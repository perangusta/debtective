# frozen_string_literal: true

require "csv"
require "test_helper"

Rails.application.load_tasks

module Debtective
  class UnusedTaskTest < Minitest::Test
    def test_unused_task_inspects_helpers
      Rake::Task[:'debtective:unused'].invoke

      csv = CSV.read(Rails.root.join("debtective/helpers.csv"))
      assert_equal 5, csv.length
      assert_equal ["file_path", "line", "name", "count"], csv[0]
      assert_equal ["app/helpers/application_helper.rb", "8", "unused_helper", "0"], csv[1]
    end

    def test_unused_task_inspects_constants
      Rake::Task[:'debtective:unused'].invoke

      csv = CSV.read(Rails.root.join("debtective/constants.csv"))
      assert_equal 4, csv.length
      assert_equal ["file_path", "line", "name", "count"], csv[0]
      assert_equal ["app/helpers/application_helper.rb", "4", "UNUSED_CONST", "0"], csv[1]
    end

    def test_unused_task_inspects_partials
      Rake::Task[:'debtective:unused'].invoke

      csv = CSV.read(Rails.root.join("debtective/partials.csv"))
      assert_equal 4, csv.length
      assert_equal ["file_path", "count"], csv[0]
      assert_equal ["app/views/users/_unused_partial.html.erb", "0"], csv[1]
    end
  end
end
