# Controller for managing users (see also classes of devise gem)
class UsersController < ApplicationController

  # Control logic for index-view
  # GET /users
  def index
    @users = User.all
  end

  # Control logic for show-view
  # GET /users/:id
  def show
    @user = User.find(params[:id])
  end

end
