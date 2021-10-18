# frozen_string_literal: true

require "debtective/absolute_paths/correcter/base"
require "debtective/absolute_paths/path_finder/partial"

module Debtective
  module AbsolutePaths
    module Correcter
      # Find elements absolute paths
      class Partials < Base
        private

        # regex match partial in codebase:
        # <span><%= render "hello/world" %></span>
        # <span><%= render "hello" %></span>
        # <span><%= render partial: "hello/world" %></span>
        # <span><%= render "hello/world", count: 42 %></span>
        # etc.

        # return code before partial
        # @return [Regexp]
        def before_regex
          /render(\(|\s)(partial:(\(|\s))?('|")/
        end

        # return partial (path)
        # @return [Regexp]
        def element_regex
          %r{(\w|\d|/|_|\#\{.*\})+}
        end

        # return code after partial
        # @return [Regexp]
        def after_regex
          /'|"/
        end

        # return path finder class
        # @return [Class]
        def path_finder_class
          AbsolutePaths::PathFinder::Partial
        end
      end
    end
  end
end
