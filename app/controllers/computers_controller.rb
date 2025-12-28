class ComputersController < ApplicationController
  before_action :set_computer, only: %i[show edit update destroy]
  before_action :ensure_computer_belongs_to_current_owner, only: %i[edit update destroy]

  def index
    paginate Computer.includes(:owner, :computer_model).order(created_at: :desc)
  end

  def show
    @components = @computer.components.includes(:component_type)
  end

  def new
    @computer = Current.owner.computers.build
  end

  def create
    @computer = Current.owner.computers.build(computer_params)

    if @computer.save
      redirect_to computer_path(@computer), notice: "Computer was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @computer.update(computer_params)
      redirect_to computer_path(@computer), notice: "Computer was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @computer.destroy
    redirect_to computers_path, notice: "Computer was successfully deleted."
  end

  private

  def set_computer
    @computer = Computer.find(params[:id])
  end

  def ensure_computer_belongs_to_current_owner
    require_owner(@computer.owner)
  end

  def computer_params
    params.require(:computer).permit(:computer_model_id, :serial_number, :condition, :run_status, :description, :history)
  end
end
