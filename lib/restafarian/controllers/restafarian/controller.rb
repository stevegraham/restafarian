module Restafarian
  class Controller < ActionController::Base
    respond_to :restafarian_js, :restafarian_json
    
    self.responder = Restafarian::Responder
  end
end
