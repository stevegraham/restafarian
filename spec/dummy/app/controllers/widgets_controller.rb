class WidgetsController < Restafarian::Controller
  def show
    respond_with Widget.new
  end
end
