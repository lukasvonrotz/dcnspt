# Controller for managing projects
class ProjectsController < ApplicationController

  # Include the methods from the projects_helper class
  include ProjectsHelper

  # Control logic for index-view
  # GET /projects
  def index
    @projects = Project.all
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

  # Control logic for show-view
  # GET /projects/:id
  def show
    @project = Project.find(params[:id])
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
      # call comes from filter-view -> since URL is different in filter-view,
      # it has to be defined which ID to read from URL
      @project = Project.find(params[:project_id])
    end

    # if update method is called from filter page (then the numberofcrits parameter is set)
    if !params[:numberofcrits].nil?
      update_filter
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
    params.require(:project).permit(:name, :loclat, :loclon, :startdate, :enddate, :effort, :hourlyrate,
                                    {:criterion_ids => []}, {:employee_ids => []}, :jobprofile_list)
  end

  def update_filter
    jobprofiles = project_params[:jobprofile_list].split(', ')
    numberofcrits = params[:numberofcrits].to_i
    branch = params[:branch]

    # save filter-low and filter-high values
    saveFilterValues(numberofcrits)

    # remove all connected employees that are connected to the project
    @project.employees.delete_all

    # initialize counter (number of fulfilled criteria)
    fulfilled = 0

    # check for each employee whether he fulfills the set filter-values
    Employee.all.each do |employee|
      @project.criterionparams.each do |criterionparam|

        # check if costrate and location is fulfilled
        if criterionparam.criterion.name == 'location'
          fulfilled = check_location(employee, fulfilled)
        elsif criterionparam.criterion.name == 'costrate'
          fulfilled = check_margin(employee, fulfilled)
        end
        #check all criteria except costrate and location
        if criterionparam.criterion.name != 'location' && criterionparam.criterion.name != 'costrate'
          #does this employee have a assigned value to this criterion?
          if !employee.criterionvalues.find_by(criterion_id: criterionparam.criterion.id).nil?
            # increment fulfilled counter if criterionvalue is within filter range
            fulfilled = check_other_criteria(criterionparam, employee, fulfilled)
          else
            # if no value assigned but filter value is set to 0, then take this employee into account nevertheless!
            fulfilled = check_if_filter_zero(criterionparam, fulfilled)
          end
        end
      end

      #if all criteria are fulfilled && job profile does also match
      if (employee.jobprofile && (numberofcrits == fulfilled) && (jobprofiles.include? employee.jobprofile.name))
        # if there was selected one or several branches in the filter, only add employees who work at that branch
        # IMPORTANT: The branch filter is not included in the database! only implemented for evalution purposes
        if !branch
          @project.employees << employee
        else
          if employee.location && branch.to_s.include?(employee.location.to_s) && (employee.location.to_s.length > 0)
            @project.employees << employee
          end
        end
      end
      fulfilled = 0
    end
  end

end
