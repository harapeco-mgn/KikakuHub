RSpec.configure do |config|
  config.include Devise::Test::IntegrationHelpers, type: :request

  # allow_browserチェックをスキップするヘルパー
  config.before(:each, type: :request) do
    allow_any_instance_of(ApplicationController).to receive(:allow_browser).and_return(true)
  end
end
