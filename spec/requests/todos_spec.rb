# Todosコントローラーのリクエストテスト
# type: :request - HTTPリクエストをテスト
# コントローラーの動作を統合的にテスト
require 'rails_helper'

RSpec.describe "Todos", type: :request do
  # HTTP Basic認証のヘッダーを生成
  # Base64エンコードで "username:password" を作成
  let(:auth_headers) do
    {
      'Authorization' => ActionController::HttpAuthentication::Basic.encode_credentials('admin', 'password')
    }
  end

  # ============================================
  # GET /todos (index)
  # ============================================
  describe "GET /todos" do
    let!(:todos) { create_list(:todo, 3) }  # 3つのTodoを作成

    context '認証済みの場合' do
      it '正常にレスポンスが返ること' do
        # get: GETリクエストを送信
        # headers: HTTPヘッダーを指定
        get todos_path, headers: auth_headers

        # expect(response): レスポンスを検証
        # to have_http_status(:success): 200番台のステータスコード
        expect(response).to have_http_status(:success)
      end

      it 'Todo一覧が表示されること' do
        get todos_path, headers: auth_headers
        # response.body: レスポンスのHTML
        # include: 文字列が含まれるか
        todos.each do |todo|
          expect(response.body).to include(todo.title)
        end
      end
    end

    context '認証なしの場合' do
      it '401 Unauthorizedが返ること' do
        get todos_path
        expect(response).to have_http_status(:unauthorized)
      end
    end
  end

  # ============================================
  # GET /todos/:id (show)
  # ============================================
  describe "GET /todos/:id" do
    let(:todo) { create(:todo) }

    context '認証済みの場合' do
      it '正常にレスポンスが返ること' do
        get todo_path(todo), headers: auth_headers
        expect(response).to have_http_status(:success)
      end

      it 'Todoの詳細が表示されること' do
        get todo_path(todo), headers: auth_headers
        expect(response.body).to include(todo.title)
        expect(response.body).to include(todo.description)
      end
    end
  end

  # ============================================
  # GET /todos/new (new)
  # ============================================
  describe "GET /todos/new" do
    context '認証済みの場合' do
      it '正常にレスポンスが返ること' do
        get new_todo_path, headers: auth_headers
        expect(response).to have_http_status(:success)
      end

      it '新規作成フォームが表示されること' do
        get new_todo_path, headers: auth_headers
        expect(response.body).to include('新しいTodo作成')
      end
    end
  end

  # ============================================
  # POST /todos (create)
  # ============================================
  describe "POST /todos" do
    context '認証済みで有効なパラメータの場合' do
      let(:valid_params) do
        { todo: { title: 'New Todo', description: 'Description' } }
      end

      it 'Todoが作成されること' do
        # expect { ... }.to change { ... }: 状態変化を検証
        # by(1): 1増えることを期待
        expect {
          post todos_path, params: valid_params, headers: auth_headers
        }.to change { Todo.count }.by(1)
      end

      it '詳細ページにリダイレクトすること' do
        post todos_path, params: valid_params, headers: auth_headers
        # follow_redirect!: リダイレクトを追跡
        expect(response).to have_http_status(:redirect)
        follow_redirect!
        expect(response.body).to include('New Todo')
      end
    end

    context '認証済みで無効なパラメータの場合' do
      let(:invalid_params) do
        { todo: { title: 'ab' } }  # 3文字未満（バリデーションエラー）
      end

      it 'Todoが作成されないこと' do
        expect {
          post todos_path, params: invalid_params, headers: auth_headers
        }.not_to change { Todo.count }
      end

      it 'エラーメッセージが表示されること' do
        post todos_path, params: invalid_params, headers: auth_headers
        expect(response.body).to include('エラー')
      end
    end
  end

  # ============================================
  # GET /todos/:id/edit (edit)
  # ============================================
  describe "GET /todos/:id/edit" do
    let(:todo) { create(:todo) }

    context '認証済みの場合' do
      it '正常にレスポンスが返ること' do
        get edit_todo_path(todo), headers: auth_headers
        expect(response).to have_http_status(:success)
      end

      it '編集フォームが表示されること' do
        get edit_todo_path(todo), headers: auth_headers
        expect(response.body).to include('Todo編集')
        expect(response.body).to include(todo.title)
      end
    end
  end

  # ============================================
  # PATCH /todos/:id (update)
  # ============================================
  describe "PATCH /todos/:id" do
    let(:todo) { create(:todo) }

    context '認証済みで有効なパラメータの場合' do
      let(:valid_params) do
        { todo: { title: 'Updated Title' } }
      end

      it 'Todoが更新されること' do
        patch todo_path(todo), params: valid_params, headers: auth_headers
        todo.reload
        expect(todo.title).to eq('Updated Title')
      end

      it '詳細ページにリダイレクトすること' do
        patch todo_path(todo), params: valid_params, headers: auth_headers
        expect(response).to have_http_status(:redirect)
      end
    end

    context '認証済みで無効なパラメータの場合' do
      let(:invalid_params) do
        { todo: { title: 'ab' } }
      end

      it 'Todoが更新されないこと' do
        original_title = todo.title
        patch todo_path(todo), params: invalid_params, headers: auth_headers
        todo.reload
        expect(todo.title).to eq(original_title)
      end
    end
  end

  # ============================================
  # DELETE /todos/:id (destroy)
  # ============================================
  describe "DELETE /todos/:id" do
    let!(:todo) { create(:todo) }

    context '認証済みの場合' do
      it 'Todoが削除されること' do
        expect {
          delete todo_path(todo), headers: auth_headers
        }.to change { Todo.count }.by(-1)
      end

      it '一覧ページにリダイレクトすること' do
        delete todo_path(todo), headers: auth_headers
        expect(response).to have_http_status(:redirect)
        expect(response).to redirect_to(todos_path)
      end
    end
  end

  # ============================================
  # PATCH /todos/:id/toggle_completion (toggle_completion)
  # ============================================
  describe "PATCH /todos/:id/toggle_completion" do
    context '未完了のTodoの場合' do
      let(:incomplete_todo) { create(:todo, :incomplete) }

      it '完了状態に切り替わること' do
        patch toggle_completion_todo_path(incomplete_todo), headers: auth_headers
        incomplete_todo.reload
        expect(incomplete_todo.completed).to be true
      end
    end

    context '完了済みのTodoの場合' do
      let(:completed_todo) { create(:todo, :completed) }

      it '未完了状態に切り替わること' do
        patch toggle_completion_todo_path(completed_todo), headers: auth_headers
        completed_todo.reload
        expect(completed_todo.completed).to be false
      end
    end
  end
end
