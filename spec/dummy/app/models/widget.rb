class Widget < ActiveRecord::Base
  validates :terms, acceptance: true
end
