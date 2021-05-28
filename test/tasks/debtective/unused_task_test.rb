# frozen_string_literal: true

require "csv"
require "test_helper"

Rails.application.load_tasks

module Debtective
  class UnusedTaskTest < Minitest::Test
    def test_unused_task_inspects_helpers
      Rake::Task[:'debtective:unused'].invoke

      unused_helpers_csv = CSV.read(Rails.root.join("debtective/unused_helpers.csv"))
      assert_equal 5, unused_helpers_csv.length
      assert_equal ["filename", "line", "name", "count"], unused_helpers_csv[0]
      assert_equal ["app/helpers/application_helper.rb", "8", "unused_helper", "0"], unused_helpers_csv[1]
    end

    def test_unused_task_inspects_constants
      Rake::Task[:'debtective:unused'].invoke

      unused_constants_csv = CSV.read(Rails.root.join("debtective/unused_constants.csv"))
      assert_equal 4, unused_constants_csv.length
      assert_equal ["filename", "line", "name", "count"], unused_constants_csv[0]
      assert_equal ["app/helpers/application_helper.rb", "4", "UNUSED_CONST", "0"], unused_constants_csv[1]
    end
  end
end
