# TodosHelper
# ヘルパー：ビューで使用する表示ロジックを定義
# MVCの役割分担：
#   - Model: ビジネスロジック
#   - Controller: リクエスト処理
#   - View: 表示
#   - Helper: 表示ロジック（Viewをシンプルに保つ）
#
# Railsの規約：
#   - app/helpers/todos_helper.rb は TodosController のビューで自動的に利用可能
#   - module名は TodosHelper（複数形 + Helper）
module TodosHelper
  # Todoのステータスバッジを生成するヘルパーメソッド
  # 目的：ビューでの表示ロジックを簡潔にする
  #
  # 使用例：
  #   <%= status_badge_for(@todo) %>
  #
  # @param todo [Todo] Todoオブジェクト
  # @return [String] HTMLタグを含む文字列
  def status_badge_for(todo)
    # 完了状態に応じてCSSクラスとテキストを設定
    if todo.completed?
      badge_class = 'badge-completed'
      status_text = '完了'
    else
      badge_class = 'badge-incomplete'
      status_text = '未完了'
    end

    # content_tag: HTMLタグを生成するヘルパー
    # 第一引数：タグ名（:span）
    # 第二引数：タグの内容（status_text）
    # 第三引数：HTML属性（class: '...'）
    # html_safe: 文字列をHTMLセーフとしてマーク（エスケープしない）
    content_tag(:span, status_text, class: "badge #{badge_class}")
  end

  # Todoの説明を切り詰めて表示するヘルパーメソッド
  # 目的：一覧表示で長い説明を適切に表示
  #
  # 使用例：
  #   <%= truncated_description(@todo) %>
  #
  # @param todo [Todo] Todoオブジェクト
  # @param length [Integer] 最大文字数（デフォルト: 50）
  # @return [String] 切り詰められた説明
  def truncated_description(todo, length: 50)
    # presence: 値がある場合はその値、空の場合はnil
    description = todo.description.presence || '説明なし'
    # truncate: Railsのヘルパー、文字列を切り詰める
    truncate(description, length: length, omission: '...')
  end

  # Todoの統計情報を取得するヘルパーメソッド
  # 目的：統計情報の計算ロジックをビューから分離
  #
  # 使用例：
  #   <% stats = todo_statistics %>
  #   <%= stats[:total] %>
  #
  # @return [Hash] 統計情報を含むハッシュ
  def todo_statistics
    {
      total: Todo.count,        # 全Todo数
      incomplete: Todo.incomplete.count,  # 未完了Todo数
      completed: Todo.completed.count     # 完了Todo数
    }
  end

  # ステータス切り替えボタンのテキストを返すヘルパーメソッド
  # 目的：ボタンテキストの決定ロジックをビューから分離
  #
  # 使用例：
  #   <%= button_to toggle_button_text(@todo), ... %>
  #
  # @param todo [Todo] Todoオブジェクト
  # @return [String] ボタンテキスト
  def toggle_button_text(todo)
    todo.completed? ? '未完了に戻す' : '完了にする'
  end

  # Todoの完了率を計算するヘルパーメソッド
  # 目的：統計情報の計算
  #
  # 使用例：
  #   <%= completion_rate %>%
  #
  # @return [Float] 完了率（0.0〜100.0）
  def completion_rate
    total = Todo.count
    # ゼロ除算を防ぐ
    return 0.0 if total.zero?

    completed = Todo.completed.count
    # to_f: 整数を浮動小数点数に変換（正確な割合計算のため）
    # round(1): 小数点第1位で四捨五入
    (completed.to_f / total * 100).round(1)
  end
end
