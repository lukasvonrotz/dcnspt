class AddJobprofileToEmployees < ActiveRecord::Migration
  def change
    add_reference :employees, :jobprofile, index: true, foreign_key: true
  end
end
