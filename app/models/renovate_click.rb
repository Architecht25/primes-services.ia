class RenovateClick < ApplicationRecord
  validates :event_type, inclusion: { in: %w[click redirect] }

  scope :clicks,     -> { where(event_type: 'click') }
  scope :redirects,  -> { where(event_type: 'redirect') }
  scope :recent,     -> { where('created_at >= ?', 30.days.ago) }
  scope :today,      -> { where('created_at >= ?', Time.current.beginning_of_day) }
  scope :this_week,  -> { where('created_at >= ?', 7.days.ago) }
end
