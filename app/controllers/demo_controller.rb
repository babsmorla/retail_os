class DemoController < ApplicationController
    skip_before_action :authenticate_user!, only: [:index]
skip_before_action :set_current_store, raise: false
  def index
  end
end
