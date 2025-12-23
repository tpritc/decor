class ComponentsController < ApplicationController
  def index
    @components = Component.includes(:owner, :component_type, :computer).order(created_at: :desc)
  end
end
