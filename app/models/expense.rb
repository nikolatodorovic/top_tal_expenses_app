class Expense < ActiveRecord::Base
  belongs_to :user

  validates :user_id, :amount, :for_timeday, :description, presence: true
  validates :amount, numericality: { greater_than_or_equal_to: 0.1, less_than_or_equal_to: 100000000 }

  validate :day_cant_be_in_the_future

  def day_cant_be_in_the_future
    errors.add :for_timeday, "can't be in the future" if self.for_timeday and self.for_timeday >= Time.now
  end

  scope :greaterThanTime, -> (time) {where("for_timeday > ?", time)}
  scope :lessThanTime, -> (time) {where("for_timeday < ?", time)}

end
