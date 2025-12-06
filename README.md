# Todo アプリケーション

Ruby on Rails で作成したシンプルなTodo管理システムです。Ruby初心者がコードを読みながらシステム設計を学習できるよう、詳細なコメントを含んでいます。

## 概要

このアプリケーションは、以下の学習目的で設計されています：

- **MVCアーキテクチャ**の理解
- **RESTful設計**の実践
- **データベース設計**とActiveRecordの使用方法
- **バリデーション**の実装
- **RSpec**によるテスト駆動開発
- **ドメイン駆動設計（DDD）**の基礎

## 機能

### 基本機能
- ✅ Todoの作成・表示・更新・削除（CRUD操作）
- ✅ 完了/未完了のステータス管理
- ✅ HTTP Basic認証（ユーザー名: `admin`、パスワード: `password`）

### 技術的特徴
- **SSR（Server-Side Rendering）**: ERBテンプレートによるサーバーサイドレンダリング
- **RESTful API設計**: 標準的なHTTPメソッドとURLパターン
- **バリデーション**: データの妥当性検証
- **スコープ**: 再利用可能なクエリ
- **ドメインメソッド**: ビジネスロジックのカプセル化

## 技術スタック

- **Ruby**: 3.2.2
- **Rails**: 7.1.6
- **データベース**: SQLite3
- **テンプレートエンジン**: ERB
- **テストフレームワーク**: RSpec
- **テストツール**: FactoryBot, Faker, Capybara

## セットアップ

### 必要な環境

- Ruby 3.2.2
- Bundler
- SQLite3

### インストール手順

1. リポジトリをクローン

```bash
git clone <repository-url>
cd <repository-name>
```

2. 依存関係をインストール

```bash
bundle install
```

3. データベースをセットアップ

```bash
rails db:create
rails db:migrate
```

4. シードデータを投入（オプション）

```bash
rails db:seed
```

## 使い方

### 開発サーバーの起動

```bash
rails server
```

