# frozen_string_literal: true

require 'test_helper'

class OrderTest < ActiveSupport::TestCase
  test 'should save' do
    order = orders(:valid)
    assert order.save
  end

  test 'should not save' do
    assert_not Order.new.save

    order = orders(:invalid)
    assert_not order.save
  end

  test 'should has blank attribute error message' do
    order = orders(:valid)
    %i[imei phone_model annual_price installments].each do |attribute|
      [nil, '', ' '].each do |value|
        order.send("#{attribute}=", value)
        order.valid?
        assert_includes order.errors[attribute],
                        I18n.t('errors.messages.blank'),
                        "attribute: #{attribute}, value: #{value}"
      end
    end
  end

  test 'should has imei minimum length error message' do
    order = Order.new(imei: '9999')
    order.valid?
    assert_includes(
      order.errors[:imei],
      I18n.t('errors.messages.too_short.other', count: Order::IMEI_MIN_LENGTH)
    )
  end

  test 'should has imei maximum length error message' do
    order = Order.new(imei: '9999999999999999999')
    order.valid?
    assert_includes(
      order.errors[:imei],
      I18n.t('errors.messages.too_long.other', count: Order::IMEI_MAX_LENGTH)
    )
  end

  test 'should has attribute is not a number error message' do
    order = Order.new
    %i[annual_price installments].each do |attribute|
      order.send("#{attribute}=", 'um')
      order.valid?
      assert_includes order.errors[attribute],
                      I18n.t('errors.messages.not_a_number'),
                      "attribute: #{attribute}, value: um"
    end
  end

  test 'should has annual_price must be greater than 0 error message' do
    order = Order.new
    [0, -1, -1.1, 0.0].each do |value|
      order.annual_price = value
      order.valid?
      assert_includes order.errors[:annual_price],
                      I18n.t('errors.messages.greater_than', count: 0)
    end
  end

  test 'should has installments must be greater than 0 error message' do
    order = Order.new
    [0, -1].each do |value|
      order.installments = value
      order.valid?
      assert_includes order.errors[:installments],
                      I18n.t('errors.messages.greater_than', count: 0)
    end
  end

  test 'should has installments must be an integer error message' do
    order = Order.new
    [-1.1, 0.0, BigDecimal('123.12')].each do |value|
      order.installments = value
      order.valid?
      assert_includes order.errors[:installments],
                      I18n.t('errors.messages.not_an_integer')
    end
  end

  test 'should has user must exist error message' do
    order = orders(:valid)
    order.user = nil
    order.valid?
    assert_includes order.errors[:user], I18n.t('errors.messages.required')
  end

  test 'should belongs to an user' do
    order = orders(:valid)
    assert_kind_of ApplicationRecord, order.user
  end
end
