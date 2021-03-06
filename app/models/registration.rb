class Registration < ActiveRecord::Base
  has_one :invitation, foreign_key: :invitee_id

  include Extentions::Attendable # Allows for tracking whether a student showed up (and why/why not)

  REQUIRED_ATTRIBUTES = [
    :first_name,
    :last_name,
    :email
  ]

  REGISTRATION_ATTRIBUTES = [
    :event_id,
    :event,
    :email_confirmation,
    :gender,
    :phone_number,
    :programming_experience,
    :reason_for_applying,
    :how_did_you_hear_about_us,
    :uk_resident,
    :os,
    :os_version,
    :terms_of_service,
    :address,
    :spoken_languages,
    :preferred_language
  ]

  # attr_accessible(
  #   *(REQUIRED_ATTRIBUTES + REGISTRATION_ATTRIBUTES),
  #   :twitter,
  #   :dietary_restrictions,
  #   :selection_state,
  #   :attending,
  #   :member
  # )

  validates *REQUIRED_ATTRIBUTES,     presence: true
  validates *(REGISTRATION_ATTRIBUTES - [:gender]), presence: true, on: :registration

  belongs_to :event
  belongs_to :member

  validates :terms_of_service, :acceptance => true
  validates :email, confirmation: true
  validates :email, uniqueness: { scope: :event_id, message: "You've already registered for this event! Sit tight, you'll hear from us soon." }

  scope :accepted, -> { where(selection_state: "accepted", attending: true) }
  scope :members,  -> { where(Registration.arel_table[:member_id].not_eq(nil)) }

  default_scope -> { order(created_at: :desc) }

  def fullname
    "#{first_name} #{last_name}"
  end

  def name
    fullname
  end

  def to_s
    [
      :fullname,
      :gender,
      :uk_resident,
      :programming_experience,
      :spoken_languages,
      :preferred_language
    ].map do |information|
      "#{information.to_s.humanize}: #{send(information)}"
    end.join "\n"
  end

  def mark_selection(selection_state)
    update_attribute :selection_state, selection_state
  end

end
