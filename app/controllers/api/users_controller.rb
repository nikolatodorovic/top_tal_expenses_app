module Api
  class UsersController < Api::BaseController
    before_action :set_user, only: [:show, :edit, :update, :destroy]
    before_action :is_authorized?
    rescue_from ActiveRecord::RecordNotFound, with: :invalid_user

    def index
      @users = User.all
    end

    def show
    end

    def edit
    end

    def create
      @user = User.new(user_params)

      if @user.save
        render status: :created
      else
        render json: @user.errors, status: :unprocessable_entity
      end
    end

    def update
      if @user.update(user_params)
        render status: :no_content
      else
        render json: @user.errors, status: :unprocessable_entity
      end
    end

    def destroy
      @user.destroy
      head :no_content
    end


    private

      def is_authorized?
        if @current_user.isRegular
          render json: { error: "Doesn't have permissions" }, status: :forbidden
          return
        end
      end

      def set_user
        @user = User.find(params[:id])
      end

      def user_params
        params.require(:user).permit(:first_name, :last_name, :email, :password)
      end

      def invalid_user
        @user = nil
      end

  end
end