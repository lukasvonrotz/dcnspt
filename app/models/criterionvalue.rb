class Criterionvalue < ActiveRecord::Base
  belongs_to :criterion
  belongs_to :employee
end
