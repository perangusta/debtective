# frozen_string_literal: true

require "debtective/unused/base"

module Debtective
  module Unused
    # Inspect partials usage
    class Partials < Base
      DEF_DIRECTORIES = %w[app/views].freeze
      DEF_EXTENSIONS  = %w[html.erb].freeze
      USE_DIRECTORIES = DEF_DIRECTORIES
      USE_EXTENSIONS  = DEF_EXTENSIONS
      DEF_REGEX = %r{app/views/(?<dir>(?:\w+/)*\w+)/_(?<def>\w+).#{DEF_EXTENSIONS.join("|")}}.freeze

      # returns partial with computed data if file_path is a partial
      # @return [Array<Hash>, nil]
      # @example [{ file_path: "app/views/users/_form", count: 3 }, ...]
      def process_file(file_path)
        match = file_path.match(DEF_REGEX)
        return unless match

        { file_path: file_path, count: uses_count(match[:dir], match[:def]) }
      end

      # returns count of uses for the given definition
      # @param partial_dir [String] "admin/users"
      # @param partial [String] "my_partial"
      # @return [Integer]
      def uses_count(partial_dir, partial)
        source_code_file_paths.sum do |file_path|
          file_code = File.readlines(Rails.root + file_path).join("\n")
          file_dir = file_path.match(%r{app/views/(?<dir>(?:\w+/)*\w+)/.*})[:dir]
          regex =
            if file_dir == partial_dir
              %r{render partial: ("|')(#{partial_dir}/)?#{partial}("|')}
            else
              %r{render partial: ("|')#{partial_dir}/#{partial}("|')}
            end
          file_code.scan(regex).count
        end
      end
    end
  end
end
