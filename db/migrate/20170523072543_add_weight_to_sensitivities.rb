class AddWeightToSensitivities < ActiveRecord::Migration
  def change
    add_column :sensitivities, :weight, :float
  end
end
