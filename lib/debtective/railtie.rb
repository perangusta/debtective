# frozen_string_literal: true

require "debtective"
require "rails"

module Debtective
  # Makes Rails aware of the tasks
  class Railtie < Rails::Railtie
    rake_tasks do
      load "tasks/debtective/unused.rake"
    end
  end
end
