module Admin
  class BulkUploadsController < BaseController
    def new
    end

    def create
      file = params[:file]

      unless file.present?
        flash[:alert] = "Please select a file to upload"
        return redirect_to new_admin_bulk_upload_path
      end

      result = BulkUploadService.process(file)

      if result[:success]
        flash[:notice] = "Successfully imported #{result[:computer_count]} computers and #{result[:component_count]} components for #{result[:owner_name]}"
        redirect_to admin_owners_path
      else
        flash[:alert] = "Import failed: #{result[:error]}"
        redirect_to new_admin_bulk_upload_path
      end
    end
  end
end
