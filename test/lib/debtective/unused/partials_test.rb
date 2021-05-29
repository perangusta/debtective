# frozen_string_literal: true

require "test_helper"
require "debtective/unused/partials"

module Debtective
  module Unused
    class PartialsTest < Minitest::Test
      def test_service
        elements = Debtective::Unused::Partials.new.call

        [
          { file_path: "app/views/users/_unused_partial.html.erb", count: 0 },
          { file_path: "app/views/users/_partial_used_once.html.erb", count: 1 },
          { file_path: "app/views/users/_partial_used_twice.html.erb", count: 2 }
        ].each do |expectation|
          assert_includes elements, expectation
        end
      end
    end
  end
end
