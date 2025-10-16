class AddPaymentTermsAndSignatoryToClients < ActiveRecord::Migration[7.2]
  def change
    add_column :clients, :payment_terms, :string
    add_column :clients, :signatory, :string
  end
end
