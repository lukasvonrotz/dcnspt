class EmployeesController < ApplicationController

  before_filter :authenticate_user!

  def new
    # build a 'temporary' post which is written to DB later (create-method)
    @employee = Employee.new
  end

  def create
    @employee = Employee.new(employee_params)
    # write project to database
    if @employee.save
      redirect_to employees_path, :notice => 'Employee successufully created'
    else
      render 'new'
    end
  end

  def edit
    @employee = Employee.find(params[:id])
  end

  def update
    @employee = Employee.find(params[:id])
    if @employee.update(employee_params)
      redirect_to employees_path, :notice => 'Employee successfully updated'
    else
      render 'edit'
    end
  end

  def show
    @employee = Employee.find(params[:id])
  end

  def index
    @employees = Employee.all
  end

  def destroy
    @employee = Employee.find(params[:id])
    @employee.destroy
    redirect_to employees_path, :notice => 'Employee deleted'
  end


  private
  # defines which parameters have to be provided by the form when creating a new project
  def employee_params
    params.require(:employee).permit(:firstname, :surname, :country, :loclat, :loclon, :costrate, :jobprofile_id)
  end

end
