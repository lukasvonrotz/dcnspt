module ProjectsHelper
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
end
