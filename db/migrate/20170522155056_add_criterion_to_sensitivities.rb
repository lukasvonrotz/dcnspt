class AddCriterionToSensitivities < ActiveRecord::Migration
  def change
    add_reference :sensitivities, :criterion, index: true, foreign_key: true
  end
end
