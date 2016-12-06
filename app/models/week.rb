class Week < ActiveRecord::Base
  has_many :workloads, dependent: :destroy
  has_many :employees, through: :workloads
end
