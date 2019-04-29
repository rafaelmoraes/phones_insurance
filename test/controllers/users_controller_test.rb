# frozen_string_literal: true

require 'test_helper'

class UsersControllerTest < ActionDispatch::IntegrationTest
  test 'should create' do
    user_hash = {
      'user' => {
        'name' => 'Rafael Moraes',
        'email' => 'rafael@email.com',
        'cpf' => '105.193.444-30'
      }
    }
    assert_difference('User.count', 1) do
      post users_url(params: user_hash)
    end
    user_hash['user']['id'] = User.last.id
    assert_equal user_hash, response.parsed_body
    assert_response :success
  end

  test 'should not create' do
    assert_difference('User.count', 0) do
      post users_url(
        params: {
          user: {
            name: 'Rafael Moraes',
            email: 'rafael@email.com',
            cpf: ''
          }
        }
      )
    end
    assert response.parsed_body['errors'].any?
    assert_response :bad_request
  end

  test 'should search and find user by cpf' do
    user = users(:valid)
    get search_users_url(cpf: user.cpf)
    user_hash = { 'user' => JSON.parse(user.to_json) }
    assert_equal user_hash, response.parsed_body
    assert_response :success
  end

  test 'should search and not find user by cpf' do
    get search_users_url(cpf: '000.000.000-00')
    assert_response :not_found
  end

  test 'should returns bad request when cpf is blank' do
    get search_users_url
    assert_response :bad_request
  end

  test 'should returns all users' do
    get users_url
    assert_equal User.count, JSON.parse(response.body)['users'].size
    assert_response :success
  end
end
