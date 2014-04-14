module Restafarian
  class RootController < ::ApplicationController
    def index
      # raise request.path.inspect
      render json: { child_resources: child_resources },
             content_type: 'application/vnd.restafarian.resource+json; version=1'
    end
  end
end
