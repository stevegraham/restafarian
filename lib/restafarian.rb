require 'uncle'

module Restafarian
  class Engine < Rails::Engine
    paths["app/controllers"] << "lib/restafarian/controllers"
  end
end

ActionDispatch::Routing::Mapper.class_eval do
  def restafarian_routes
    root 'restafarian/root#index'
  end
end
