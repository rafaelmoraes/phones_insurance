# frozen_string_literal: true

class UsersController < ApplicationController
  before_action :skip_when_cpf_is_blank, only: :search

  def index
    render json: { users: User.all }, status: :ok
  end

  def create
    user = User.new(user_params)
    if user.save
      render json: { user: user }, status: :created
    else
      render json: { errors: user.errors.full_messages }, status: :bad_request
    end
  end

  def search
    user = User.search_by_cpf(cpf_param)
    if user
      render json: { user: user }, status: :ok
    else
      render status: :not_found
    end
  end

  private

  def user_params
    params.require(:user).permit(:name, :cpf, :email)
  end

  def cpf_param
    params.permit(:cpf)[:cpf]
  end

  def skip_when_cpf_is_blank
    render status: :bad_request if cpf_param.blank?
  end
end
