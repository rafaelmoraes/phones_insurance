# frozen_string_literal: true

class Order < ApplicationRecord
  IMEI_MIN_LENGTH = 15
  IMEI_MAX_LENGTH = 18

  belongs_to :user

  validates :imei, :phone_model, :annual_price, :installments, presence: true
  validates :imei,
            length: { minimum: IMEI_MIN_LENGTH, maximum: IMEI_MAX_LENGTH }
  validates :annual_price, numericality: { greater_than: 0 }
  validates :installments, numericality: { greater_than: 0, only_integer: true }

  # TODO: implement an imei validator
end
