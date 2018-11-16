class AddResultToDonations < ActiveRecord::Migration[5.1]
  def change
    add_column :donations, :result, :string
  end
end
