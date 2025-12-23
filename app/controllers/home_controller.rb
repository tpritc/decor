class HomeController < ApplicationController
  def index
    @computer_count = Computer.count
    @component_count = Component.count
    @owner_count = Owner.count
  end
end
