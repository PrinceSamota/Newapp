class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  has_many :availabilities
  belongs_to :organization, foreign_key: 'org_id', optional: true
  devise :database_authenticatable,
         :recoverable, :rememberable, :validatable
         
end
