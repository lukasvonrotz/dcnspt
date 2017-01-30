class CreateEmployees < ActiveRecord::Migration
  def change
    create_table :employees do |t|

      t.string :firstname
      t.string :surname
      t.decimal :loclat
      t.decimal :loclon
      t.string :country
      t.decimal :costrate

      t.timestamps null: false
    end
  end
end
