# frozen_string_literal: true

require "test_helper"
require "debtective/unused/helpers"

module Debtective
  module Unused
    class HelpersTest < Minitest::Test
      def test_def_regex
        [
          ["def hello_world", "hello_world"],
          ["  def hello_world  ", "hello_world"],
          ["def hello_world # comment", "hello_world"],
          ["def hello_world()", "hello_world"],
          ["def hello_world(a, b)", "hello_world"],
          ["def hello_world(a: \"hello world\")", "hello_world"],
          ["def hello_world(a: \"(hello) (world)\")", "hello_world"],
          ["def hello_world; end", "hello_world"],
          ["def hello_world!(a, b)", "hello_world!"],
          ["def hello_world?(a, b)", "hello_world?"]

        ].each do |line|
          helper = line[0].match(Debtective::Unused::Helpers::DEF_REGEX)&.[](:def)
          assert_equal line[1], helper
        end
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
          "EXAMPLE",
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

        [
          { file_path: "app/helpers/application_helper.rb", line: 8, name: "unused_helper", count: 0 },
          { file_path: "app/helpers/application_helper.rb", line: 14, name: "helper_used_once", count: 1 },
          { file_path: "app/helpers/application_helper.rb", line: 18, name: "helper_used_twice", count: 2 },
          { file_path: "app/helpers/users_helper.rb", line: 6, name: "users_helper_used_once", count: 1 }
        ].each do |expectation|
          assert_includes elements, expectation
        end
      end
    end
  end
end
