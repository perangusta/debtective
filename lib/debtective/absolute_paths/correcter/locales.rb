# frozen_string_literal: true

require "debtective/absolute_paths/correcter/base"
require "debtective/absolute_paths/path_finder/locale"

module Debtective
  module AbsolutePaths
    module Correcter
      # Find elements absolute paths
      class Locales < Base
        private

        # regex match locale in codebase:
        # <span><%= t("hello.world") %></span>
        # <span><%= t(".hello") %></span>
        # <span><%= t("hello.#{var}.world") %></span>
        # <span><%= t("hello.world", count: 2) %></span>
        # etc.

        # return code before locale
        # @return [Regexp]
        def before_regex
          # t("
          /
            (?<!\w)t # I18n t method
            (\(|\s)  # a parenthesis or a space
            ("|')    # a simple or double quote
          /x
        end

        # return locale (path)
        # @return [Regexp]
        def element_regex
          key_regex = /(\w|\d|_|\#\{.*\})+/
          /
            \.?               # start with a dot if path is relative
            (#{key_regex}\.)* # optional intermediary keys ending with dot
            (#{key_regex})    # last key
          /x
        end

        # return code after locale
        # @return [Regexp]
        def after_regex
          /"|'/ # a simple or double quote
        end

        # return path finder class
        # @return [Class]
        def path_finder_class
          AbsolutePaths::PathFinder::Locale
        end
      end
    end
  end
end
