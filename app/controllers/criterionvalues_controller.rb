# Controller for managing criterionvalues
class CriterionvaluesController < ApplicationController

  # Control logic for index-view
  # GET /employees/:employee_id/criterionvalues
  def index
    if employee = Employee.find(params[:employee_id])
      # load criterionvalues of a specific employee
      @criterionvalues = employee.criterionvalues
      @employee = employee
    else
      # load all criterionvalues
      @criterionvalues = Criterionvalue.all
    end
  end

  # Control logic for show-view
  # GET /employees/:employee_id/criterionvalues/:id
  def show
    @criterionvalue = Criterionvalue.find(params[:id])
  end

  # Control logic for edit-view
  # GET /employees/:employee_id/criterionvalues/:id/edit
  def edit
    @criterionvalue = Criterionvalue.find(params[:id])
  end

  # Save an updated criterion
  # PUT /employees/:employee_id/criterionvalues/:id
  def update
    @criterionvalue = Criterionvalue.find(params[:id])
    if @criterionvalue.update(criterionvalue_params)
      redirect_to employee_criterionvalues_path, :notice => 'Criterion Values successfully updated'
    else
      render 'edit'
    end
  end

  private
  # defines which parameters have to be provided by the form when creating a new criterionvalue
  def criterionvalue_params
    params.require(:criterionvalue).permit(:value)
  end
end
