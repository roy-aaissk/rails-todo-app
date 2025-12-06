# FactoryBot ファクトリ定義
# FactoryBot: テストデータを簡単に生成するためのライブラリ
# ファクトリ: テストで使用するモデルのテンプレート
#
# 使用例：
#   create(:todo)  # データベースに保存
#   build(:todo)   # メモリ上に作成（保存しない）
#   create(:completed_todo)  # トレイト使用
FactoryBot.define do
  # 基本的なTodoファクトリ
  factory :todo do
    # シーケンス: 重複しない値を生成
    # n: 連番（1, 2, 3, ...）
    sequence(:title) { |n| "Todo タイトル #{n}" }

    # Faker: ランダムなテストデータを生成
    # Lorem.paragraph: ランダムな段落テキスト
    description { Faker::Lorem.paragraph(sentence_count: 3) }

    # デフォルトは未完了
    completed { false }
    completed_at { nil }

    # トレイト: ファクトリのバリエーション
    # 特定の状態のオブジェクトを簡単に作成

    # 完了済みTodoのトレイト
    # 使用例: create(:todo, :completed)
    trait :completed do
      completed { true }
      # 過去のランダムな日時を生成
      completed_at { Faker::Time.backward(days: 7) }
    end

    # 未完了Todoのトレイト（明示的）
    # 使用例: create(:todo, :incomplete)
    trait :incomplete do
      completed { false }
      completed_at { nil }
    end

    # 説明なしのTodoのトレイト
    # 使用例: create(:todo, :without_description)
    trait :without_description do
      description { nil }
    end

    # 長いタイトルのTodoのトレイト
    # バリデーションテスト用
    # 使用例: build(:todo, :with_long_title)
    trait :with_long_title do
      title { 'a' * 256 }  # 256文字（バリデーションエラー）
    end

    # 短いタイトルのTodoのトレイト
    # バリデーションテスト用
    # 使用例: build(:todo, :with_short_title)
    trait :with_short_title do
      title { 'ab' }  # 2文字（バリデーションエラー）
    end
  end
end
