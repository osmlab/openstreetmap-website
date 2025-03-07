# == Schema Information
#
# Table name: user_blocks
#
#  id             :integer          not null, primary key
#  user_id        :bigint           not null
#  creator_id     :bigint           not null
#  reason         :text             not null
#  ends_at        :datetime         not null
#  needs_view     :boolean          default(FALSE), not null
#  revoker_id     :bigint
#  created_at     :datetime
#  updated_at     :datetime
#  reason_format  :enum             default("markdown"), not null
#  deactivates_at :datetime
#
# Indexes
#
#  index_user_blocks_on_creator_id_and_id  (creator_id,id)
#  index_user_blocks_on_user_id            (user_id)
#
# Foreign Keys
#
#  user_blocks_moderator_id_fkey  (creator_id => users.id)
#  user_blocks_revoker_id_fkey    (revoker_id => users.id)
#  user_blocks_user_id_fkey       (user_id => users.id)
#

class UserBlock < ApplicationRecord
  validate :moderator_permissions
  validates :reason, :characters => true, :length => { :maximum => 10000 }
  validates :deactivates_at, :comparison => { :greater_than_or_equal_to => :ends_at }, :unless => -> { needs_view }
  validates :deactivates_at, :absence => true, :if => -> { needs_view }

  belongs_to :user, :class_name => "User"
  belongs_to :creator, :class_name => "User"
  belongs_to :revoker, :class_name => "User", :optional => true

  PERIODS = Settings.user_block_periods

  ##
  # scope to match active blocks
  def self.active
    where("needs_view or ends_at > ?", Time.now.utc)
  end

  ##
  # return a renderable version of the reason text.
  def reason
    RichText.new(self[:reason_format], self[:reason])
  end

  ##
  # returns true if the block is currently active (i.e: the user can't
  # use the API).
  def active?
    needs_view || ends_at > Time.now.utc
  end

  ##
  # returns true if the block is a "zero hour" block
  def zero_hour?
    # if the times differ more than 1 minute we probably have more important issues
    needs_view && (ends_at.to_i - updated_at.to_i) < 60
  end

  ##
  # revokes the block, allowing the user to use the API again. the argument
  # is the user object who is revoking the ban.
  def revoke!(revoker)
    update(
      :ends_at => Time.now.utc,
      :deactivates_at => Time.now.utc,
      :revoker_id => revoker.id,
      :needs_view => false
    )
  end

  private

  ##
  # validate that only moderators are allowed to change the
  # block. this should be caught and dealt with in the controller,
  # but i've also included it here just in case.
  def moderator_permissions
    errors.add(:base, I18n.t("user_blocks.model.non_moderator_update")) if creator_id_changed? && !creator.moderator?
    errors.add(:base, I18n.t("user_blocks.model.non_moderator_revoke")) if revoker_id_changed? && !revoker_id.nil? && !revoker.moderator?
  end
end
