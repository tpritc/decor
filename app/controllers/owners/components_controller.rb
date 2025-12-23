module Owners
  class ComponentsController < ApplicationController
    before_action :set_owner
    before_action :set_component, only: %i[show edit update destroy]
    before_action -> { require_owner(@owner) }, only: %i[new create edit update destroy]

    def index
      @components = @owner.components.includes(:component_type, :computer)
    end

    def show
    end

    def new
      @component = @owner.components.build(computer_id: params[:computer_id])
    end

    def create
      @component = @owner.components.build(component_params)

      if @component.save
        redirect_to owner_component_path(@owner, @component), notice: "Component was successfully created."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
    end

    def update
      if @component.update(component_params)
        redirect_to owner_component_path(@owner, @component), notice: "Component was successfully updated."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @component.destroy
      redirect_to owner_components_path(@owner), notice: "Component was successfully deleted."
    end

    private

    def set_owner
      @owner = Owner.find(params[:owner_id])
    end

    def set_component
      @component = @owner.components.find(params[:id])
    end

    def component_params
      params.require(:component).permit(:component_type_id, :computer_id, :description)
    end
  end
end
