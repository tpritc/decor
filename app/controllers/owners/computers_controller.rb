module Owners
  class ComputersController < ApplicationController
    before_action :set_owner
    before_action :set_computer, only: %i[show edit update destroy]
    before_action -> { require_owner(@owner) }, only: %i[new create edit update destroy]

    def index
      @computers = @owner.computers.includes(:computer_model)
    end

    def show
      @components = @computer.components.includes(:component_type)
    end

    def new
      @computer = @owner.computers.build
    end

    def create
      @computer = @owner.computers.build(computer_params)

      if @computer.save
        redirect_to owner_computer_path(@owner, @computer), notice: "Computer was successfully created."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
    end

    def update
      if @computer.update(computer_params)
        redirect_to owner_computer_path(@owner, @computer), notice: "Computer was successfully updated."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @computer.destroy
      redirect_to owner_computers_path(@owner), notice: "Computer was successfully deleted."
    end

    private

    def set_owner
      @owner = Owner.find(params[:owner_id])
    end

    def set_computer
      @computer = @owner.computers.find(params[:id])
    end

    def computer_params
      params.require(:computer).permit(:computer_model_id, :serial_number, :condition, :run_status, :description, :history)
    end
  end
end
