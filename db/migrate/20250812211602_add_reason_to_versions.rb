class AddReasonToVersions < ActiveRecord::Migration[7.2]
  def change
    add_column :versions, :reason, :string
  end
end
