# ApplicationController
# コントローラー：ユーザーリクエストを処理し、モデルとビューを繋ぐ（MVCのC）
# ApplicationController: 全てのコントローラーの基底クラス
# ここで定義したメソッドや機能は、全てのコントローラーで利用可能
class ApplicationController < ActionController::Base
  # HTTP Basic認証を全コントローラーに適用
  # before_action: アクション実行前に指定したメソッドを実行するフィルター
  # authenticate: HTTP Basic認証を実行するメソッド（下記で定義）
  before_action :authenticate

  private

  # HTTP Basic認証メソッド
  # HTTP Basic認証：ブラウザの基本認証ダイアログでユーザー名とパスワードを入力
  # シンプルな認証方式で、学習用やプロトタイプに適している
  # 本番環境では、より堅牢な認証（Devise等）を検討する
  def authenticate
    # authenticate_or_request_with_http_basic: Rails組み込みのHTTP Basic認証メソッド
    # ブロック内で認証ロジックを定義
    # 認証失敗時は、自動的に401 Unauthorizedレスポンスを返す
    authenticate_or_request_with_http_basic do |username, password|
      # 認証情報の検証
      # username: ユーザーが入力したユーザー名
      # password: ユーザーが入力したパスワード
      # 戻り値: 認証成功時true、失敗時false

      # セキュリティ上の注意：
      # 1. 本番環境では認証情報を環境変数で管理すべき
      #    例: ENV['ADMIN_USERNAME'], ENV['ADMIN_PASSWORD']
      # 2. パスワードはハッシュ化して保存すべき
      # 3. HTTPS通信を使用してパスワードを保護すべき
      username == 'admin' && password == 'password'
    end
  end
end
