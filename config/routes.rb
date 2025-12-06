# ルーティング設定
# ルーティング：URLとコントローラーアクションを結びつける仕組み
# RESTful設計：リソース（Todo）に対する標準的な操作を定義
Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # ルートパス: アプリケーションのトップページ
  # "/" にアクセスすると todos#index アクションが実行される
  root "todos#index"

  # RESTful リソースルーティング
  # resources: Todoリソースに対する標準的なCRUD操作のルートを自動生成
  # 生成されるルート:
  #   GET    /todos          -> todos#index   (一覧表示)
  #   GET    /todos/new      -> todos#new     (新規作成フォーム)
  #   POST   /todos          -> todos#create  (作成処理)
  #   GET    /todos/:id      -> todos#show    (詳細表示)
  #   GET    /todos/:id/edit -> todos#edit    (編集フォーム)
  #   PATCH  /todos/:id      -> todos#update  (更新処理)
  #   DELETE /todos/:id      -> todos#destroy (削除処理)
  resources :todos do
    # カスタムメンバールート: 特定のTodoに対するカスタムアクション
    # member: 個別のリソース（:idが必要）に対するアクション
    member do
      # PATCH /todos/:id/toggle_completion -> todos#toggle_completion
      # Todoの完了/未完了を切り替えるカスタムアクション
      # PATCHメソッド: リソースの部分的な更新に使用（RESTful設計）
      patch :toggle_completion
    end
  end
end
