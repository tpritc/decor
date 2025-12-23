module Admin
  class ComponentTypesController < BaseController
    before_action :set_component_type, only: %i[edit update destroy]

    def index
      @component_types = ComponentType.order(:name).includes(:components)
    end

    def new
      @component_type = ComponentType.new
    end

    def create
      @component_type = ComponentType.new(component_type_params)

      if @component_type.save
        redirect_to admin_component_types_path, notice: "Component type was successfully created."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
    end

    def update
      if @component_type.update(component_type_params)
        redirect_to admin_component_types_path, notice: "Component type was successfully updated."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @component_type.destroy
      redirect_to admin_component_types_path, notice: "Component type was successfully deleted."
    end

    private

    def set_component_type
      @component_type = ComponentType.find(params[:id])
    end

    def component_type_params
      params.require(:component_type).permit(:name)
    end
  end
end
