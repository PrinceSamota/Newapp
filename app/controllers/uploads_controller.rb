class UploadsController < ApplicationController
  def index
  end

  def create
    uploaded_io = params[:uploaded_file][:file]
    filename = uploaded_io.original_filename
  
    # Save to ActiveStorage
    uploaded_file = UploadedFile.new
    uploaded_file.file.attach(uploaded_io)
    uploaded_file.save!
  
    # Create order with filename
    order = Order.create!(name: filename)
  
    # Extract article numbers
    file_path = ActiveStorage::Blob.service.path_for(uploaded_file.file.key)
    extension = File.extname(filename).delete('.').to_sym
  
    xlsx = Roo::Spreadsheet.open(file_path, extension: extension)
    sheet_name = xlsx.sheets.first
    sheet = xlsx.sheet(sheet_name)
    
    header = sheet.row(1)
    article_no_index = header.find_index { |h| h.to_s.strip.downcase == "article no" }
    
    if article_no_index
      sheet.each_row_streaming(offset: 1) do |row|
        article_no = row[article_no_index]&.value
        next if article_no.blank?
    
        # Create item for each article
        order.items.create!(
          name: sheet_name,      # Table/Sheet name
          article_no: article_no # Actual article number
        )
      end
    end
  
    redirect_to order_path(order)
  end
end
