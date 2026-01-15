#!/usr/bin/env sh
set -e

# Render/production で動く前提：DBマイグレーションを適用
bundle exec rails db:migrate

# 固定IDの初期データ（communities.id=1）を投入（冪等なら毎回OK）
bundle exec rails db:seed

# ここで本来の起動コマンド（CMD）を実行
exec "$@"