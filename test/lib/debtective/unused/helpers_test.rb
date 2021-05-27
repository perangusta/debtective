# frozen_string_literal: true

require "test_helper"
require "debtective/unused/helpers"

module Debtective
  module Unused
    class HelpersTest < Minitest::Test
      def test_def_regex
        [
          "def hello_world",
          "  def hello_world  ",
          "def hello_world # comment",
          "def hello_world()",
          "def hello_world(a, b)",
          "def hello_world(a: \"hello world\")",
          "def hello_world(a: \"(hello) (world)\")",
          "def hello_world; end"
        ].each do |line|
          helper = line.match(Debtective::Unused::Helpers::DEF_REGEX)&.[](:definition)
          assert_equal "hello_world", helper
        end
      end

      def test_def_regex_with_!
        helper = "def hello_world!(a, b)".match(Debtective::Unused::Helpers::DEF_REGEX)&.[](:definition)
        assert_equal "hello_world!", helper
      end

      def test_def_regex_with_?
        helper = "def hello_world?(a, b)".match(Debtective::Unused::Helpers::DEF_REGEX)&.[](:definition)
        assert_equal "hello_world?", helper
      end

      def test_use_regex
        regex = Debtective::Unused::Helpers::USE_REGEX["example"]
        [
          "example",
          " example ",
          "Helper.example",
          "foo(example)",
          "example(foo)",
          "example.to_s",
          "module Helper\n   def foobar\n     example\n   end\n \n end\n"
        ].each do |line|
          assert !line.match(regex).nil?
        end
      end

      def test_use_regex_no_match
        regex = Debtective::Unused::Helpers::USE_REGEX["example"]
        [
          "_example",
          "example_",
          "def example",
          "def example\n",
          "module Helper\n   def example\n     1 + 1\n   end\n \n end\n"
        ].each do |line|
          assert line.match(regex).nil?
        end
      end

      def test_service
        elements = Debtective::Unused::Helpers.new.call

        assert_includes elements, { position: "app/helpers/application_helper.rb:4", name: "used_0_time", count: 0 }
        assert_includes elements, { position: "app/helpers/application_helper.rb:8", name: "used_1_time", count: 1 }
        assert_includes elements, { position: "app/helpers/application_helper.rb:12", name: "used_2_times", count: 2 }
        assert_includes elements, { position: "app/helpers/example_helper.rb:6", name: "example_1_time", count: 1 }
      end
    end
  end
end
