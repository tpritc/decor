# frozen_string_literal: true

module Pagination
  extend ActiveSupport::Concern

  def paginate(scope, **options)
    set_page_and_extract_portion_from(scope, **options)

    request.format = :html if @page.number == 1
    respond_to do |format|
      format.turbo_stream
      format.html
    end
  end
end
