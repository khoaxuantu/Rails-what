class Micropost < ApplicationRecord
  belongs_to :user

  has_one_attached :image do |attachable|
    attachable.variant :display, resize_to_limit: [500, 500]
  end

  scope :latest, -> { order(created_at: :desc) }
  validates :user_id, presence: true
  validates(
    :content,
    presence: true,
    length: { maximum: 140 }
  )
  validates(
    :image,
    content_type: {
      in: %w[image/jpeg image/gif image/png],
      message: I18n.t('micropost.image_type_validate')
    },
    size: {
      less_than: 5.megabytes,
      message: I18n.t('micropost.image_size_validate')
    }
  )
end
