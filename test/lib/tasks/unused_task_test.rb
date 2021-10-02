# frozen_string_literal: true

require "csv"
require "fileutils"
require "test_helper"

Rails.application.load_tasks

module Debtective
  class UnusedTaskTest < Minitest::Test
    def test_unused_task
      directory_path = Rails.root.join("debtective")

      FileUtils.remove_dir(directory_path) if File.directory?(directory_path)
      Rake::Task[:"debtective:unused"].invoke

      # helpers
      csv_path = Rails.root.join("debtective/helpers.csv")
      assert File.exist?(csv_path)
      csv = CSV.read(csv_path)
      assert_equal 5, csv.length
      assert_equal ["file_path", "line", "name", "count"], csv[0]
      assert_equal ["app/helpers/application_helper.rb", "8", "unused_helper", "0"], csv[1]

      # constants
      csv_path = Rails.root.join("debtective/constants.csv")
      assert File.exist?(csv_path)
      csv = CSV.read(csv_path)
      assert_equal 4, csv.length
      assert_equal ["file_path", "line", "name", "count"], csv[0]
      assert_equal ["app/helpers/application_helper.rb", "4", "UNUSED_CONST", "0"], csv[1]

      # partials
      csv_path = Rails.root.join("debtective/partials.csv")
      assert File.exist?(csv_path)
      csv = CSV.read(csv_path)
      assert_equal 4, csv.length
      assert_equal ["file_path", "count"], csv[0]
      assert_equal ["app/views/users/_unused_partial.html.erb", "0"], csv[1]
    ensure
      FileUtils.remove_dir(directory_path) if File.directory?(directory_path)
    end
  end
end
