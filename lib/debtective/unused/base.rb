# frozen_string_literal: true

module Debtective
  module Unused
    class Base
      DIRECTORIES = %w[app lib].freeze
      EXTENSIONS  = %w[rb js erb].freeze

      def investigate
        element_counts
      end

      private

      # can the given filename contain target
      def can_contain?(_filename)
        raise "should be implemented by inherited class"
      end

      # find target definition in the given code line or return nil
      def find_def(_line)
        raise "should be implemented by inherited class"
      end

      # regex to find each target occurrences (calls and definition itself)
      def use_regex(_string)
        raise "should be implemented by inherited class"
      end

      # paths where target could be called
      def paths
        DIRECTORIES.product(EXTENSIONS).map { |pair| "#{pair[0]}/**/*.#{pair[1]}" }
      end

      # files matching these paths
      def source_files
        Dir.glob(paths, base: Rails.root).map { |filename| [filename, File.readlines(Rails.root + filename)] }.to_h
      end

      # list of targets in the codebase
      def elements
        source_files.flat_map do |filename, lines|
          next unless can_contain?(filename)

          lines.map.with_index do |line, index|
            match = find_def(line)
            # [name, position]
            # e.g. [human_readable_date, app/helpers/dates_helper:42]
            [match, "#{filename}:#{index + 1}"] if match
          end
        end.compact
      end

      # whole codebase in a single string
      def source_code
        source_files.values.flatten.join(" ")
      end

      # group targets by name and count occurrences
      # e.g. { name: 3, human_readable_date: 1 }
      def count_by_name
        elements.map(&:first).group_by(&:itself).transform_values(&:count)
      end

      # message to print
      def message
        "Scanning #{source_files.size} files for #{elements.size} #{target}..."
      end

      # iterate over all the targets and count when helper is called
      # note we cannot be sure that this is indeed this target that is called because we only check for name without module
      # save missing targets to avoid looking several time for the same target name defined in different classes
      def element_counts
        @checked = {}
        elements.map do |element|
          [element[0], element_count(element)]
        end
      end

      def element_count(element)
        # find cached count
        cached_count = @checked[element[0]]
        # set count to cached one
        return cached_count if cached_count

        # remove from count because it includes the target definition itself (eventually multiple times)
        regex = use_regex(Regexp.escape(element[0]))
        scan = source_code.scan(regex)
        # cache and return count
        @checked[element[0]] = scan.count - count_by_name[element[0]]
      end
    end
  end
end
