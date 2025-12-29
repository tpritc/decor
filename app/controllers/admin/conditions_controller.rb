module Admin
  class ConditionsController < BaseController
    before_action :set_condition, only: %i[edit update destroy]

    def index
      @conditions = Condition.order(:name).includes(:computers)
    end

    def new
      @condition = Condition.new
    end

    def create
      @condition = Condition.new(condition_params)

      if @condition.save
        redirect_to admin_conditions_path, notice: "Condition was successfully created."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
    end

    def update
      if @condition.update(condition_params)
        redirect_to admin_conditions_path, notice: "Condition was successfully updated."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @condition.destroy
      redirect_to admin_conditions_path, notice: "Condition was successfully deleted."
    end

    private

    def set_condition
      @condition = Condition.find(params[:id])
    end

    def condition_params
      params.require(:condition).permit(:name)
    end
  end
end
