# frozen_string_literal: true

require "debtective/unused/base"

module Debtective
  module Unused
    class Helpers < Base
      private

      # can the given filename contain target
      def can_contain?(filename)
        filename.start_with? "app/helpers"
      end

      # find target definition in the given code line or return nil
      def find_def(line)
        line.match(/(^|\s)def\s(\w+)(\?|!)?(\(.*\))?$/)&.[](2)
      end

      # regex to find each target occurrences (calls and definition itself)
      def use_regex(helper)
        /(?!(\w|-|\.))*#{helper}(?!(\w|-))*/
      end
    end
  end
end
