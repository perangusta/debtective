# frozen_string_literal: true

require "csv"

namespace :debtective do
  desc "Find unused"
  task :unused_helpers do
    require "debtective/unused/helpers"

    elements = Debtective::Unused::Helpers.new.investigate

    FileUtils.mkdir_p(Rails.root.join("debtective")) unless File.directory?(Rails.root.join("debtective"))
    CSV.open(Rails.root.join("debtective/unused_helpers.csv"), "w") do |csv|
      csv << ["helper", "uses"]
      elements.sort_by(&:last).each do |element|
        csv << element
      end
    end
  end
end
