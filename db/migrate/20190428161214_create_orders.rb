# frozen_string_literal: true

class CreateOrders < ActiveRecord::Migration[6.0]
  def change
    create_table :orders do |t|
      t.references :user, null: false, foreign_key: true

      t.string :imei, limit: 18, null: false
      t.string :phone_model, limit: 100, null: false
      t.decimal :annual_price,
                precision: 10,
                scale: 2,
                default: 0.0,
                null: false
      t.integer :installments, default: 1, null: false

      t.timestamps
    end
  end
end
