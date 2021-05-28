# frozen_string_literal: true

require "csv"

namespace :debtective do
  desc "Find unused helpers and constants"
  task :unused do
    targets = %w[helpers constants]
    targets.each do |target|
      require "debtective/unused/#{target}"

      elements = "Debtective::Unused::#{target.capitalize}".constantize.new.call
      elements.sort_by! { |element| element[:count] }

      # create /debtective directory
      FileUtils.mkdir_p(Rails.root.join("debtective")) unless File.directory?(Rails.root.join("debtective"))
      # create debtective/unused_<target>.csv and write elements data
      CSV.open(Rails.root.join("debtective/unused_#{target}.csv"), "w") do |csv|
        csv << ["filename", "line", "name", "count"]
        elements.sort_by(&:count).each do |element|
          csv << element.values
        end
      end
    end
  end
end
