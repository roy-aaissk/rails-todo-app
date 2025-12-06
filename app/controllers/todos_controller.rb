# TodosController
# RESTful設計に基づくTodoリソースのコントローラー
# MVCのC（Controller）：ユーザーリクエストを受け取り、モデルとビューを調整
# ApplicationControllerを継承することで、HTTP Basic認証が適用される
class TodosController < ApplicationController
  # before_action: 指定したアクション実行前に特定のメソッドを実行
  # set_todo: Todoを取得するメソッド（下記で定義）
  # only: 特定のアクションでのみ実行（show、edit、update、destroy、toggle_completion）
  # DRY原則：同じコード（Todo.find）を繰り返さない
  before_action :set_todo, only: [:show, :edit, :update, :destroy, :toggle_completion]

  # ============================================
  # RESTful CRUD アクション
  # ============================================

  # GET /todos
  # Todoの一覧表示アクション
  def index
    # ActiveRecordのクエリメソッドをチェーン
    # recent: 新しい順にソート（モデルで定義したスコープ）
    # @todos: インスタンス変数（@付き）はビューで利用可能
    @todos = Todo.recent

    # ビューの描画
    # Railsの規約：アクション名と同じビューを自動的に探す
    # この場合：app/views/todos/index.html.erb
    # render は省略可能（Railsが自動的に実行）
  end

  # GET /todos/:id
  # 特定のTodoの詳細表示アクション
  def show
    # @todo は before_action の set_todo で設定済み
    # 何もしなくてもビューで @todo が利用可能
  end

  # GET /todos/new
  # 新規Todo作成フォーム表示アクション
  def new
    # 新しいTodoオブジェクトを作成（まだ保存していない）
    # ビューのフォームヘルパーがこのオブジェクトを使用
    # build: newと同じ（モデルのインスタンスを作成）
    @todo = Todo.new
  end

  # POST /todos
  # 新規Todo作成処理アクション
  # フォームから送信されたデータを受け取り、データベースに保存
  def create
    # Todo.new: 新しいTodoオブジェクトを作成
    # todo_params: Strong Parametersで安全にパラメータを取得（下記で定義）
    @todo = Todo.new(todo_params)

    # save: データベースに保存を試みる
    # バリデーション成功時：true を返し、データベースに保存
    # バリデーション失敗時：false を返し、保存しない
    if @todo.save
      # 成功時の処理
      # redirect_to: 指定したURLにリダイレクト
      # @todo: Railsが自動的に todo_path(@todo) に変換
      # notice: フラッシュメッセージ（一時的なメッセージ）
      redirect_to @todo, notice: 'Todoが正常に作成されました。'
    else
      # 失敗時の処理
      # render: ビューを描画（リダイレクトせず、同じリクエスト内で表示）
      # :new: new.html.erbを表示
      # status: HTTPステータスコード（422: Unprocessable Entity）
      # なぜrenderなのか：
      #   1. @todoにエラー情報が含まれている
      #   2. フォームを再表示してエラーメッセージを表示
      #   3. リダイレクトすると@todoが失われる
      render :new, status: :unprocessable_entity
    end
  end

  # GET /todos/:id/edit
  # Todo編集フォーム表示アクション
  def edit
    # @todo は before_action の set_todo で設定済み
    # ビューのフォームヘルパーが@todoの現在の値を表示
  end

  # PATCH/PUT /todos/:id
  # Todo更新処理アクション
  def update
    # update: 属性を更新してデータベースに保存
    # バリデーション成功時：true を返し、更新
    # バリデーション失敗時：false を返し、更新しない
    if @todo.update(todo_params)
      # 成功時：詳細ページにリダイレクト
      redirect_to @todo, notice: 'Todoが正常に更新されました。'
    else
      # 失敗時：編集フォームを再表示（エラーメッセージ付き）
      render :edit, status: :unprocessable_entity
    end
  end

  # DELETE /todos/:id
  # Todo削除処理アクション
  def destroy
    # destroy: データベースからレコードを削除
    # 戻り値：削除されたオブジェクト（freezeされている）
    @todo.destroy

    # 一覧ページにリダイレクト
    # todos_path: /todos のURL（一覧ページ）
    # notice: 削除成功メッセージ
    redirect_to todos_path, notice: 'Todoが正常に削除されました。'
  end

  # ============================================
  # カスタムアクション
  # ============================================

  # PATCH /todos/:id/toggle_completion
  # Todoの完了/未完了を切り替えるカスタムアクション
  # RESTful設計の拡張：ビジネスロジックに特化したアクション
  def toggle_completion
    # toggle_completion!: モデルで定義したドメインメソッド
    # ビジネスロジックはモデルに配置（Fat Model, Skinny Controller）
    if @todo.toggle_completion!
      # 成功時：一覧ページにリダイレクト
      redirect_to todos_path, notice: "Todoのステータスが#{@todo.status}に変更されました。"
    else
      # 失敗時：一覧ページにリダイレクト（エラーメッセージ付き）
      redirect_to todos_path, alert: 'ステータスの変更に失敗しました。'
    end
  end

  private

  # ============================================
  # プライベートメソッド
  # ============================================

  # 特定のTodoを取得するメソッド
  # before_actionで使用
  # DRY原則：繰り返しを避ける
  def set_todo
    # find: IDでレコードを検索
    # params[:id]: URLから取得したTodoのID
    # 見つからない場合：ActiveRecord::RecordNotFound 例外が発生
    # Railsが自動的に404エラーページを表示
    @todo = Todo.find(params[:id])
  end

  # Strong Parameters
  # セキュリティ機能：ユーザーが送信できるパラメータを制限
  # マスアサインメント脆弱性を防ぐ
  #
  # マスアサインメント脆弱性とは：
  #   悪意のあるユーザーが想定外のパラメータを送信し、
  #   データベースを不正に操作する攻撃
  #
  # 例：
  #   User.new(params[:user]) # 危険！
  #   User.new(user_params)   # 安全（Strong Parameters使用）
  def todo_params
    # require: 必須パラメータのキーを指定
    # params[:todo] が存在しない場合、エラーを発生
    #
    # permit: 許可する属性を指定
    # :title と :description のみ許可
    # それ以外の属性は除外される
    #
    # なぜcompletedとcompleted_atを許可しないのか：
    #   ビジネスロジックで管理すべきだから
    #   ユーザーが直接設定すべきではない
    #   toggle_completion アクションで適切に設定
    params.require(:todo).permit(:title, :description)
  end
end
