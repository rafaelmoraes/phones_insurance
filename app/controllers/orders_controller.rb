# frozen_string_literal: true

class OrdersController < ApplicationController
  before_action :set_order, only: :create
  before_action :render_not_found

  def create
    if @order.save
      render json: { order: @order }, status: :created
    else
      render json: { errors: @order.errors.full_messages }, status: :bad_request
    end
  end

  def index
    if url_user_id.nil?
      render json: { orders: Order.all }, status: :ok
    else
      render json: { orders: Order.where(user_id: url_user_id) }, status: :ok
    end
  end

  private

  def render_not_found
    render status: :not_found if url_user_id && !User.exists?(url_user_id)
  end

  def set_order
    @order = Order.new(order_params)
    set_user
  end

  def url_user_id
    params.permit(:user_id)[:user_id]
  end

  def order_params
    params.require(:order).permit(
      :imei,
      :user_id,
      :phone_model,
      :annual_price,
      :installments
    )
  end

  def user_params
    params.require(:order).permit(user: %i[id name cpf email])[:user]
  end

  def set_user
    @order.user_id = url_user_id if url_user_id.present?
    @order.user_id = user_params[:id] if user_params && user_params[:id]
    @order.user = User.new(user_params) if @order.user_id.nil?
  end
end
