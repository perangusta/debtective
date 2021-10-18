# frozen_string_literal: true

module Debtective
  module AbsolutePaths
    module PathFinder
      # Find locale absolute path
      class Locale
        attr_reader :locale, :view_file_path, :absolute_path, :locale_file_path, :path_type

        alias element locale
        alias element_file_path locale_file_path

        # :nodoc:
        def initialize(locale, view_file_path)
          @locale = locale
          @view_file_path = view_file_path
        end

        # @return [String]
        # @example => "projects.index.list"
        # @note => set @absolute_path, @locale_file_path and @path_type
        def call
          @absolute_path = find_absolute_path
        end

        # @return [String]
        # @example => "projects.index.list"
        def corrected_path
          @corrected_path ||= @absolute_path || @locale
        end

        # @return [Boolean]
        def corrected?
          @locale != corrected_path
        end

        private

        # @return [String, nil]
        # @example => "projects.index.list"
        # TODO: refacto
        def find_absolute_path
          path = nil

          # do not search absolute path of interpolated locale like "activerecord.attributes.#{object_type}.name"
          if @locale.match?(/#\{.*\}/)
            @path_type = "interpolated"
            nil
          else
            if @locale.start_with?(".")
              view = @view_file_path.match(%r{app/views/((\w|\d|/)+)\..*})[1]
              @path_type = "relative"
              path = view.gsub("/", ".").gsub("._", ".") + locale
            else
              @path_type = "absolute"
              path = @locale
            end

            begin
              translation = I18n.t!(path)
              if translation.is_a?(Hash) && !translation.keys.include?(:one)
                @path_type = "incomplete"
                nil
              else
                path
              end
            rescue I18n::MissingTranslationData
              @path_type = "missing"
              nil
            end
          end
        end
      end
    end
  end
end
