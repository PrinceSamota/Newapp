WickedPdf.config = {
  exe_path: Rails.env.production? ? '/usr/bin/wkhtmltopdf' : '/usr/bin/wkhtmltopdf',
  enable_local_file_access: true,
  disable_smart_shrinking: true
}
