require "administrate/base_dashboard"

class ThemeDashboard < Administrate::BaseDashboard
  ATTRIBUTE_TYPES = {
    id:          Field::Number,
    title:       Field::String,
    category:    Field::Select.with_options(
                   collection: Theme.categories.keys
                 ),
    status:      Field::Select.with_options(
                   collection: Theme.statuses.keys
                 ),
    hidden_at:   Field::DateTime,
    expires_at:  Field::DateTime,
    user:        Field::BelongsTo,
    created_at:  Field::DateTime,
    updated_at:  Field::DateTime
  }.freeze

  COLLECTION_ATTRIBUTES = %i[id title category status hidden_at user created_at].freeze

  SHOW_PAGE_ATTRIBUTES = %i[id title category status hidden_at expires_at user created_at updated_at].freeze

  FORM_ATTRIBUTES = %i[title category status hidden_at expires_at].freeze

  COLLECTION_FILTERS = {}.freeze
end
