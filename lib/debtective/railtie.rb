# frozen_string_literal: true

module Debtective
  # Makes Rails aware of the tasks
  class Railtie < Rails::Railtie
    rake_tasks do
      load "tasks/debtective_tasks.rake"
    end
  end
end
