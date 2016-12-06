class CreateJoinTable < ActiveRecord::Migration
  def change
    create_join_table :projects, :employees do |t|
      # t.index [:project_id, :employee_id]
      # t.index [:employee_id, :project_id]
    end
  end
end
