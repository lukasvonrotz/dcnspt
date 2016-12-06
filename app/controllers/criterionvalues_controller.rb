class CriterionvaluesController < ApplicationController
  def index
    if employee = Employee.find(params[:employee_id])
      @criterionvalues = employee.criterionvalues
      @employee = employee
    else
      @criterionvalues= Criterionvalue.all
    end
  end

  def edit
    @criterionvalue = Criterionvalue.find(params[:id])
  end

  def update
    @criterionvalue = Criterionvalue.find(params[:id])
    if @criterionvalue.update(criterionvalue_params)
      redirect_to employee_criterionvalues_path, :notice => 'Criterion Values successfully updated'
    else
      render 'edit'
    end
  end

  def show
    @criterionvalue = Criterionvalue.find(params[:id])
  end

  private
  # defines which parameters have to be provided by the form when creating a new project
  def criterionvalue_params
    params.require(:criterionvalue).permit(:value)
  end
end
