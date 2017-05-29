class CreateSensitivities < ActiveRecord::Migration
  def change
    create_table :sensitivities do |t|
      t.float :indslo
      t.float :indint
      t.float :prefslo
      t.float :prefint
      t.float :vetslo
      t.float :vetint

      t.timestamps null: false
    end
  end
end
