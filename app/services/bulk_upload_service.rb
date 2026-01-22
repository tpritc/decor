class BulkUploadService
  VALID_CSV_HEADERS = %w[owner_name email serial_number computer_model condition run_status description component_type history].freeze
  MAX_FILE_SIZE = 10.megabytes
  BATCH_SIZE = 100

  attr_reader :file, :errors

  def initialize(file)
    @file = file
    @errors = []
    @row_number = 0
    @computer_count = 0
    @component_count = 0
    @owner_name = nil
  end

  def self.process(file)
    new(file).process
  end

  def process
    validate_file!
    return error_result if errors.any?

    begin
      ActiveRecord::Base.transaction do
        process_csv
        raise ActiveRecord::Rollback if errors.any?
      end
      
      return error_result if errors.any?

      {
        success: true,
        owner_name: @owner_name,
        computer_count: @computer_count,
        component_count: @component_count
      }
    rescue => e
      { success: false, error: "Error processing CSV: #{e.message}" }
    end
  end

  private

  def validate_file!
    if file.nil?
      errors << "No file provided"
      return
    end

    if file.size > MAX_FILE_SIZE
      errors << "File size exceeds #{MAX_FILE_SIZE / 1.megabyte}MB limit"
      return
    end

    unless file.content_type == "text/csv" || file.original_filename.end_with?(".csv")
      errors << "File must be a CSV file"
      return
    end
  end

  def process_csv
    csv_data = CSV.read(file.path, headers: true)
    
    validate_headers!(csv_data.headers)
    return if errors.any?

    csv_data.each_with_index do |row, index|
      @row_number = index + 2  # +2 because headers are row 1
      process_row(row)
    end
  end

  def validate_headers!(headers)
    return if headers.blank?

    invalid_headers = headers.reject { |h| VALID_CSV_HEADERS.include?(h.to_s.downcase) }
    if invalid_headers.any?
      errors << "Invalid CSV headers: #{invalid_headers.join(', ')}. Expected headers: #{VALID_CSV_HEADERS.join(', ')}"
    end
  end

  def process_row(row)
    owner_name = row["owner_name"]&.strip
    serial_number = row["serial_number"]&.strip
    computer_model = row["computer_model"]&.strip
    condition = row["condition"]&.strip
    run_status = row["run_status"]&.strip
    description = row["description"]&.strip
    component_type = row["component_type"]&.strip
    history = row["history"]&.strip

    # Skip empty rows
    if [owner_name, serial_number, description].all?(&:blank?)
      return
    end

    # Validate required fields
    if owner_name.blank?
      errors << "Row #{@row_number}: owner_name is required"
      return
    end

    @owner_name = owner_name

    # Find or create owner
    begin
      owner = find_or_create_owner(owner_name, row["email"]&.strip)
    rescue => e
      errors << "Row #{@row_number}: Failed to create/find owner: #{e.message}"
      return
    end

    # Process computer if provided
    if serial_number.present? && computer_model.present?
      process_computer(owner, serial_number, computer_model, condition, run_status)
    end

    # Process component if provided
    if description.present? && component_type.present?
      process_component(owner, description, component_type, serial_number, history, condition)
    end
  end

  def find_or_create_owner(user_name, email)
    owner = Owner.find_by(user_name: user_name)
    
    return owner if owner.present?

    Owner.create!(
      user_name: user_name,
      email: email.blank? ? "#{user_name}@decor.local" : email,
      password: SecureRandom.alphanumeric(16)
    )
  end

  def process_computer(owner, serial_number, computer_model_name, condition_name, run_status_name)
    # Check if computer already exists for this owner
    computer = owner.computers.find_by(serial_number: serial_number)
    return if computer.present?

    # Validate that computer_model exists
    computer_model_record = ComputerModel.find_by(name: computer_model_name)
    if computer_model_record.nil?
      errors << "Row #{@row_number}: Computer model '#{computer_model_name}' does not exist. Please create it first."
      return
    end

    # Validate that condition exists (if provided)
    condition_record = nil
    if condition_name.present?
      condition_record = Condition.find_by(name: condition_name)
      if condition_record.nil?
        errors << "Row #{@row_number}: Condition '#{condition_name}' does not exist. Please create it first."
        return
      end
    end

    # Validate that run_status exists (if provided)
    run_status_record = nil
    if run_status_name.present?
      run_status_record = RunStatus.find_by(name: run_status_name)
      if run_status_record.nil?
        errors << "Row #{@row_number}: Run status '#{run_status_name}' does not exist. Please create it first."
        return
      end
    end

    computer = owner.computers.build(
      serial_number: serial_number,
      computer_model: computer_model_record,
      condition: condition_record,
      run_status: run_status_record
    )

    if computer.save
      @computer_count += 1
    else
      errors << "Row #{@row_number}: Failed to create computer with serial '#{serial_number}': #{computer.errors.full_messages.join(', ')}"
    end
  end

  def process_component(owner, description, component_type_name, serial_number, history, condition_name)
    # Validate that component_type exists
    component_type_record = ComponentType.find_by(name: component_type_name)
    if component_type_record.nil?
      errors << "Row #{@row_number}: Component type '#{component_type_name}' does not exist. Please create it first."
      return
    end

    # Validate that condition exists (if provided)
    condition_record = nil
    if condition_name.present?
      condition_record = Condition.find_by(name: condition_name)
      if condition_record.nil?
        errors << "Row #{@row_number}: Condition '#{condition_name}' does not exist. Please create it first."
        return
      end
    end

    # Try to associate with computer if available
    computer = nil
    if serial_number.present?
      computer = owner.computers.find_by(serial_number: serial_number)
    end

    component = owner.components.build(
      description: description,
      component_type: component_type_record,
      computer: computer,
      history: history,
      condition: condition_record
    )

    if component.save
      @component_count += 1
    else
      errors << "Row #{@row_number}: Failed to create component '#{description}': #{component.errors.full_messages.join(', ')}"
    end
  end

  def error_result
    {
      success: false,
      error: errors.length == 1 ? errors.first : "Import failed with #{errors.length} error(s). First few: #{errors.take(3).join('; ')}"
    }
  end
end
