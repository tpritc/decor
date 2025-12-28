class ComponentsController < ApplicationController
  before_action :set_component, only: %i[show edit update destroy]
  before_action :ensure_component_belongs_to_current_owner, only: %i[edit update destroy]

  def index
    paginate Component.includes(:owner, :component_type, :computer).order(created_at: :desc)
  end

  def show
  end

  def new
    @component = Current.owner.components.new(computer_id: params[:computer_id])
  end

  def create
    @component = Current.owner.components.build(component_params)

    if @component.save
      redirect_to component_path(@component), notice: "Component was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @component.update(component_params)
      redirect_to component_path(@component), notice: "Component was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @component.destroy
    redirect_to components_path, notice: "Component was successfully deleted."
  end

  private

  def set_component
    @component = Component.find(params[:id])
  end

  def ensure_component_belongs_to_current_owner
    require_owner(@component.owner)
  end

  def component_params
    params.require(:component).permit(:component_type_id, :computer_id, :description)
  end
end