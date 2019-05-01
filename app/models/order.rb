# frozen_string_literal: true

class Order < ApplicationRecord
  REGEX_IMEI_WITHOUT_DASH = /\A([0-9]{6})([0-9]{2})([0-9]{6})([0-9])\z/.freeze
  REGEX_IMEI_WITH_DASH = /\A[0-9]{6}-[0-9]{2}-[0-9]{6}-[0-9]\z/.freeze
  IMEI_MIN_LENGTH = 15
  IMEI_MAX_LENGTH = 18

  belongs_to :user
  accepts_nested_attributes_for :user

  validates :imei, :phone_model, :annual_price, :installments, presence: true
  validates :imei,
            length: { minimum: IMEI_MIN_LENGTH, maximum: IMEI_MAX_LENGTH }
  validates :annual_price, numericality: { greater_than: 0 }
  validates :installments, numericality: { greater_than: 0, only_integer: true }

  validate :validate_imei

  default_scope { includes(:user) }

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

  def normalize_imei!
    match = REGEX_IMEI_WITHOUT_DASH.match(imei&.strip)
    return nil if match.nil?

    self.imei = "#{match[1]}-#{match[2]}-#{match[3]}-#{match[4]}"
  end

  def validate_imei
    normalize_imei!
    return true if REGEX_IMEI_WITH_DASH.match?(imei)

    errors.add(:imei, :invalid)
  end
end
