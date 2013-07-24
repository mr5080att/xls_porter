require "xls_porter/xls_uploader"

module XlsPorter

  def to_xls(list, columns, name)
    book = Spreadsheet::Workbook.new
    sheet = book.create_worksheet :name => name
    row = sheet.row(0)
    columns.each {|column| row.push(column)}
    idx = 0
    list.each do |it|
      row = sheet.row(idx += 1)
      columns.each {|column| row.push(it[column])}
    end
    return book
  end

  def model_to_xls(model)
    to_xls(model.all, model.column_names, model.name)
  end

  # sanitize and prefix filename with timestamp
  # store the uploaded file
  def store_uploaded_file(uploaded_file)
    uploaded_file.original_filename = "#{Time.now.to_i}_#{File.basename(uploaded_file.original_filename)}"
    file = XlsUploader.new
    file.store!(uploaded_file)
    return file
  end

  def xls_to_model(xls_file_path, model, ignore=[])
    #TODO exception handling

    book = Spreadsheet.open(xls_file_path)
    sheet = book.worksheet(0)
    columns = sheet.row(0)
    ignore_columns = (columns - model.column_names) + ignore
    id_idx = columns.find_index("id")
    updates = []
    # Read each row, skip the first (column names)
    sheet.each 1 do |row|
      id = row[id_idx]
      record = nil
      update = nil
      update_notes = nil
      if id.nil?
        record = model.new
        update = "new"
      else
        begin
          record = model.find(id)
          update = "exist"
        rescue
          record = model.new
          update = "new"
        end
      end
      (0..(columns.size - 1)).each do |i|
        column = columns[i]
        value = row[i]
        puts "Column: #{column} Value: #{value.inspect}"
        value = value.strip if value.is_a?(String)
        value = value.value if value.is_a?(Spreadsheet::Formula)
        if column == "id" and update == "new"
          record[column] = value
        elsif ignore_columns.include?(column)
          #skip if column is ignored
        elsif record[column].blank? and value.blank?
          #skip if both are either nil or empty
        elsif [DateTime, Time, Date].include?(value.class)
          record[column] = value if record[column].to_f != value.to_f
        else
          puts "Column: #{column} Record: #{record[column].to_s} Value: #{value.to_s}"
          if record[column] != value
            record[column] = value
            update = "updated" if update == "exist"
            update_notes = [] if update_notes.nil?
            update_notes << column
          end
        end
      end
      puts "Record ID:#{record.id} new? #{record.new_record?} persisted? #{record.persisted?}"
      puts "Record changed? #{not record.changed.empty?}"
      #track all updates
      if not record.changed.empty?
        begin
          puts "Trying to save record..."
          if record.save
            puts "Record #{record.class}:#{record.id} saved #{record.persisted?}"
          else
            puts "Record Error #{record.errors.messages.inspect}"
          end
        rescue Exception => exception
          update = "exception"
          update_notes = exception.to_s
          puts "Exception: #{exception.message}"
        end
        updates << record.attributes.merge({ 'update' => update, 'update_notes' => update_notes }) # if %w(new updated).include?(update) #not record.changed.empty?
      end
    end
    return {:columns => (%w(update update_notes) + columns), :updates => updates, :model => model.name}
  end

  def cleanup_tmp_file(file_path)
    File.delete(file_path) if File.exist?(file_path)
  end

  def xls_upload_and_update_model(uploaded_file, model)
    file_path = store_uploaded_file(uploaded_file).store_path
    model_updates = xls_to_model(file_path, model)
    cleanup_tmp_file(file_path)
    return model_updates
  end

end
