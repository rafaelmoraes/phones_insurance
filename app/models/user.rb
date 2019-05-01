# frozen_string_literal: true

class User < ApplicationRecord
  REGEX_CPF_NORMALIZED = /[0-9]{3}\.[0-9]{3}\.[0-9]{3}-[0-9]{2}/.freeze

  has_many :orders

  validates :name, :email, :cpf, presence: true
  validates :email, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :cpf, uniqueness: true, if: :cpf_valid?
  validate :cpf do
    errors.add(:cpf, :invalid) if cpf.present? && !cpf_valid?
  end

  before_validation :normalize_cpf!

  def cpf_valid?
    return false if cpf.blank?

    CPF.valid?(cpf)
  end

  def self.search_by_cpf(cpf)
    where(cpf: cpf).first if CPF.valid?(cpf)
  end

  def as_json(args)
    super({ except: %i[created_at updated_at] }.merge args)
  end

  def normalize_cpf!
    return nil if cpf.nil?
    return cpf if REGEX_CPF_NORMALIZED.match?(cpf)

    self.cpf = CPF.new(cpf).formatted
  end
end
