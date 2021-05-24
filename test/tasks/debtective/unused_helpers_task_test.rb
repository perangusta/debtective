# frozen_string_literal: true

require "csv"
require "test_helper"

Rails.application.load_tasks

module Debtective
  class TaskTest < Minitest::Test
    def test_unused_helpers
      Rake::Task[:'debtective:unused_helpers'].invoke
      csv = CSV.read(Rails.root.join("debtective/unused_helpers.csv"))
      assert_equal csv[0], ["helper", "uses"]
      assert_equal csv[1], ["used_0_time", "0"]
      assert_equal csv[2], ["used_1_time", "1"]
      assert_equal csv[3], ["used_2_times", "2"]
    end
  end
end
