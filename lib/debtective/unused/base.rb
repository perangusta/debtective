# frozen_string_literal: true

module Debtective
  module Unused
    # Base service to find unused elements
    class Base
      # directories in which the element can be defined
      DEF_DIRECTORIES = %w[app lib].freeze
      # extensions in which the element can be defined
      DEF_EXTENSIONS  = %w[rb].freeze
      # directories in which the element can be used
      USE_DIRECTORIES = %w[app lib].freeze
      # extensions in which the element can be used
      USE_EXTENSIONS  = %w[rb js erb].freeze

      # pattern of the element definition
      DEF_REGEX = //.freeze
      # pattern of the element use
      USE_REGEX = ->(_element) { // }

      # returns elements with uses count
      # @return [Array]
      # @example [{ position: "app/helpers/aaplication_helper:42", name: "my_helper", count: 3 }, ...]
      def call
        # use cache to handle cases where the same element is defined in different classes/modules
        # (since we cannot know which one is called, we count 1 for each of them)
        @cache = {}
        paths = file_paths(self.class::DEF_DIRECTORIES, self.class::DEF_EXTENSIONS)
        Dir.glob(paths, base: Rails.root).flat_map do |filename|
          process_file(filename)
        end.compact
      end

      private

      # returns elements find in filename
      # @return [Array]
      # @example [{ position: "app/helpers/aaplication_helper:42", name: "my_helper", count: 3 }, ...]
      def process_file(filename)
        lines = File.readlines(Rails.root + filename)
        lines.map.with_index do |line, index|
          next unless (definition = line.match(self.class::DEF_REGEX)&.[](:definition))

          count = (@cache[definition] ||= definition_count(definition))
          { filename: filename, line: index + 1, name: definition, count: count }
        end
      end

      # returns count of uses for the given definition
      # @param definition [String] "my_method"
      # @return [Integer]
      def definition_count(definition)
        # use regex escape to handle element with special characters like "?" or "!"
        regex = self.class::USE_REGEX[Regexp.escape(definition)]
        source_code.scan(regex).count
      end

      # returns whole code in a single string
      # @return [String]
      # @example "module ApplicationHelper\n\n ... </html>\n\n \n <%= yield %>\n"
      def source_code
        @source_code ||=
          begin
            paths = file_paths(self.class::USE_DIRECTORIES, self.class::USE_EXTENSIONS)
            Dir.glob(paths, base: Rails.root).map do |filename|
              File.readlines(Rails.root + filename)
            end.join("\n \n ")
          end
      end

      # returns file paths matching directories and extensions
      # @return [Array<String>]
      # @param directories [Array<String>] ["app" "lib"]
      # @param extensions [Array<String>] ["rb" "js"]
      # @example ["app/helpers/**/*.rb", ..., "app/views/**/*.erb"]
      def file_paths(directories, extensions)
        directories.product(extensions).map { |pair| "#{pair[0]}/**/*.#{pair[1]}" }
      end
    end
  end
end
