class CreateCriterionparams < ActiveRecord::Migration
  def change
    create_table :criterionparams do |t|

      t.belongs_to :project, index: true
      t.belongs_to :criterion, index: true
      t.decimal :weight, :default => 0.1
      t.boolean :direction, :default => true
      t.decimal :prefthresslo, :default => 0.1
      t.decimal :prefthresint, :default => 0.1
      t.decimal :inthresslo, :default => 0.1
      t.decimal :inthresint, :default => 0.1
      t.decimal :vetothresslo, :default => 0.1
      t.decimal :vetothresint, :default => 0.1
      t.decimal :filterlow, :default => 0
      t.decimal :filterhigh, :default => 100000

      t.timestamps
    end
  end
end
