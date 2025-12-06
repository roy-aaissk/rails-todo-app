# シードデータ
# seeds.rb: 開発環境やデモ用の初期データを投入するファイル
# 実行方法: rails db:seed
#
# 冪等性（べきとうせい）: 何度実行しても同じ結果になる
# 本番環境では注意して使用する

# Fakerの日本語設定（オプション）
# Faker::Config.locale = :ja

# 既存データを削除（開発環境でのみ実行）
# 本番環境では実行しないように注意！
if Rails.env.development?
  puts 'シードデータの投入を開始します...'
  puts '既存のTodoデータを削除中...'
  Todo.destroy_all
end

puts 'サンプルTodoを作成中...'

# 未完了のTodo（5件）
5.times do |i|
  Todo.create!(
    title: "未完了タスク #{i + 1}",
    description: "これは未完了のタスクです。説明文がここに入ります。",
    completed: false,
    completed_at: nil
  )
end

# 完了済みのTodo（3件）
3.times do |i|
  Todo.create!(
    title: "完了済みタスク #{i + 1}",
    description: "これは完了済みのタスクです。すでに終了しています。",
    completed: true,
    completed_at: i.days.ago  # i日前に完了
  )
end

# より詳細なサンプルTodo
Todo.create!(
  title: "Ruby on Railsのドキュメントを読む",
  description: "Ruby on Railsの公式ドキュメントを読んで、基礎を学習する。\n特に以下の項目に注目する：\n- MVCアーキテクチャ\n- ActiveRecord\n- ルーティング\n- バリデーション",
  completed: false,
  completed_at: nil
)

Todo.create!(
  title: "データベース設計の学習",
  description: "データベース設計の基礎を学ぶ：\n- 正規化\n- インデックス\n- リレーション\n- トランザクション",
  completed: true,
  completed_at: 2.days.ago
)

Todo.create!(
  title: "RESTful API設計の理解",
  description: "RESTfulなAPI設計の原則を学び、実際のアプリケーションに適用する。HTTPメソッド（GET、POST、PUT、DELETE）の適切な使い分けを習得する。",
  completed: false,
  completed_at: nil
)

# Fakerを使ったランダムデータ（より多様性のあるデータ）
puts 'ランダムなサンプルTodoを作成中...'
10.times do
  # ランダムに完了/未完了を決定
  is_completed = [true, false].sample

  Todo.create!(
    title: Faker::Lorem.sentence(word_count: 3),
    description: Faker::Lorem.paragraph(sentence_count: 3),
    completed: is_completed,
    completed_at: is_completed ? Faker::Time.backward(days: 14) : nil
  )
end

# 作成されたデータの統計を表示
puts "\n" + "=" * 50
puts "シードデータの投入が完了しました！"
puts "=" * 50
puts "合計Todo数: #{Todo.count}"
puts "未完了: #{Todo.incomplete.count}"
puts "完了済み: #{Todo.completed.count}"
puts "=" * 50
