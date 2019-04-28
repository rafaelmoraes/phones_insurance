# frozen_string_literal: true

class CreateUsers < ActiveRecord::Migration[6.0]
  def change
    create_table :users do |t|
      t.string :name, limit: 100, null: false
      t.string :email, limit: 100, null: false
      t.string :cpf, limit: 14, null: false, unique: true

      t.timestamps
    end
    add_index :users, :cpf
  end
end
