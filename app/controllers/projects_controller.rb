class ProjectsController < ApplicationController

  before_filter :authenticate_user!

  def new
    # build a 'temporary' post which is written to DB later (create-method)
    @project = Project.new
  end

  def create
    @project = Project.new(project_params)
    @project.user = current_user
    # write project to database
    if @project.save
      redirect_to projects_path, :notice => 'Project successufully created'
    else
      render 'new'
    end
  end

  def edit
    @project = Project.find(params[:id])
  end

  def update
    if params[:id]
      @project = Project.find(params[:id])
    else
      @project = Project.find(params[:project_id])
    end

    if !params[:numberofcrits].nil?
      jobprofiles = project_params[:jobprofile_list].split(', ')
      numberofcrits = params[:numberofcrits].to_i
      index = 1

      while index <= numberofcrits
        @project.criterionparams[index-1].filterlow = params[variablenamelow(index)]
        @project.criterionparams[index-1].filterhigh = params[variablenamehigh(index)]
        @project.criterionparams[index-1].save
        index += 1
      end
      index = 1
      while index <= numberofcrits
        index += 1
      end
      @project.employees.delete_all
      fulfilled = 0
      Employee.all.each do |employee|
        @project.criterionparams.each do |criterionparam|
          if !employee.criterionvalues.find_by(criterion_id: criterionparam.criterion.id).nil?
            criterionvalue = employee.criterionvalues.find_by(criterion_id: criterionparam.criterion.id).value.to_f
            filterhigh = criterionparam.filterhigh + 0.1
            filterlow = criterionparam.filterlow - 0.1
            if (filterlow <= criterionvalue) && (filterhigh >= criterionvalue)
              fulfilled += 1
            end
          end
        end

        #check additionally if costrate and location is fulfilled (because they are not saved in the criterion values)
        locationid = Criterion.where(name: 'location').first.id
        costrateid = Criterion.where(name: 'costrate').first.id
        if @project.criterionparams.exists?(:criterion_id => locationid) && @project.criterionparams.exists?(:criterion_id => costrateid)
          distance = Location.get_distance(employee.loclat,employee.loclon,@project.loclat,@project.loclon)
          costrate = employee.costrate
          if (Criterionparam.where(criterion_id: locationid).first.filterlow <= distance) && (Criterionparam.where(criterion_id: locationid).first.filterhigh >= distance)
            fulfilled += 1
          end
          if (Criterionparam.where(criterion_id: costrateid).first.filterlow <= costrate) && (Criterionparam.where(criterion_id: costrateid).first.filterhigh >= costrate)
            fulfilled += 1
          end
        end

        #if all criteria are fulfilled && job profile does also match
        if ((numberofcrits == fulfilled) && (jobprofiles.include? employee.jobprofile.name))
          @project.employees << employee
        end
        fulfilled = 0
      end
    end

    if @project.update(project_params)
      redirect_to @project, :notice => 'Project successfully updated'
    else
      render 'edit'
    end
  end

  def show
    @project = Project.find(params[:id])
  end

  def index
    @projects = Project.all
  end

  def destroy
    @project = Project.find(params[:id])
    @project.destroy
    redirect_to projects_path, :notice => 'Project deleted'
  end

  def filter
    @project = Project.find(params[:project_id])
  end

  def updateemployees

  end


  private
  # defines which parameters have to be provided by the form when creating a new project
  def project_params
    params.require(:project).permit(:name, :loclat, :loclon, :startdate, :enddate, :effort, :hourlyrate, {:criterion_ids => []}, {:employee_ids => []}, :jobprofile_list)
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
