require "administrate/base_dashboard"

class UserDashboard < Administrate::BaseDashboard
  ATTRIBUTE_TYPES = {
    id:         Field::Number,
    nickname:   Field::String,
    email:      Field::String,
    role:       Field::Select.with_options(
                  collection: User.roles.keys
                ),
    cohort:     Field::Number,
    created_at: Field::DateTime,
    updated_at: Field::DateTime
  }.freeze

  COLLECTION_ATTRIBUTES = %i[id nickname email role cohort created_at].freeze

  SHOW_PAGE_ATTRIBUTES = %i[id nickname email role cohort created_at updated_at].freeze

  FORM_ATTRIBUTES = %i[nickname email role cohort].freeze

  COLLECTION_FILTERS = {}.freeze
end
