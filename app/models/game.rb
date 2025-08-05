class Game < ApplicationRecord
  # Validations
  validates :name, presence: true, length: { minimum: 3, maximum: 100 }, uniqueness: true
  validates :description, presence: true, length: { maximum: 1000 }
  validates :max_participants, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :min_participants, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validate :max_participants_greater_than_or_equal_to_min
  
  # Scopes
  scope :upcoming, -> { where(started_at: nil) }
  scope :in_progress, -> { where.not(started_at: nil).where(completed_at: nil) }
  scope :completed, -> { where.not(completed_at: nil) }
  
  # Instance methods
  def status
    return :completed if completed_at.present?
    return :in_progress if started_at.present?
    :upcoming
  end
  
  def start!
    return false if started_at.present?
    update!(started_at: Time.current)
  end
  
  def complete!
    return false if completed_at.present? || started_at.nil?
    update!(completed_at: Time.current)
  end
  
  private
  
  def max_participants_greater_than_or_equal_to_min
    return if max_participants.blank? || min_participants.blank?
    
    if max_participants < min_participants
      errors.add(:max_participants, "must be greater than or equal to min participants")
    end
  end
end
