# KikakuHub 開発ガイド

## 開発フロー

1. **Issue を確認 or 作成する** — 対応する issue がなければ先に作成する
2. **ブランチを切る** — `feature/{issue番号}-{機能名}` 形式で作成
3. **実装・テスト** — Rubocop を通し、手動で動作確認する
4. **PR を作成する** — テンプレートに沿って記載し、`Closes #XX` で issue を紐付ける
5. **レビュー・マージ** — セルフレビューチェックリストを確認してからマージする

## ガイドライン

| ドキュメント | 内容 |
|-------------|------|
| [Issue の書き方](docs/contributing/issue-guide.md) | タイトル形式、本文構成、ラベルの付け方 |
| [PR の書き方](docs/contributing/pull-request-guide.md) | タイトル形式、本文構成、セルフレビュー |
| [ブランチ命名・ラベル運用](docs/contributing/branch-naming.md) | ブランチ命名規則、コミットメッセージ、ラベル体系 |

## コーディング規約

- **Rubocop** に従う（CI で自動チェック: `.github/workflows/lint.yml`）
- **UI**: Tailwind CSS + daisyUI を使用（[UI ガイドライン](docs/ai/ui-guidelines.ja.md) 参照）
- Views は ERB（`.html.erb`）で記述

## 開発環境

- Docker + Docker Compose（WSL 上で動作）
- Ruby 3.3.0 / Rails
- 起動: `docker compose up` または `bin/dev`（Procfile.dev）

## 環境変数

| 変数名 | 説明 |
|--------|------|
| `INVITE_KEY` | MVP での合言葉（サインアップ時に照合） |
| `RUNTEQ_EVENT_CREATE_URL` | （任意）RUNTEQ 公式イベント作成ページ URL |
