# frozen_string_literal: true

class Order < ApplicationRecord
  IMEI_MIN_LENGTH = 15
  IMEI_MAX_LENGTH = 18

  belongs_to :user
  accepts_nested_attributes_for :user

  validates :imei, :phone_model, :annual_price, :installments, presence: true
  validates :imei,
            length: { minimum: IMEI_MIN_LENGTH, maximum: IMEI_MAX_LENGTH }
  validates :annual_price, numericality: { greater_than: 0 }
  validates :installments, numericality: { greater_than: 0, only_integer: true }

  default_scope { includes(:user) }

  # TODO: implement an imei formatter
  # TODO: implement an imei validator
  # TODO: validates if user already has an order with the same imei

  def as_json(args)
    defaults = {
      except: %i[created_at updated_at user_id],
      include: {
        user: {
          except: %i[created_at updated_at]
        }
      }
    }
    super(defaults.merge(args))
  end
end
