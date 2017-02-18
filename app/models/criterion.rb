class Criterion < ActiveRecord::Base
  has_many :criterionvalues, dependent: :delete_all
  has_many :employees, through: :criterionvalues
  has_many :criterionparams, dependent: :delete_all
  has_many :projects, through: :criterionparams
  belongs_to :criterioncontext
end
