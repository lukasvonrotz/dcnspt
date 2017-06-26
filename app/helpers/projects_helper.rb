module ProjectsHelper

  require 'open-uri'

  def saveFilterValues(numberofcrits)
    index = 1
    while index <= numberofcrits
      @project.criterionparams[index-1].filterlow = params[variablenamelow(index)]
      @project.criterionparams[index-1].filterhigh = params[variablenamehigh(index)]
      @project.criterionparams[index-1].save
      index += 1
    end
  end

  def variablenamelow (index)
    var = "crit" + index.to_s + "low"
    return var
  end

  def variablenamehigh (index)
    var = "crit" + index.to_s + "high"
    return var
  end

  def internet_connection?
    begin
      true if open("http://www.google.com/")
    rescue
      false
    end
  end

  # if location is a criterion of the project, check whether the distance to customer of the employee is within the range
  def check_location(employee, fulfilled)
    locationid = Criterion.where(name: 'location').first.id
    distance = Location.get_distance(employee.loclat,employee.loclon,@project.loclat,@project.loclon)
    if (Criterionparam.where(project_id: @project.id, criterion_id: locationid).first.filterlow <= distance) &&
        (Criterionparam.where(project_id: @project.id, criterion_id: locationid).first.filterhigh >= distance)
      fulfilled += 1
    end

    return fulfilled
  end

  # if costrate is a criterion of the project, check whether the costrate of the employee is within the range
  def check_margin(employee, fulfilled)
    costrateid = Criterion.where(name: 'costrate').first.id
    margin = Margin.get_margin(@project.hourlyrate,employee.costrate)
    if (Criterionparam.where(project_id: @project.id, criterion_id: costrateid).first.filterlow <= margin) &&
        (Criterionparam.where(project_id: @project.id, criterion_id: costrateid).first.filterhigh >= margin)
      fulfilled += 1
    end

    return fulfilled
  end

  def check_other_criteria(criterionparam, employee, fulfilled)
    criterionvalue = employee.criterionvalues.find_by(criterion_id: criterionparam.criterion.id).value.to_f
    filterhigh = criterionparam.filterhigh + 0.1
    filterlow = criterionparam.filterlow - 0.1
    # compare criterion value of employee with filter values
    if (filterlow <= criterionvalue) && (filterhigh >= criterionvalue)
      fulfilled += 1
    end
    return fulfilled
  end

  def check_if_filter_zero(criterionparam, fulfilled)
    filterlow = criterionparam.filterlow - 0.1
    if filterlow <= 0
      fulfilled +=1
    end
    return fulfilled
  end
end
