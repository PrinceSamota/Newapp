class UploadsController < ApplicationController
  before_action :authenticate_user!
  def index
    @decoded_result = nil
    @article_number = nil
    @item_masters = ItemMaster.order(created_at: :desc)
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

    # Extract article numbers and extra fields
    file_path = ActiveStorage::Blob.service.path_for(uploaded_file.file.key)
    extension = File.extname(filename).delete('.').to_sym

    xlsx = Roo::Spreadsheet.open(file_path, extension: extension)
    sheet_name = xlsx.sheets.first
    sheet = xlsx.sheet(sheet_name)

    header = sheet.row(1).map(&:to_s).map(&:strip).map(&:downcase)

    indices = {
      article_no: header.find_index("article no"),
      loop_color:       header.find_index("loop"),
      fuse:       header.find_index("fuse"),
      profile:    header.find_index("profile"),
      status:     header.find_index("status"),
      client:     header.find_index("client"),
      start_serial_no:     header.find_index("start serial no"),
      end_serial_no:     header.find_index("end serial no"),
      invoice_no:     header.find_index("invoice no."),
      fuse:     header.find_index("fuse"),
      sku_no:     header.find_index("sku number"),
    }

    if indices[:article_no]
      sheet.each_row_streaming(offset: 1) do |row|
        article_no = row[indices[:article_no]]&.value
        next if article_no.blank?

        order.items.create!(
          name: sheet_name,
          article_no: article_no,
          loop_color: row[indices[:loop_color]]&.value,
          fuse: row[indices[:fuse]]&.value,
          profile: row[indices[:profile]]&.value,
          status: row[indices[:status]]&.value,
          client: row[indices[:client]]&.value,
          start_serial_no: row[indices[:start_serial_no]]&.value,
          end_serial_no: row[indices[:end_serial_no]]&.value,
          invoice_no: row[indices[:invoice_no]]&.value,
          fuse: row[indices[:fuse]]&.value,
          sku_no: row[indices[:sku_no]]&.value,
        )
      end
    end

    redirect_to order_path(order)
  end
end
