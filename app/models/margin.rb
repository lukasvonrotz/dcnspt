class Margin
  def self.get_margin(rate_project, rate_employee)
    if rate_project && rate_employee
      return rate_project-rate_employee
    end
    return 0
  end
end
