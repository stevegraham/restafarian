module Restafarian
  class Responder < ActionController::Responder
    def to_restafarian_js
      request = Restafarian::Request.new(controller.request)
      controller.response.headers['Allow'] = request.acceptable_http_methods.join(', ')

      controller.render restafarian_js: resource
    end

    def to_restafarian_json
      controller.render restafarian_json: resource
    end

  end
end
