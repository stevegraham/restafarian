class Widget < ActiveRecord::Base
  validates :terms, acceptance: true
  validates :favourite_colour, inclusion: { in: %w<red green blue>}
end
