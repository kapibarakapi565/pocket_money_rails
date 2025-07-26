class ApplicationController < ActionController::Base
  # 基本認証を全てのコントローラーに適用
  http_basic_authenticate_with name: Rails.application.credentials.basic_auth_username || ENV['BASIC_AUTH_USERNAME'] || 'admin',
                               password: Rails.application.credentials.basic_auth_password || ENV['BASIC_AUTH_PASSWORD'] || 'password'
end
