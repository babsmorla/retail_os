# app/controllers/users/passwords_controller.rb
module Users
  class PasswordsController < Devise::PasswordsController
    layout "auth"
  end
end