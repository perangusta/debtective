# frozen_string_literal: true

require "test_helper"
require "debtective/unused/constants"

module Debtective
  module Unused
    class ConstantsTest < Minitest::Test
      def test_def_regex
        [
          ["CONST = 42", "CONST"],
          ["  CONST = 42  ", "CONST"],
          ["CONST = ANOTHER_CONST", "CONST"],
          ["CONST_X = 42", "CONST_X"],
          ["CONST_42 = 42", "CONST_42"]
        ].each do |line|
          constant = line[0].match(Debtective::Unused::Constants::DEF_REGEX)&.[](:definition)
          assert_equal line[1], constant
        end
      end

      def test_use_regex
        regex = Debtective::Unused::Constants::USE_REGEX["CONST"]
        [
          "CONST",
          " CONST ",
          "CONST.",
          "foo(CONST)",
          "CONST.call(foo)",
          "CONST[foo]",
          "Module::CONST"
        ].each do |line|
          assert !line.match(regex).nil?
        end
      end

      def test_use_regex_no_match
        regex = Debtective::Unused::Constants::USE_REGEX["CONST"]
        [
          "const",
          "CONST = 42",
          "FOO_CONST_BAR"
        ].each do |line|
          assert line.match(regex).nil?
        end
      end

      def test_service
        elements = Debtective::Unused::Constants.new.call

        [
          { filename: "app/helpers/application_helper.rb", line: 4, name: "UNUSED_CONST", count: 0 },
          { filename: "app/helpers/application_helper.rb", line: 5, name: "CONST_USED_ONCE", count: 1 },
          { filename: "app/helpers/application_helper.rb", line: 6, name: "CONST_LAMBDA", count: 2 }
        ].each do |expectation|
          assert_includes elements, expectation
        end
      end
    end
  end
end
