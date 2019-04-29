# frozen_string_literal: true

require 'test_helper'

class UserTest < ActiveSupport::TestCase
  test 'should save' do
    user = users(:valid)
    assert user.save
  end

  test 'should not save' do
    assert_not User.new.save

    user = users(:invalid)
    assert_not user.save
  end

  test 'should has blank attribute error message' do
    user = users(:valid)
    %i[name email cpf].each do |attribute|
      [nil, ''].each do |value|
        user.send("#{attribute}=", value)
        user.valid?
        assert_includes user.errors[attribute],
                        I18n.t('errors.messages.blank'),
                        "attribute: #{attribute}, value: #{value}"
      end
    end
  end

  test 'should has a cpf invalid error' do
    user = User.new(cpf: '999.999.99-99')
    user.valid?
    assert_includes user.errors[:cpf], I18n.t('errors.messages.invalid')
  end

  test 'should has a cpf already been taken error' do
    user = users(:valid)
    new_user = User.new(cpf: user.cpf)
    new_user.valid?
    assert_includes new_user.errors[:cpf], I18n.t('errors.messages.taken')
  end

  test 'should has a email invalid error' do
    user = User.new(email: 'invalid@ email')
    user.valid?
    assert_includes user.errors[:email], I18n.t('errors.messages.invalid')
  end

  test '#cpf_valid? should returns false' do
    user = User.new
    [nil, '', '999'].each do |value|
      user.cpf = value
      assert_not user.cpf_valid?, "cpf is #{value}"
    end
  end

  test '#orders should be kind of \
    ActiveRecord::Associations::CollectionProxy' do
    user = User.new
    assert_kind_of ActiveRecord::Associations::CollectionProxy, user.orders
  end

  test '.search_by_cpf should returns nil' do
    assert_nil User.search_by_cpf('123.123.123-12')
  end

  test '.search_by_cpf should returns an user' do
    assert_instance_of User, User.search_by_cpf(users(:valid).cpf)
  end

  test 'should not has the attributes on the json' do
    user = users(:valid)
    json_as_hash = JSON.parse(user.to_json)
    %w[created_at updated_at].each do |attribute|
      assert_nil json_as_hash[attribute], "attribute: #{attribute}"
    end
  end
end
