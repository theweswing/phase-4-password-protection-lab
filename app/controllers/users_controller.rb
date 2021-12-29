class UsersController < ApplicationController
  rescue_from ActiveRecord::RecordInvalid, with: :invalid_input
  before_action :authorize, only: [:show]

  def create
    user = User.create!(strong_params)
    session[:user_id] = user.id
    render json: user, status: :created
  end

  def show
    user = User.find_by(id: session[:user_id])
    if user
      render json: user, status: :ok
    else
      render json: { error: 'Not authorized' }, status: :unauthorized
    end
  end

  private

  def strong_params
    params.permit(:username, :password, :password_confirmation)
  end

  def invalid_input(e)
    render json: {
             errors: e.record.errors.full_messages,
           },
           status: :unprocessable_entity
  end

  def authorize
    unless session.include? :user_id
      return render json: { error: 'Not authorized' }, status: :unauthorized
    end
  end
end

# rescue_from ActiveRecord::RecordNotFound, with: :not_found

# def not_found
#   render json: { error: 'Camper Not Found!' }, status: :not_found
# end
