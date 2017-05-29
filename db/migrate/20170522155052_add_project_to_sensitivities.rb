class AddProjectToSensitivities < ActiveRecord::Migration
  def change
    add_reference :sensitivities, :project, index: true, foreign_key: true
  end
end
