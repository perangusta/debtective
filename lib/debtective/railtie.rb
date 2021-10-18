# frozen_string_literal: true

module Debtective
  # Makes Rails aware of the tasks
  class Railtie < Rails::Railtie
    rake_tasks do
      load "tasks/debtective/absolute_paths/locales.rake"
      load "tasks/debtective/absolute_paths/partials.rake"
      load "tasks/debtective/unused.rake"
    end
  end
end
