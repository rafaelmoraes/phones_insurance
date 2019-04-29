# frozen_string_literal: true

require 'test_helper'

class OrdersControllerTest < ActionDispatch::IntegrationTest
  test 'should create user and order' do
    order_hash = { 'order' => { 'imei' => '123123123123123',
                                'phone_model' => 'V8',
                                'annual_price' => '500.5',
                                'installments' => 12,
                                'user' => { 'id' => nil,
                                            'name' => 'Rafael Moraes',
                                            'email' => 'rafael@email.com',
                                            'cpf' => '519.602.618-51' } } }

    assert_difference('User.count', 1) do
      assert_difference('Order.count', 1) do
        post orders_url(params: order_hash)
      end
    end

    assert_equal order_to_hash(Order.last), response.parsed_body
    assert_response :created
  end

  test 'should not create user and order' do
    assert_difference('User.count', 0) do
      assert_difference('Order.count', 0) do
        post orders_url(params: { order: { user: { name: 'Rafael Moraes',
                                                   email: 'rafael@email.com',
                                                   cpf: '999.999.999-99' },
                                           imei: '123123123123123',
                                           phone_model: 'V180',
                                           annual_price: '500.50',
                                           installments: 12 } })
      end
    end

    assert_instance_of Array, response.parsed_body['errors']
    assert_response :bad_request
  end

  test 'should create order when user_id on json' do
    assert_difference('User.count', 0) do
      assert_difference('Order.count', 1) do
        post orders_url(params: { order: { imei: '123123123123123',
                                           phone_model: 'V8',
                                           annual_price: '500.5',
                                           installments: 12,
                                           user_id: users(:valid).id } })
      end
    end

    assert_equal order_to_hash(Order.last), response.parsed_body
    assert_response :created
  end

  test 'should post not create order when user_id or user is empty' do
    assert_difference('User.count', 0) do
      assert_difference('Order.count', 0) do
        post orders_url(params: { order: { imei: '123123123123123',
                                           phone_model: 'HiPhone',
                                           annual_price: '500.50',
                                           installments: 12 } })
      end
    end

    assert response.parsed_body['errors'].any?
    assert_response :bad_request
  end

  test 'should returns all orders' do
    get orders_url

    assert_equal Order.count, response.parsed_body['orders'].size
    assert_response :success
  end

  test 'should returns all user orders' do
    user = users(:valid)
    get user_orders_url(user.id)
    assert_equal user.orders.count, response.parsed_body['orders'].size
    assert_response :success
  end

  test 'should respond not found when user not exists' do
    get user_orders_url(10_000)
    assert_response :not_found
  end

  test 'should create when user_id on url' do
    user = users(:valid)
    assert_difference("Order.where(user_id: #{user.id}).count", 1) do
      post user_orders_url(user.id,
                           params: { order: {
                             imei: '123123123123123',
                             phone_model: 'ChinaPhone',
                             annual_price: '0.50',
                             installments: 5
                           } })
    end

    assert_equal order_to_hash(Order.last), response.parsed_body
    assert_response :created
  end

  private

  def order_to_hash(order)
    { 'order' => JSON.parse(order.to_json) }
  end
end
