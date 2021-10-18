# frozen_string_literal: true

module Debtective
  module AbsolutePaths
    module Correcter
      # Find elements absolute paths
      class Base
        VIEW_FILE_PATHS = Dir.glob(["app/views/**/*.erb"], base: Rails.root)

        attr_reader :path_finders

        # these methods should be implemented in inherited classes
        %w[path_finder_class before_regex element_regex after_regex].each do |method_name|
          define_method(method_name) { raise "#{method_name} should be defined by inherited class" }
        end

        # :nodoc:
        # @param autocorrect [Boolean] correct the file (rewrite)
        def initialize(autocorrect: false, verbose: false)
          @autocorrect = autocorrect
          @verbose = verbose
          @path_finders = []
        end

        # :nodoc:
        def call
          @path_finders = []
          VIEW_FILE_PATHS.each do |view_file_path|
            corrected_lines = []
            lines = File.readlines("#{Rails.root}/#{view_file_path}")
            lines.each do |line|
              line_after = corrected_line(line, view_file_path) || line
              corrected_lines << line_after
            end
            next if !@autocorrect || corrected_lines == lines

            correct_file(view_file_path, corrected_lines)
          end
          log_results
        end

        private

        # return regex matching line with searched element
        # @return [Regexp]
        def line_with_element_regex
          @line_with_element_regex ||=
            Regexp.new("(?<before>(#{before_regex}))(?<element>(#{element_regex}))(?<after>(#{after_regex}))")
        end

        # correct the line with an absolute path
        # @param line [String]
        # @param view_file_path [String]
        # @return [String, nil] corrected line if needed
        # @note populate @path_finders
        def corrected_line(line, view_file_path)
          match = line.match(line_with_element_regex)
          return unless match

          path_finder = path_finder_class.new(match[:element], view_file_path)
          path_finder.call
          @path_finders << path_finder
          return unless path_finder.corrected?

          line.gsub(
            line_with_element_regex,
            "#{match[:before]}#{path_finder.corrected_path}#{match[:after]}"
          )
        end

        # replace file content by corrected lines
        # @param file_path [String]
        # @param corrected_lines [Array<String>]
        # @return nil
        def correct_file(file_path, corrected_lines)
          file = File.open(Rails.root + file_path, "w")
          begin
            corrected_lines.each { |corrected_line| file << corrected_line }
          ensure
            file.close
          end
        end

        # returns counts per path type
        # @return [Hash]
        # @example { "absolute" => 42, "relative" => 7 }
        def counts_per_type
          @path_finders.group_by(&:path_type).transform_values(&:count)
        end

        # describe results (stdout)
        # @return [void]
        def log_results
          return unless @verbose

          puts <<-TEXT
            elements found:             #{@path_finders.count.to_s.rjust(9)}
            -> with absolute path:      #{describe_path_types("absolute")}
            -> with correctable path:   #{describe_path_types("relative")}
            -> with uncorrectable path: #{describe_path_types("missing", "incomplete", "interpolated")}
          TEXT

          warn_missing_files
        end

        # return description for types
        # @param types [*Array]
        # @return [String]
        def describe_path_types(*types)
          count = counts_per_type.values_at(*types).compact.sum
          "#{count.to_s.rjust(9)} (#{((count / Float(@path_finders.count)) * 100).round(3)}%)"
        end

        # warn about missing element (stdout)
        # @return [void]
        def warn_missing_files
          return if counts_per_type["missing"].nil? || counts_per_type["missing"].zero?

          puts "some paths seem to be incorrect. You should check them:"
          @path_finders.each do |path_finder|
            next unless path_finder.path_type == "missing"

            puts "- path \"#{path_finder.element}\" in #{path_finder.view_file_path}"
          end
        end
      end
    end
  end
end
