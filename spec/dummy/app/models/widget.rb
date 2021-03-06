class Widget < ActiveRecord::Base
  validates :decimal, numericality: { greater_than: 100 }
  validates :integer, numericality: { only_integer: true }
  validates :terms, acceptance: true
  validates :favourite_colour, inclusion: { in: %w<red green blue>}
  validates :password, presence: true, length: { minimum: 8, maximum: 32 }, confirmation: true
  validates :doo_dad,  absence: true
  validates :username, exclusion: { in: ['admin', 'root'] }
  validates :email, format: { with: /\w+@\w+.com/ }

  attr_accessor :cover_photo, :main_image, :chat_avatar, :profile_picture,
                :resume_file, :password, :password_confirmation,
                :telephone_number, :phone_number, :lucky_number,
                :favourite_colour, :doo_dad, :username, :email

  def as_json(options={})
    super options.merge \
      methods: [:cover_photo, :main_image, :chat_avatar, :profile_picture,
                :resume_file, :password, :password_confirmation,
                :terms, :favourite_colour, :doo_dad, :username, :email],
      except: [:id]
  end
end
