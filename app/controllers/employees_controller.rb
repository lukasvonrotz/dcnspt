class EmployeesController < ApplicationController

  # Control logic for show-view
  # GET /employees/:id
  def show
    @employee = Employee.find(params[:id])
  end

  # Control logic for index-view
  # GET /employees
  def index
    @employees = Employee.all
  end

  # Control logic for create-view
  # GET /employees/new
  def new
    # build a 'temporary' employee which is written to DB later (create-method)
    @employee = Employee.new
  end

  # Control logic when creating a new employee
  # POST /employees
  def create
    @employee = Employee.new(employee_params)
    # write project to database
    if @employee.save
      redirect_to employees_path, :notice => 'Employee successufully created'
    else
      render 'new'
    end
  end

  # Control logic for edit-view
  # GET /employees/:id/edit
  def edit
    @employee = Employee.find(params[:id])
  end

  # Save an updated employee
  # PUT /employees/:id
  def update
    @employee = Employee.find(params[:id])
    if @employee.update(employee_params)
      redirect_to employees_path, :notice => 'Employee successfully updated'
    else
      render 'edit'
    end
  end

  # Delete an employee
  # DELETE /employees/:id
  def destroy
    @employee = Employee.find(params[:id])
    @employee.destroy
    redirect_to employees_path, :notice => 'Employee deleted'
  end


  private
  # defines which parameters have to be provided by the form when creating a new employee
  def employee_params
    params.require(:employee).permit(:firstname, :surname, :code, :country, :loclat, :loclon,
                                     :costrate, :jobprofile_id, {:criterion_ids => []})
  end

end
