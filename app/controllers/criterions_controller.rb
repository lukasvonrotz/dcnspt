# Controller for managing criterions
class CriterionsController < ApplicationController

  # Control logic for index-view
  # GET /criterions
  def index
    @criterions = Criterion.all
  end

  # Control logic for show-view
  # GET /criterions/:id
  def show
    @criterion = Criterion.find(params[:id])
  end

  # Control logic for create-view
  # GET /criterions/new
  def new
    # build a 'temporary' post which is written to DB later (create-method)
    @criterion = Criterion.new
  end

  # Control logic when creating a new criterion
  # POST /criterions
  def create
    @criterion = Criterion.new(criterion_params)
    @criterioncontext = Criterioncontext.find(criterion_params[:criterioncontext_id])
    @criterion.criterioncontext = @criterioncontext
    # write project to database
    if @criterion.save
      redirect_to criterions_path, :notice => 'Criterion successufully created'
    else
      render 'new'
    end
  end

  # Control logic for edit-view
  # GET /criterions/:id/edit
  def edit
    @criterion = Criterion.find(params[:id])
  end

  # Save an updated criterion
  # PUT /criterions/:id
  def update
    @criterion = Criterion.find(params[:id])
    if @criterion.update(criterion_params)
      redirect_to criterions_path, :notice => 'Criterion successfully updated'
    else
      render 'edit'
    end
  end

  # Delete a criterion
  # DELETE /criterions/:id
  def destroy
    @criterion = Criterion.find(params[:id])
    @criterion.destroy
    redirect_to criterions_path, :notice => 'Criterion deleted'
  end

  private
  # defines which parameters have to be provided by the form when creating a new project
  def criterion_params
    params.require(:criterion).permit(:name,:criterioncontext_id)
  end
end
