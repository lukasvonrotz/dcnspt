class CriterionsController < ApplicationController

  before_filter :authenticate_user!

  def new
    # build a 'temporary' post which is written to DB later (create-method)
    @criterion = Criterion.new
  end

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

  def edit
    @criterion = Criterion.find(params[:id])
  end

  def update
    @criterion = Criterion.find(params[:id])
    if @criterion.update(criterion_params)
      redirect_to criterions_path, :notice => 'Criterion successfully updated'
    else
      render 'edit'
    end
  end

  def show
    @criterion = Criterion.find(params[:id])
  end

  def index
    @criterions = Criterion.all
  end

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
