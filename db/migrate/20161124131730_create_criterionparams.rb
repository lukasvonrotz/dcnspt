class CreateCriterionparams < ActiveRecord::Migration
  def change
    create_table :criterionparams do |t|

      t.belongs_to :project, index: true
      t.belongs_to :criterion, index: true
      t.decimal :weight
      t.decimal :preferencethreshold
      t.decimal :indifferencethreshold
      t.decimal :vetothreshold

      t.timestamps
    end
  end
end
