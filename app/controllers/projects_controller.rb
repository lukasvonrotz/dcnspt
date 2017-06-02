# Controller for managing projects
class ProjectsController < ApplicationController

  # Include the methods from the projects_helper class
  include ProjectsHelper

  # Control logic for index-view
  # GET /projects
  def index
    @projects = Project.all
  end

  # Control logic for show-view
  # GET /projects/:id
  def show
    @project = Project.find(params[:id])
  end

  # Control logic for create-view
  # GET /projects/new
  def new
    # build a 'temporary' post which is written to DB later (create-method)
    @project = Project.new
  end

  # Control logic when creating a new project
  # POST /projects
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

  # Control logic for edit-view
  # GET /projects/:id/edit
  def edit
    @project = Project.find(params[:id])
  end

  # Save an updated project
  # This method is either called from the project edit-view (GET /projects/:id/edit)
  # or the project filter-view (GET /projects/:id/filter)
  # PUT /projects/:id
  def update
    if params[:id]
      # call comes from edit-view
      @project = Project.find(params[:id])
    else
      # call comes from filter-view
      @project = Project.find(params[:project_id])
    end

    # if update method is called from filter page (then the numberofcrits parameter is set)
    if !params[:numberofcrits].nil?
      jobprofiles = project_params[:jobprofile_list].split(', ')
      numberofcrits = params[:numberofcrits].to_i
      branch = params[:branch]

      # save filter-low and filter-high values
      saveFilterValues(numberofcrits)

      # remove all connected employees that are connected to the project
      @project.employees.delete_all

      fulfilled = 0
      containsLocation = false
      containsCostrate = false
      Employee.all.each do |employee|
        # check if criterionvalue of employee is fulfilled (within range of filter)
        @project.criterionparams.each do |criterionparam|
          # handle location anc costrate seperately, see next block
          if criterionparam.criterion.name == 'location'
            containsLocation = true
          elsif criterionparam.criterion.name == 'costrate'
            containsCostrate = true
          end
          #check all criteria except costrate and location (will be checked later)
          if criterionparam.criterion.name != 'location' && criterionparam.criterion.name != 'costrate'
            #does this employee have a assigned value to this criterion?
            if !employee.criterionvalues.find_by(criterion_id: criterionparam.criterion.id).nil?
              criterionvalue = employee.criterionvalues.find_by(criterion_id: criterionparam.criterion.id).value.to_f
              filterhigh = criterionparam.filterhigh + 0.1
              filterlow = criterionparam.filterlow - 0.1
              if (filterlow <= criterionvalue) && (filterhigh >= criterionvalue)
                fulfilled += 1
              end
            else
              # if filter value is set to 0, then take this employee into account nevertheless!
              filterlow = criterionparam.filterlow - 0.1
              if filterlow <= 0
                fulfilled +=1
              end
            end
          end
        end

        #check additionally if costrate and location is fulfilled (because they are not saved in the criterion values)

        # if location is a criterion of the project, check whether the distance to customer of the employee is within the range
        if containsLocation
          locationid = Criterion.where(name: 'location').first.id
          costrateid = Criterion.where(name: 'costrate').first.id
          distance = Location.get_distance(employee.loclat,employee.loclon,@project.loclat,@project.loclon)
          if employee.costrate
            costrate = employee.costrate
          else
            costrate = 0
          end

          if (Criterionparam.where(criterion_id: locationid).first.filterlow <= distance) && (Criterionparam.where(criterion_id: locationid).first.filterhigh >= distance)
            fulfilled += 1
          end
        end

        # if costrate is a criterion of the project, check whether the costrate of the employee is within the range
        if containsCostrate
          if (Criterionparam.where(criterion_id: costrateid).first.filterlow <= costrate) && (Criterionparam.where(criterion_id: costrateid).first.filterhigh >= costrate)
            fulfilled += 1
          end
        end

        #if all criteria are fulfilled && job profile does also match
        if (employee.jobprofile && (numberofcrits == fulfilled) && (jobprofiles.include? employee.jobprofile.name))
          # if there was selected one or several branches in the filter, only add employees who work at that branch
          # IMPORTANT: The branch filter is not included in the database! only implemented for evalution purposes
          if !branch
            @project.employees << employee
          else
            if employee.location && branch.to_s.include?(employee.location.to_s)
              @project.employees << employee
            end
          end
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

  # Delete a project
  # DELETE /projects/:id
  def destroy
    @project = Project.find(params[:id])
    @project.destroy
    redirect_to projects_path, :notice => 'Project deleted'
  end

  # Control logic for filter-employees view
  # GET /projects/:project_id/filter
  def filter
    @project = Project.find(params[:project_id])
  end


  private
  # defines which parameters have to be provided by the form when creating a new project
  def project_params
    params.require(:project).permit(:name, :loclat, :loclon, :startdate, :enddate, :effort, :hourlyrate, {:criterion_ids => []}, {:employee_ids => []}, :jobprofile_list)
  end

end
