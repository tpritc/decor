class ComputersController < ApplicationController
  before_action :set_computer, only: %i[show edit update destroy]
  before_action :ensure_computer_belongs_to_current_owner, only: %i[edit update destroy]

  def index
    computers = Computer.includes(:owner, :computer_model, :condition, :run_status)

    if params[:model].present?
      model = ComputerModel.find(params[:model])
      computers = computers.where(computer_model: model)
    end

    if params[:condition_id].present?
      computers = computers.where(condition_id: params[:condition_id])
    end

    if params[:run_status_id].present?
      computers = computers.where(run_status_id: params[:run_status_id])
    end

    computers = case params[:sort]
    when "added_asc" then computers.order(created_at: :asc)
    when "added_desc" then computers.order(created_at: :desc)
    when "model_asc" then computers.joins(:computer_model).order("computer_models.name ASC")
    when "model_desc" then computers.joins(:computer_model).order("computer_models.name DESC")
    else
      computers.order(created_at: :desc)
    end

    paginate computers
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
    params.require(:computer).permit(:computer_model_id, :serial_number, :condition_id, :run_status_id, :description, :history)
  end
end
