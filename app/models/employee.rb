class Employee < ActiveRecord::Base
  has_and_belongs_to_many :projects
  has_many :criterionvalues, dependent: :destroy
  has_many :criterions, through: :criterionvalues
  has_many :workloads, dependent: :destroy
  has_many :weeks, through: :workloads
end
