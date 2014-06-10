module Restafarian
  class RootController < Controller
    def index
      # raise request.path.inspect
      respond_with _links: child_resources
    end
  end
end
