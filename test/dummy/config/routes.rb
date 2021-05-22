# frozen_string_literal: true

Rails.application.routes.draw do
  mount Debtective::Engine => "/debtective"
end
