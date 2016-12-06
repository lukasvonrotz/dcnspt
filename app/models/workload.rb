class Workload < ActiveRecord::Base
  belongs_to :week
  belongs_to :employee
end
