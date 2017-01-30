class CreateCriterionparams < ActiveRecord::Migration
  def change
    create_table :criterionparams do |t|

      t.belongs_to :project, index: true
      t.belongs_to :criterion, index: true
      t.decimal :weight
      t.boolean :direction
      t.decimal :prefthresslo
      t.decimal :prefthresint
      t.decimal :inthresslo
      t.decimal :inthresint
      t.decimal :vetothresslo
      t.decimal :vetothresint
      t.decimal :filterlow
      t.decimal :filterhigh

      t.timestamps
    end
  end
end