ブラウザで [http://localhost:3000](http://localhost:3000) にアクセスします。

### 認証情報

- **ユーザー名**: `admin`
- **パスワード**: `password`

### テストの実行

```bash
# 全テストを実行
bundle exec rspec

# 特定のテストを実行
bundle exec rspec spec/models/todo_spec.rb
bundle exec rspec spec/requests/todos_spec.rb
```

## プロジェクト構造

```
app/
├── controllers/          # コントローラー（MVCのC）
│   ├── application_controller.rb  # HTTP Basic認証
│   └── todos_controller.rb        # Todo CRUD操作
├── models/              # モデル（MVCのM）
│   └── todo.rb          # Todoビジネスロジック
├── views/               # ビュー（MVCのV）
│   ├── layouts/
│   │   └── application.html.erb   # 共通レイアウト
│   └── todos/
│       ├── index.html.erb         # 一覧
│       ├── show.html.erb          # 詳細
│       ├── new.html.erb           # 新規作成
│       ├── edit.html.erb          # 編集
│       └── _form.html.erb         # 共通フォーム
└── helpers/             # ヘルパー
    └── todos_helper.rb  # 表示ロジック

config/
├── routes.rb            # ルーティング設定
└── database.yml         # データベース設定

db/
├── migrate/             # マイグレーションファイル
│   └── XXXXXX_create_todos.rb
└── seeds.rb             # シードデータ

spec/                    # テスト
├── models/
│   └── todo_spec.rb     # モデルテスト
├── requests/
│   └── todos_spec.rb    # リクエストテスト
└── factories/
    └── todos.rb         # FactoryBotファクトリ
```

## アーキテクチャ

### MVCパターン

```
           ┌─────────────┐
           │   Browser   │
           └──────┬──────┘
                  │
           ┌──────▼──────┐
           │   Router    │  ← routes.rb
           └──────┬──────┘
                  │
      ┌───────────▼───────────┐
      │   Controller (C)       │  ← todos_controller.rb
      │  - リクエスト処理      │
      │  - パラメータ検証      │
      │  - レスポンス制御      │
      └───┬───────────────┬───┘
          │               │
  ┌───────▼──────┐  ┌────▼─────┐
  │  Model (M)   │  │ View (V) │  ← index.html.erb
  │- ビジネス    │  │- 表示     │
  │  ロジック    │  │- HTML生成 │
  │- DB操作      │  │           │
  └───┬──────────┘  └───────────┘
      │
  ┌───▼────┐
  │Database│  ← SQLite3
  └────────┘
```

### RESTful設計

| HTTPメソッド | URL | アクション | 説明 |
|------------|-----|----------|------|
| GET | /todos | index | 一覧表示 |
| GET | /todos/new | new | 新規作成フォーム |
| POST | /todos | create | 作成処理 |
| GET | /todos/:id | show | 詳細表示 |
| GET | /todos/:id/edit | edit | 編集フォーム |
| PATCH | /todos/:id | update | 更新処理 |
| DELETE | /todos/:id | destroy | 削除処理 |
| PATCH | /todos/:id/toggle_completion | toggle_completion | ステータス切替 |

### データベース設計

**todosテーブル**

| カラム名 | 型 | 制約 | 説明 |
|---------|-----|-----|------|
| id | INTEGER | PRIMARY KEY | 主キー |
| title | VARCHAR(255) | NOT NULL | タイトル（3-255文字） |
| description | TEXT | NULL | 説明（最大1000文字） |
| completed | BOOLEAN | NOT NULL, DEFAULT false | 完了フラグ |
| completed_at | DATETIME | NULL | 完了日時 |
| created_at | DATETIME | NOT NULL | 作成日時 |
| updated_at | DATETIME | NOT NULL | 更新日時 |

**インデックス**
- `index_todos_on_completed`: 完了/未完了でのフィルタリング高速化
- `index_todos_on_created_at`: 作成日時でのソート高速化

## 学習ポイント

### 1. MVCアーキテクチャ
- **Model**: ビジネスロジック（バリデーション、スコープ、ドメインメソッド）
- **View**: 表示ロジック（ERBテンプレート、ヘルパー）
- **Controller**: リクエスト処理（CRUD操作、認証）

### 2. RESTful設計
- リソース指向のURL設計
- HTTPメソッドの適切な使用
- ステートレスな設計

### 3. データベース設計
- 適切なカラム型の選択
- NOT NULL制約とDEFAULT値
- インデックスによる高速化

### 4. バリデーション
- モデルレベルでのデータ検証
- カスタムバリデーション
- エラーメッセージの日本語化

### 5. ドメイン駆動設計（DDD）
- ビジネスロジックのモデルへの配置
- ドメインメソッド（`mark_as_completed`、`toggle_completion!`）
- Fat Model, Skinny Controller

### 6. テスト駆動開発（TDD）
- モデルテスト（バリデーション、スコープ、ドメインメソッド）
- リクエストテスト（CRUD操作、認証）
- FactoryBotによるテストデータ生成

### 7. セキュリティ
- **CSRF対策**: `csrf_meta_tags`
- **XSS対策**: `csp_meta_tag`、ERBの自動エスケープ
- **認証**: HTTP Basic認証
- **Strong Parameters**: マスアサインメント脆弱性対策

## トラブルシューティング

### データベースのリセット

```bash
rails db:drop
rails db:create
rails db:migrate
rails db:seed
```

### テストデータベースのセットアップ

```bash
rails db:test:prepare
```

## 今後の拡張案

- ユーザー管理（Devise等）
- カテゴリー機能
- 期限管理
- ページネーション
- 検索機能
- APIエンドポイント（JSON形式）
- フロントエンド強化（Hotwire/Turbo）

## ライセンス

MIT License

## 作成者

学習用サンプルアプリケーション

## 参考資料

- [Ruby on Rails ガイド](https://railsguides.jp/)
- [RSpec Documentation](https://rspec.info/)
- [RESTful Web Services](https://www.oreilly.com/library/view/restful-web-services/9780596529260/)
- [ドメイン駆動設計入門](https://www.amazon.co.jp/dp/479815072X)
