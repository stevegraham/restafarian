FactoryGirl.define do
  factory :widget do
    decimal  10
    float    3.14
    integer  42
    datetime Time.zone.now.to_s(:db)
  end
end
