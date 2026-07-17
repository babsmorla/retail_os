class ApplicationController < ActionController::Base
  allow_browser versions: :modern
  stale_when_importmap_changes
  include Pundit::Authorization

  before_action :authenticate_user!
  before_action :set_current_store # This will now populate Current.store_id

  helper_method :current_store

 rescue_from ActiveRecord::RecordNotFound, with: :render_not_found

  def current_store
    @current_store ||= begin
      if session[:store_id].present? && current_user&.stores&.exists?(id: session[:store_id])
        current_user.stores.find(session[:store_id])
      else
        current_user&.stores&.first
      end
    end
  end

  private

  def set_current_store
    # This ensures Current.store_id is populated for the duration of the request
    Current.store_id = current_store&.id
  end

  def render_not_found
    respond_to do |format|
      format.html { render "errors/not_found", layout: "auth", status: :not_found }
      format.json { render json: { error: "Record not found" }, status: :not_found }
      format.all { head :not_found }
    end
  end

  # Pundit error handling...
  # 
  rescue_from Pundit::NotAuthorizedError do
    redirect_back(
      fallback_location: root_path,
      alert: "You are not authorized to perform this action."
    )
  end
end
