class Employee < ActiveRecord::Base
  has_and_belongs_to_many :projects
  has_many :criterionvalues, dependent: :delete_all
  has_many :criterions, through: :criterionvalues
  has_many :workloads, dependent: :delete_all
  has_many :weeks, through: :workloads
  belongs_to :jobprofile

end
