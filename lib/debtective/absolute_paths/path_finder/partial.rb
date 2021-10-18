# frozen_string_literal: true

module Debtective
  module AbsolutePaths
    module PathFinder
      # Find partial absolute path
      class Partial
        VIEW_FILE_PATHS = Dir.glob(["app/views/**/*.erb"], base: Rails.root)
        PARTIAL_REGEX = %r{app/views/(.*)/}.freeze

        attr_reader :partial, :view_file_path, :absolute_path, :partial_file_path, :path_type

        alias element partial
        alias element_file_path partial_file_path

        # :nodoc:
        def initialize(partial, view_file_path)
          @partial = partial
          @view_file_path = view_file_path
        end

        # @return [String]
        # @example => "users/form"
        # @note => set @absolute_paths, @partial_file_path and @path_type
        def call
          @absolute_path = find_absolute_path
        end

        # @return [String]
        # @example => "users/form"
        def corrected_path
          @corrected_path ||= @absolute_path || @partial
        end

        # @return [Boolean]
        def corrected?
          @partial != corrected_path
        end

        private

        # @return [String, nil]
        # @example => "users/form"
        def find_absolute_path
          # do not search absolute path of interpolated partial like "#{page}/form"
          if @partial.match?(/#\{.*\}/)
            @path_type = "interpolated"
            nil
          else
            current_partial || partial_in_directory || partial_in_application || partial_somewhere || missing_file!
          end
        end

        # set path_type to missing
        # @return [void]
        def missing_file!
          @path_type = "missing"
          nil
        end

        # @return [String]
        # @example
        #   partial is "users/form" and file "app/views/users/_form.html.erb" exists
        #   => "users/form"
        #   partial is "shared/menu" and file "app/views/shared/_menu.html.erb" exists
        #   => "shared/menu" and set path_type to "absolute"
        # @note set path_type
        def current_partial
          @partial_file_path = partial_file_for(@partial)
          return if @partial_file_path.nil?

          @path_type = "absolute"
          @partial
        end

        # @return [String]
        # @example
        #   partial is "form", view_file_path is "app/views/users/new.html"
        #   and "app/views/users/_form.html.erb" exists
        #   => "users/form" and set path_type to "relative"
        # @note set path_type
        def partial_in_directory
          directory = @view_file_path.match(PARTIAL_REGEX)[1]
          @partial_file_path = partial_file_for("#{directory}/#{@partial}")
          return if @partial_file_path.nil?

          @path_type = "relative"
          "#{directory}/#{@partial}"
        end

        # @return [String]
        # @example
        #   partial is "menu" and file "app/views/application/_menu.html.erb" exists
        #   => "application/menu" and set path_type to "application"
        # @note set path_type
        def partial_in_application
          @partial_file_path = partial_file_for("application/#{@partial}")
          return if @partial_file_path.nil?

          @path_type = "application"
          "application/#{@partial}"
        end

        # @return [String]
        # @example
        #   partial is "form" and file "app/views/articles/_form.html.erb" exists
        #   => "articles/form" and set path_type to "other"
        # @note set path_type
        def partial_somewhere
          @partial_file_path = file_matching_regex(%r{app/views/.*_#{@partial}(\.\w+)?\.erb})
          return if @partial_file_path.nil?

          @path_type = "other"
          @partial_file_path.match(PARTIAL_REGEX)[2]
        end

        # find the file matching the given partial absolute path
        # @param partial_path [String]
        # @return [String]
        # @example
        #   partial_file_for("users/form") => "app/views/users/_form.html.erb"
        #   partial_file_for("form") => nil
        def partial_file_for(partial_path)
          match = partial_path.match(%r{(?<directory>.*)/(?<file>.*)})
          return unless match

          file_matching_regex(%r{app/views/#{match[:directory]}/_#{match[:file]}(\.\w+)*\.erb})
        end

        # return first file matching regex
        # @param regex [Regexp]
        # @return [String]
        # @example
        #   file_matching_regex(/app\/views\/.*\_form.html\.erb/) => "app/views/articles/_form.html.erb"
        def file_matching_regex(regex)
          VIEW_FILE_PATHS.find do |view_file_path|
            view_file_path.match?(regex)
          end
        end
      end
    end
  end
end
