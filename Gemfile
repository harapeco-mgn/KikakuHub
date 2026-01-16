source "https://rubygems.org"

ruby "3.3.0"

gem "rails", "~> 7.2.0"
gem "pg", "~> 1.1"
gem "puma", ">= 5.0"
gem "sprockets-rails"
gem "importmap-rails"
gem "turbo-rails"
gem "stimulus-rails"
gem "jbuilder"
gem "tzinfo-data", platforms: %i[ windows jruby ]
gem "bootsnap", require: false

# 認証
gem "devise"
gem "devise-i18n"
gem "resend"

# tailwindcss
gem "tailwindcss-rails"

group :development, :test do
  gem "debug", platforms: %i[ mri windows ]

  # コード品質チェック
  gem "rubocop", require: false
  gem "rubocop-rails", require: false
  gem "rubocop-rails-omakase", require: false

  # デバッグツール
  gem "pry-byebug"
  gem "better_errors"
  gem "binding_of_caller"

  # テスト関連
  gem "rspec-rails"
  gem "factory_bot_rails"
  gem "faker"
end

group :development do
  gem "web-console"

  # 開発効率向上
  gem "annotate"
  gem "bullet"

  gem "letter_opener_web"
end
