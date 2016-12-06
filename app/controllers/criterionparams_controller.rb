class CriterionparamsController < ApplicationController
  def index
    if project = Project.find(params[:project_id])
      @criterionparams = project.criterionparams
      @project = project
    else
      @criterionparams = Criterionparam.all
    end
  end

  def edit
    @criterionparam = Criterionparam.find(params[:id])
  end

  def update
    @criterionparam = Criterionparam.find(params[:id])
    if @criterionparam.update(criterionparam_params)
      redirect_to project_criterionparams_path, :notice => 'Criterion Parameters successfully updated'
    else
      render 'edit'
    end
  end

  def show
    @criterionparam = Criterionparam.find(params[:id])
  end

  private
  # defines which parameters have to be provided by the form when creating a new project
  def criterionparam_params
    params.require(:criterionparam).permit(:weight,:preferencethreshold,:indifferencethreshold,:vetothreshold)
  end
end
