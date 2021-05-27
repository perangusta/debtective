# frozen_string_literal: true

class ApplicationController < ActionController::Base
  def index
    ExampleHelper.example_1_time
  end
end
