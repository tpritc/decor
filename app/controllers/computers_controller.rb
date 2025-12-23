class ComputersController < ApplicationController
  def index
    @computers = Computer.includes(:owner, :computer_model).order(created_at: :desc)
  end
end
