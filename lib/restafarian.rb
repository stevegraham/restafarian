require 'uncle'
require 'restafarian/engine'
require 'restafarian/request'
require 'restafarian/type_hinter'
require 'restafarian/responder'
require 'restafarian/javascript_renderer'

module Restafarian

end

ActionDispatch::Routing::Mapper.class_eval do
  def restafarian_routes
    root 'restafarian/root#index'
  end
end

Mime::Type.register \
  'application/vnd.restafarian.resource+json', :restafarian_json

Mime::Type.register \
  'application/vnd.restafarian.resource+js', :restafarian_js

ActionController::Renderers.add(:restafarian_json) do |object, options|
  self.content_type ||= Mime::RESTAFARIAN_JSON
  object.kind_of?(String) ? object : object.to_json(options)
end

ActionController::Renderers.add(:restafarian_js) do |object, options|
  self.content_type ||= Mime::RESTAFARIAN_JS
  Restafarian::JavascriptRenderer.new(object).render
end
