# Controller for managing criterionparams
class CriterionparamsController < ApplicationController

  # Control logic for index-view
  # GET /projects/:project_id/criterionparams
  def index
    if project = Project.find(params[:project_id])
      @criterionparams = project.criterionparams
      @project = project
    else
      @criterionparams = Criterionparam.all
    end
  end

  # Control logic for edit-view
  # GET /projects/:project_id/criterionparams/:id/edit
  def edit
    @criterionparam = Criterionparam.find(params[:id])
  end

  # Save an updated criterionparam
  # PUT /projects/:project_id/criterionparams
  def update
    @criterionparam = Criterionparam.find(params[:id])
    if @criterionparam.update(criterionparam_params)
      redirect_to project_criterionparams_path, :notice => 'Criterion Parameters successfully updated'
    else
      render 'edit'
    end
  end

  # Control logic for show-view
  # GET /projects/:project_id/criterionparams/:id
  def show
    @criterionparam = Criterionparam.find(params[:id])
  end


  private
  # defines which parameters have to be provided by the form when creating a new criterionparam
  def criterionparam_params
    params.require(:criterionparam).permit(:weight,:direction,:prefthresslo,:prefthresint,
                                           :inthresslo,:inthresint,:vetothresslo,:vetothresint,:filterlow,:filterhigh)
  end
end
