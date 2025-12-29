class ComponentsController < ApplicationController
  before_action :set_component, only: %i[show edit update destroy]
  before_action :ensure_component_belongs_to_current_owner, only: %i[edit update destroy]

  def index
    components = Component.includes(:owner, :component_type, :computer)

    if params[:component_type].present?
      component_type = ComponentType.find(params[:component_type])
      components = components.where(component_type: component_type)
    end

    if params[:computer_model].present?
      if params[:computer_model] == "unassigned"
        components = components.where(computer_id: nil)
      else
        computer_model = ComputerModel.find(params[:computer_model])
        components = components.joins(computer: :computer_model).where(computer_models: { id: computer_model.id })
      end
    end

    computers = case params[:sort]
    when "added_asc" then components.order(created_at: :asc)
    when "added_desc" then components.order(created_at: :desc)
    else
      components.order(created_at: :desc)
    end

    paginate computers
  end

  def show
  end

  def new
    @component = Current.owner.components.new(computer_id: params[:computer_id])
  end

  def create
    @component = Current.owner.components.build(component_params)

    if @component.save
      if params[:add_another]
        redirect_to new_component_path(computer_id: @component.computer_id), notice: "Component was successfully created. Add another!"
      else
        redirect_to component_path(@component), notice: "Component was successfully created."
      end
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