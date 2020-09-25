# == Schema Information
#
# Table name: users
#
#  id              :bigint           not null, primary key
#  name            :string
#  balance         :decimal(15, 2)
#  created_at      :datetime         not null
#  updated_at      :datetime         not null
#  password_digest :string           not null
#
class User < ApplicationRecord
  has_secure_password

  has_one_attached :avatar
end
