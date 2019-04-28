# frozen_string_literal: true

class User < ApplicationRecord
  has_many :orders

  validates :name, :email, :cpf, presence: true
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :cpf, uniqueness: true, if: :cpf_valid?
  validate :cpf do
    errors.add(:cpf, :invalid) if cpf.present? && !cpf_valid?
  end

  def cpf_valid?
    return false if cpf.blank?

    CPF.valid?(cpf)
  end
end
