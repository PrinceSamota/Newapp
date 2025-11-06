class AddDispatchIdAndStatusToInputs < ActiveRecord::Migration[7.2]
  def change
    add_column :inputs, :dispatch_id, :integer
    add_column :inputs, :status, :string
  end
end
