# Todoテーブルを作成するマイグレーション
# マイグレーション：データベーススキーマの変更履歴を管理する仕組み
# このファイルを実行すると、データベースにtodosテーブルが作成される
class CreateTodos < ActiveRecord::Migration[7.1]
  def change
    # create_table: 新しいテーブルを作成するメソッド
    # ブロック内でカラムを定義する
    create_table :todos do |t|
      # title: Todoのタイトル
      # string型: 短いテキスト（最大255文字）に適している
      # null: false - 必須フィールド（NULLを許可しない）
      # limit: 最大文字数を255に制限
      t.string :title, null: false, limit: 255

      # description: Todoの詳細説明
      # text型: 長いテキストを保存できる（サイズ制限なし）
      # null制約なし - 任意フィールド
      t.text :description

      # completed: 完了/未完了のステータス
      # boolean型: true/falseの二値
      # default: false - デフォルトで未完了
      # null: false - 必須フィールド
      t.boolean :completed, default: false, null: false

      # completed_at: 完了日時
      # datetime型: 日付と時刻を保存
      # null制約なし - 未完了の場合はNULL
      t.datetime :completed_at

      # timestamps: created_atとupdated_atカラムを自動的に追加
      # created_at: レコード作成日時
      # updated_at: レコード更新日時
      # Railsが自動的に管理する
      t.timestamps
    end

    # インデックス: データベースの検索を高速化
    # completedカラムにインデックスを作成
    # 完了/未完了でフィルタリングする際に高速化される
    add_index :todos, :completed

    # created_atカラムにインデックスを作成
    # 作成日時でソートする際に高速化される
    add_index :todos, :created_at
  end
end
