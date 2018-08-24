class CreateDonationRecords < ActiveRecord::Migration[5.1]
  def change
    create_table :donation_records do |t|
      t.integer :donation_id
      t.string :key_id
      t.text :submission
      t.integer :privacy
      t.string :email
      t.boolean :diffpriv
      t.string :recepient
      t.string :purpose
      t.string :processing
      t.boolean :min_participants
      t.integer :min_participants_number
      t.string :storage_location
      t.string :storage_duration

      t.timestamps
    end
  end
end
