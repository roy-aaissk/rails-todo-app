# Todoモデル
# モデル：ビジネスロジックとデータベースとのやり取りを担当（MVCのM）
# ApplicationRecord: Railsの基底モデルクラス（ActiveRecordを継承）
# ActiveRecord: ORM（Object-Relational Mapping）パターンの実装
#   - データベースのレコードをRubyオブジェクトとして扱える
#   - SQLを直接書かずにRubyのメソッドでデータベース操作ができる
class Todo < ApplicationRecord
  # ============================================
  # バリデーション（データの妥当性検証）
  # ============================================
  # バリデーション：データベースに保存する前にデータの妥当性を検証
  # 不正なデータが保存されるのを防ぐ

  # titleのバリデーション
  # presence: 必須チェック（空文字やnilを許可しない）
  # length: 文字数制限
  #   - minimum: 最小文字数（3文字以上）
  #   - maximum: 最大文字数（255文字以下）
  validates :title,
            presence: { message: 'を入力してください' },
            length: {
              minimum: 3,
              maximum: 255,
              too_short: 'は%{count}文字以上で入力してください',
              too_long: 'は%{count}文字以内で入力してください'
            }

  # descriptionのバリデーション
  # length: 最大1000文字まで許可
  # allow_blank: 空文字を許可（任意フィールド）
  validates :description,
            length: {
              maximum: 1000,
              too_long: 'は%{count}文字以内で入力してください'
            },
            allow_blank: true

  # カスタムバリデーション：completed_atとcompletedの整合性チェック
  # validate: カスタムバリデーションメソッドを指定
  # ビジネスルール：完了日時と完了フラグの論理的な整合性を保証
  validate :completed_at_consistency

  # ============================================
  # スコープ（クエリの再利用）
  # ============================================
  # スコープ：よく使うクエリに名前をつけて再利用可能にする
  # ActiveRecordのクエリメソッドをチェーンできる

  # 未完了のTodoを取得するスコープ
  # where: SQL の WHERE句に相当
  # completed: false のレコードのみを抽出
  # 使用例: Todo.incomplete
  scope :incomplete, -> { where(completed: false) }

  # 完了済みのTodoを取得するスコープ
  # completed: true のレコードのみを抽出
  # 使用例: Todo.completed
  scope :completed, -> { where(completed: true) }

  # 新しい順にソートするスコープ
  # order: SQL の ORDER BY句に相当
  # created_at: :desc - 作成日時の降順（新しい順）
  # 使用例: Todo.recent
  scope :recent, -> { order(created_at: :desc) }

  # ============================================
  # ドメインメソッド（ビジネスロジック）
  # ============================================
  # ドメイン駆動設計（DDD）：ビジネスロジックをモデルに配置
  # コントローラーはシンプルに保ち、複雑なロジックはモデルで実装

  # Todoを完了状態にする
  # ビジネスルール：完了時に完了日時を記録
  # update: 複数の属性を一度に更新（バリデーションを実行）
  # Time.current: Railsのタイムゾーンを考慮した現在時刻
  # 戻り値: 更新成功時true、失敗時false
  def mark_as_completed
    update(
      completed: true,
      completed_at: Time.current
    )
  end

  # Todoを未完了状態に戻す
  # ビジネスルール：未完了時は完了日時をクリア
  # 戻り値: 更新成功時true、失敗時false
  def mark_as_incomplete
    update(
      completed: false,
      completed_at: nil
    )
  end

  # 完了/未完了を切り替える
  # ビジネスロジック：現在のステータスに応じて適切なメソッドを呼ぶ
  # 戻り値: 更新成功時true、失敗時false
  def toggle_completion!
    if completed?
      mark_as_incomplete
    else
      mark_as_completed
    end
  end

  # ステータスを日本語文字列で返す
  # プレゼンテーション用のヘルパーメソッド
  # 戻り値: "完了" または "未完了"
  def status
    completed? ? '完了' : '未完了'
  end

  # 完了日時をフォーマットして返す
  # プレゼンテーション用のヘルパーメソッド
  # strftime: 日時を指定したフォーマットで文字列化
  # 戻り値: フォーマット済み日時文字列、またはnil
  def formatted_completed_at
    completed_at&.strftime('%Y年%m月%d日 %H:%M')
  end

  private

  # completed_atとcompletedの整合性を検証するカスタムバリデーション
  # ビジネスルール：
  #   1. 完了済み（completed=true）の場合、completed_atは必須
  #   2. 未完了（completed=false）の場合、completed_atはnil
  # errors.add: バリデーションエラーを追加
  def completed_at_consistency
    if completed? && completed_at.blank?
      errors.add(:completed_at, '完了日時を入力してください')
    elsif !completed? && completed_at.present?
      errors.add(:completed_at, '未完了の場合は完了日時を設定できません')
    end
  end
end
