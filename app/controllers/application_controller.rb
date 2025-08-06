class ApplicationController < ActionController::Base
   before_action :basic_auth


  private

  def basic_auth
    authenticate_or_request_with_http_basic do |username, password|
      Rails.logger.info "認証試行: username=#{username}, expected_user=#{ENV['BASIC_AUTH_USER']}"
      Rails.logger.info "パスワード一致: #{password == ENV['BASIC_AUTH_PASSWORD']}"
      username == ENV["BASIC_AUTH_USER"] && password == ENV["BASIC_AUTH_PASSWORD"]  # 環境変数を読み込む記述に変更
    end
  end
end
