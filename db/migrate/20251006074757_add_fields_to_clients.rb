class AddFieldsToClients < ActiveRecord::Migration[7.2]
  def change
    add_column :clients, :company_name, :string
    add_column :clients, :email, :string
    add_column :clients, :contact_no, :string
    add_column :clients, :address1, :string
    add_column :clients, :address2, :string
    add_column :clients, :address3, :string
    add_column :clients, :pin_code, :string
    add_column :clients, :country, :string
    add_column :clients, :eori_no, :string
    add_column :clients, :gst_no, :string
    add_column :clients, :iec_no, :string
    add_column :clients, :lut_bond_no, :string
    add_column :clients, :ad_code, :string
    add_column :clients, :rex_no, :string
    add_column :clients, :rex_date, :date
    add_column :clients, :pan_no, :string
    add_column :clients, :website, :string
    add_column :clients, :port_of_discharge, :string
    add_column :clients, :port_of_loading, :string
    add_column :clients, :shipping_terms, :string
    add_column :clients, :remark, :text
  end
end
