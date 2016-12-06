class Criterion < ActiveRecord::Base
  has_many :criterionvalues
  has_many :employees, through: :criterionvalues
  has_many :criterionparams
  has_many :projects, through: :criterionparams
  belongs_to :criterioncontext
end
