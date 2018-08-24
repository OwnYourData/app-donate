# == Schema Information
#
# Table name: donation_records
#
#  id                      :bigint(8)        not null, primary key
#  diffpriv                :boolean
#  email                   :string
#  min_participants        :boolean
#  min_participants_number :integer
#  privacy                 :integer
#  processing              :string
#  purpose                 :string
#  recipient               :string
#  signature               :text
#  storage_duration        :string
#  storage_location        :string
#  submission              :text
#  created_at              :datetime         not null
#  updated_at              :datetime         not null
#  donation_id             :integer
#  key_id                  :string
#

class DonationRecord < ApplicationRecord
end
