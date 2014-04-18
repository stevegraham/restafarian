class Widget < ActiveRecord::Base
  validates :terms, acceptance: true
  validates :favourite_colour, inclusion: { in: %w<red green blue>}

  attr_accessor :cover_photo, :main_image, :chat_avatar, :profile_picture,
                :resume_file, :password, :password_confirmation,
                :telephone_number, :phone_number, :blog_url, :lucky_number,
                :doo_dad
end
