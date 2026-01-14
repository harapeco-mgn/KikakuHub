# ===== ビルドステージ =====
FROM ruby:3.3.0-slim AS builder

WORKDIR /rails

# ビルドに必要なパッケージをインストール
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y \
    build-essential \
    libpq-dev \
    && rm -rf /var/lib/apt/lists /var/cache/apt/archives

# 本番環境用の環境変数
ENV RAILS_ENV=production \
    BUNDLE_PATH="/usr/local/bundle" \
    BUNDLE_WITHOUT="development:test"

# Gemfileをコピーしてbundle install
COPY Gemfile Gemfile.lock ./
RUN bundle install --without development test

# アプリケーションコードをコピー
COPY . .

# アセットのプリコンパイル（必要な場合）
# SECRET_KEY_BASEはダミー値でOK（実行時に環境変数で上書きされる）
RUN SECRET_KEY_BASE=dummy bundle exec rails assets:precompile

# ===== 実行ステージ =====
FROM ruby:3.3.0-slim

WORKDIR /rails

# 実行に必要な最小限のパッケージのみインストール
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y \
    libpq-dev \
    postgresql-client \
    libvips \
    && rm -rf /var/lib/apt/lists /var/cache/apt/archives

# 本番環境用の環境変数
ENV RAILS_ENV=production \
    BUNDLE_PATH="/usr/local/bundle"

# ビルドステージからgemをコピー
COPY --from=builder /usr/local/bundle /usr/local/bundle

# ビルドステージからアプリケーションをコピー
COPY --from=builder /rails /rails

# entrypoint をコピー
COPY bin/render-entrypoint.sh /usr/bin/render-entrypoint.sh
RUN chmod +x /usr/bin/render-entrypoint.sh

# 起動前に必ず migrate を走らせる
ENTRYPOINT ["/usr/bin/render-entrypoint.sh"]

# 本番環境用の起動コマンド
CMD ["bash", "-c", "rm -f tmp/pids/server.pid && bundle exec rails s -b '0.0.0.0' -p ${PORT:-3000}"]