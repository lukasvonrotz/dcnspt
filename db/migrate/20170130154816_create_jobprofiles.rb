class CreateJobprofiles < ActiveRecord::Migration
  def change
    create_table :jobprofiles do |t|

      t.string :code
      t.string :name

      t.timestamps null: false
    end
  end
end
