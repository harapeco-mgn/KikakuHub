#!/usr/bin/env sh
set -e

# Render/production で動く前提：DBマイグレーションを適用
bundle exec rails db:migrate

# ここで本来の起動コマンド（CMD）を実行
exec "$@"