class CreateCriterions < ActiveRecord::Migration
  def change
    create_table :criterions do |t|

      t.belongs_to :criterioncontext, index: true
      t.string :name

      t.timestamps null: false
    end
  end
end
