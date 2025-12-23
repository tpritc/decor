module Admin
  class ComputerModelsController < BaseController
    before_action :set_computer_model, only: %i[edit update destroy]

    def index
      @computer_models = ComputerModel.order(:name).includes(:computers)
    end

    def new
      @computer_model = ComputerModel.new
    end

    def create
      @computer_model = ComputerModel.new(computer_model_params)

      if @computer_model.save
        redirect_to admin_computer_models_path, notice: "Computer model was successfully created."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
    end

    def update
      if @computer_model.update(computer_model_params)
        redirect_to admin_computer_models_path, notice: "Computer model was successfully updated."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @computer_model.destroy
      redirect_to admin_computer_models_path, notice: "Computer model was successfully deleted."
    end

    private

    def set_computer_model
      @computer_model = ComputerModel.find(params[:id])
    end

    def computer_model_params
      params.require(:computer_model).permit(:name)
    end
  end
end
