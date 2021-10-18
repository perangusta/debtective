# frozen_string_literal: true

require "debtective/unused/base"

module Debtective
  module Unused
    # Inspect partials usage
    class Partials < Base
      DEF_DIRECTORIES = %w[app/views].freeze
      DEF_EXTENSIONS  = %w[html.erb].freeze
      DEF_REGEX = %r{app/views/(?<dir>(?:\w+/)*\w+)/_(?<def>\w+).#{DEF_EXTENSIONS.join("|")}}.freeze

      # returns partial with computed data if file_path is a partial
      # @return [Array<Hash>, nil]
      # @example [{ file_path: "app/views/users/_form", count: 3 }, ...]
      def process_file(file_path)
        partial = file_path.match(DEF_REGEX)
        return unless partial

        { file_path: file_path, count: uses_count(partial) }
      end

      # returns count of uses for the given definition
      # @param partial [Hash] { def: "form", dir: "admin/users" }
      # @return [Integer]
      def uses_count(partial)
        source_code_files.sum do |file|
          regex = /render(\(|\s)(partial:\s)?("|')(#{regex_path(partial, file)})("|')/
          file[:code].scan(regex).count
        end
      end

      # returns partial path depending on current file
      # @param partial [Hash] { def: "form", dir: "users" }
      # @param file [Hash] { dir: "pages/home" }
      # @return [Regex] "users/form"
      #
      # TODO: find a recursive way to allow any subpath
      #   partial in "app/views/admin/users/form" can be called from "app/views/admin/pages/home"
      #   with "admin/users/form" and "users/form"
      def regex_path(partial, file)
        if file[:dir] == partial[:dir]
          # partial directory is optional
          # app/views/users/index -> render partial: "form"
          %r{(#{partial[:dir]}/)?#{partial[:def]}}
        else
          # partial directory is mandatory
          # app/views/pages/home -> render partial: "users/form"
          %r{#{partial[:dir]}/#{partial[:def]}}
        end
      end

      # returns source code files data
      # @return [Array<Hash>]
      # @example [{ path: "app/views/users/index", dir: "users", code: "<div>...</div>" }]
      def source_code_files
        @source_code_files ||=
          source_code_file_paths.map do |file_path|
            {
              path: file_path,
              dir: file_path.match(%r{app/views/(?<dir>(?:\w+/)*\w+)/.*})&.[](:dir),
              code: File.readlines(Rails.root + file_path).join("\n")
            }
          end
      end
    end
  end
end
