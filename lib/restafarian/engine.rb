module Restafarian
  class Engine < Rails::Engine
    paths["app/controllers"] << "lib/restafarian/controllers"
  end
end
