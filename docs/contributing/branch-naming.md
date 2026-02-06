# ブランチ命名規則 & ラベル運用ガイド

## ブランチ命名規則

### 基本形式

```
{type}/{issue_number}-{short-description}
```

### type 一覧

| type | 用途 | 例 |
|------|------|-----|
| `feature` | 新機能追加、既存機能の拡張 | `feature/73-theme-search` |
| `fix` | バグ修正 | `fix/80-vote-count-display` |
| `hotfix` | 本番緊急修正 | `hotfix/81-login-crash` |
| `refactor` | 機能変更を伴わないリファクタリング | `refactor/74-extract-service` |
| `docs` | ドキュメントのみの変更 | `docs/75-issue-pr-guidelines` |
| `chore` | 設定・CI・依存関係の更新 | `chore/77-update-rubocop` |

### ルール

- **issue番号は必ず付ける**（トレーサビリティのため）
- `short-description` はケバブケース（英語、小文字、ハイフン区切り）
- 日本語は使わない

### 具体例

```
# 良い例
feature/73-theme-search
fix/80-vote-count-display
refactor/74-extract-service-class

# 避けたい例
feature/retake_css_calendar     → issue番号なし、スネークケース
fix/bug                          → issue番号なし、説明不足
Feature/65-ui-improvements       → 大文字始まり
```

---

## コミットメッセージ

### 推奨形式（Conventional Commits スタイル）

```
{prefix}: 変更内容の説明
```

| prefix | 用途 |
|--------|------|
| `feat` | 新機能 |
| `fix` | バグ修正 |
| `refactor` | リファクタリング |
| `docs` | ドキュメント |
| `chore` | 設定・CI |
| `style` | コードフォーマット |
| `test` | テスト追加・修正 |

### ルール

- prefix の使用は**推奨だが任意**（prefix なしの日本語メッセージも可）
- 本文は日本語で書く
- 1行目は50文字以内を目安
- 詳細が必要な場合は空行の後に本文を記載

### 例

```
feat: テーマ一覧にキーワード検索機能を追加

Themeモデルにsearchスコープを実装し、
ThemesController#indexで検索パラメータを受け取る。
Turbo Frameで検索結果を非同期更新する。
```

```
fix: 投票数の表示が正しくない問題を修正
```

```
テーマ一覧に検索機能を追加
```

上記いずれの形式も許容されます。

---

## ラベル運用

### type ラベル（必須: 1つ選択）

issue作成時にテンプレートから自動付与されます。

| ラベル | 用途 |
|--------|------|
| `type:feature` | 新機能・改善 |
| `type:bug` | バグ報告 |
| `type:refactor` | リファクタリング |
| `type:docs` | ドキュメント |
| `type:chore` | 設定・CI・依存関係 |

### area ラベル（任意: 該当するものを選択）

| ラベル | 用途 |
|--------|------|
| `area:auth` | 認証・ユーザー登録 |
| `area:themes` | テーマ（企画）関連 |
| `area:availability` | 参加可能時間関連 |
| `area:rsvps` | 参加表明関連 |
| `area:comments` | コメント関連 |
| `area:ui` | UI・デザイン全般 |
| `area:infra` | Docker・CI・デプロイ |

### priority ラベル（任意）

| ラベル | 用途 |
|--------|------|
| `prio:high` | 優先度高 |
| `prio:mid` | 優先度中（デフォルト） |
| `prio:low` | 優先度低 |

### ラベルの組み合わせ例

```
type:feature + area:availability + prio:high
→ 参加可能時間関連の新機能で、優先度が高い

type:bug + area:themes
→ テーマ関連のバグ

type:refactor + area:availability
→ 参加可能時間関連のリファクタリング
```

### 既存ラベルとの対応

| 既存ラベル | 新ラベル |
|------------|----------|
| `enhancement` | `type:feature` |
| `area:auth` | そのまま維持 |
| `area:themes` | そのまま維持 |
| `area:availability` | そのまま維持 |
| `prio:high` | そのまま維持 |
| `prio:mid` | そのまま維持 |

既存issueのラベルを遡って変更する必要はありません。新規issueから新ラベルを使用してください。
