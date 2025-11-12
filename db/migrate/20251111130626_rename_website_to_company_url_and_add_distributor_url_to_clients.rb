class RenameWebsiteToCompanyUrlAndAddDistributorUrlToClients < ActiveRecord::Migration[7.2]
  def change
    rename_column :clients, :website, :company_url
    add_column :clients, :distributor_url, :string
  end
end
