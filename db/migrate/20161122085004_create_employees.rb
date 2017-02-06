class CreateEmployees < ActiveRecord::Migration
  def change
    create_table :employees do |t|

      t.string :code
      t.string :firstname
      t.string :surname
      t.string :city
      t.decimal :loclat
      t.decimal :loclon
      t.string :location
      t.string :country
      t.decimal :costrate

      t.timestamps null: false
    end
  end
end
