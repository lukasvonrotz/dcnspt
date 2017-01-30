class CreateCriterionvalues < ActiveRecord::Migration
  def change
    create_table :criterionvalues do |t|

      t.belongs_to :employee, index: true
      t.belongs_to :criterion, index: true
      t.decimal :value, :precision => 10, :scale => 3

      t.timestamps
    end
  end
end
