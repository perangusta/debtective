# frozen_string_literal: true

class CreateDebtectiveUsers < ActiveRecord::Migration[6.1]
  def change
    create_table :debtective_users do |t|
      t.string :first_name
      t.string :last_name

      t.timestamps
    end
  end
end