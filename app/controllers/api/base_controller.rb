module Api
  class BaseController < ApplicationController
    require 'auth_token'

    before_action :authenticate

    # jbuilder needs this
    layout false

    private

      def authenticate
        begin
          token = request.headers['Authorization'].split(' ').last
          payload, header = AuthToken.valid?(token)
          @current_user = User.find_by(id: payload['user_id'])
        rescue
          render json: { error: 'You need to login or signup first' }, status: :unauthorized
        end
      end

  end
end