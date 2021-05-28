# frozen_string_literal: true

class UsersController < ApplicationController
  def index
    ExampleHelper.users_helper_used_once
  end
end
