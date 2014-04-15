class SingletonsController < ApplicationController
  def show
    restafarian_request = Restafarian::Request.new(request)
    response.headers['Allow'] = restafarian_request.acceptable_http_methods.join(', ')
    head :ok
  end
end
