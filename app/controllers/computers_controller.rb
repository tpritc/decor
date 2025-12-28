class ComputersController < ApplicationController
  def index
    sleep 1
    paginate Computer.includes(:owner, :computer_model).order(created_at: :desc)
  end
end
