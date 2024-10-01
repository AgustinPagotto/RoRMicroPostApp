class Micropost < ApplicationRecord
  # This next line makes a connection to user, micropost belongs to user
  belongs_to :user
  has_one_attached :image do |attachable|
    attachable.variant :display, resize_to_limit: [500, 500]
  end
  # This will retrieve the microposts in the DB on descending order of created_at (new to old)
  # Anonymous function -> Takes in a block and returns a Proc that will be evaluated when the call method.
  default_scope -> { order(created_at: :desc) }
  validates :user_id, presence: true
  validates :content, presence: true, length: { maximum: 140 }
  validates :image, content_type: { in: %w[image/jpeg image/gif image/png], message: 'must be a valid image format' },
                    size: { less_than: 5.megabytes, message: 'should be less than 5MB' }
end
