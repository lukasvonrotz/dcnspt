class Project < ActiveRecord::Base
  has_and_belongs_to_many :employees
  belongs_to :user
  has_many :criterionparams, dependent: :destroy
  has_many :criterions, through: :criterionparams



end
