class CreateCriterioncontexts < ActiveRecord::Migration
  def change
    create_table :criterioncontexts do |t|

      t.string :name
      t.timestamps null: false
    end
  end
end
