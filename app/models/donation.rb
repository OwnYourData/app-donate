# == Schema Information
#
# Table name: donations
#
#  id         :bigint(8)        not null, primary key
#  container  :string
#  name       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#

class Donation < ApplicationRecord
end
