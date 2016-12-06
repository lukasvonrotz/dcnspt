class CreateWorkloads < ActiveRecord::Migration
  def change
    create_table :workloads do |t|

      t.belongs_to :employee, index: true
      t.belongs_to :week, index: true
      t.decimal :free
      t.decimal :offered
      t.decimal :sold
      t.decimal :absent

      t.timestamps null: false
    end
  end
end
