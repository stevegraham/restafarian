class Widget < ActiveRecord::Base
  validates :decimal, numericality: { greater_than: 100 }
  validates :integer, numericality: { only_integer: true }
  validates :terms, acceptance: true
  validates :favourite_colour, inclusion: { in: %w<red green blue>}

  attr_accessor :cover_photo, :main_image, :chat_avatar, :profile_picture,
                :resume_file, :password, :password_confirmation,
                :telephone_number, :phone_number, :blog_url, :lucky_number,
                :favourite_colour, :doo_dad

  def as_json(options={})
    super options.merge \
      methods: [:cover_photo, :main_image, :chat_avatar, :profile_picture,
                :resume_file, :password, :password_confirmation,
                :terms, :favourite_colour],
      except: [:id]
  end
end
