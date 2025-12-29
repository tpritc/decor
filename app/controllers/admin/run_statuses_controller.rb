module Admin
  class RunStatusesController < BaseController
    before_action :set_run_status, only: %i[edit update destroy]

    def index
      @run_statuses = RunStatus.order(:name).includes(:computers)
    end

    def new
      @run_status = RunStatus.new
    end

    def create
      @run_status = RunStatus.new(run_status_params)

      if @run_status.save
        redirect_to admin_run_statuses_path, notice: "Run status was successfully created."
      else
        render :new, status: :unprocessable_entity
      end
    end

    def edit
    end

    def update
      if @run_status.update(run_status_params)
        redirect_to admin_run_statuses_path, notice: "Run status was successfully updated."
      else
        render :edit, status: :unprocessable_entity
      end
    end

    def destroy
      @run_status.destroy
      redirect_to admin_run_statuses_path, notice: "Run status was successfully deleted."
    end

    private

    def set_run_status
      @run_status = RunStatus.find(params[:id])
    end

    def run_status_params
      params.require(:run_status).permit(:name)
    end
  end
end
