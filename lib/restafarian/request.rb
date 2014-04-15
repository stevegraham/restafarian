module Restafarian
  class Request < Struct.new(:request) # :nodoc:
    def acceptable_http_methods
      node = routeset.routes.match(request.path).detect do |node|
        node.value.any? do |r|
          r.path.to_regexp === request.path && r.matches?(request)
        end
      end

      node.value.map { |route| route.verb.source.gsub(/[^\w]/, '') }
    end

    private

    def routeset
      Rails.application.routes
    end
  end
end
