class CreateProjects < ActiveRecord::Migration
  def change
    create_table :projects do |t|

      t.string :name
      t.decimal :loclat
      t.decimal :loclon
      t.datetime :startdate
      t.datetime :enddate
      t.decimal :effort
      t.decimal :hourlyrate


      t.timestamps null: false
    end
  end
end
