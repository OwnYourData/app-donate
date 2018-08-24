class AddSignatureToDonationRecords < ActiveRecord::Migration[5.1]
  def change
    add_column :donation_records, :signature, :text
    rename_column :donation_records, :recepient, :recipient
  end
end
