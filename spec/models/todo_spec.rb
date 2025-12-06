# Todoモデルのテスト
# RSpec: Ruby用のテスティングフレームワーク
# type: :model - モデルテストであることを明示
require 'rails_helper'

RSpec.describe Todo, type: :model do
  # ============================================
  # バリデーションテスト
  # ============================================
  # Shoulda Matchers: バリデーションを簡潔にテスト
  describe 'バリデーション' do
    # subjectブロック: テスト対象のオブジェクトを定義
    # build: FactoryBotでオブジェクトを作成（保存しない）
    subject { build(:todo) }

    # titleのバリデーションテスト
    context 'titleカラム' do
      # 必須チェック
      it '必須であること' do
        todo = build(:todo, title: nil)
        expect(todo).not_to be_valid
        expect(todo.errors[:title]).to be_present
      end

      # 文字数制限
      it '3文字以上であること' do
        todo = build(:todo, title: 'ab')
        expect(todo).not_to be_valid
        expect(todo.errors[:title]).to include('は3文字以上で入力してください')
      end

      it '255文字以下であること' do
        todo = build(:todo, title: 'a' * 256)
        expect(todo).not_to be_valid
        expect(todo.errors[:title]).to include('は255文字以内で入力してください')
      end

      # 有効なデータの場合
      it '3〜255文字の場合は有効であること' do
        todo = build(:todo, title: 'abc')
        expect(todo).to be_valid
      end
    end

    # descriptionのバリデーションテスト
    context 'descriptionカラム' do
      it '任意であること' do
        todo = build(:todo, description: nil)
        expect(todo).to be_valid
      end

      it '1000文字以下であること' do
        todo = build(:todo, description: 'a' * 1000)
        expect(todo).to be_valid
      end

      it '1001文字の場合は無効であること' do
        todo = build(:todo, description: 'a' * 1001)
        expect(todo).not_to be_valid
        expect(todo.errors[:description]).to include('は1000文字以内で入力してください')
      end
    end

    # カスタムバリデーションテスト
    context 'completed_atの整合性' do
      it '完了済みでcompleted_atがnilの場合は無効' do
        todo = build(:todo, completed: true, completed_at: nil)
        expect(todo).not_to be_valid
        expect(todo.errors[:completed_at]).to include('完了日時を入力してください')
      end

      it '未完了でcompleted_atがある場合は無効' do
        todo = build(:todo, completed: false, completed_at: Time.current)
        expect(todo).not_to be_valid
        expect(todo.errors[:completed_at]).to include('未完了の場合は完了日時を設定できません')
      end
    end
  end

  # ============================================
  # スコープテスト
  # ============================================
  # スコープ: クエリメソッドのテスト
  describe 'スコープ' do
    # let!: 遅延評価しないlet（テスト実行前に必ず実行）
    # create: FactoryBotでデータベースに保存
    let!(:incomplete_todo1) { create(:todo, :incomplete) }
    let!(:incomplete_todo2) { create(:todo, :incomplete) }
    let!(:completed_todo1) { create(:todo, :completed) }
    let!(:completed_todo2) { create(:todo, :completed) }

    describe '.incomplete' do
      it '未完了のTodoのみを返すこと' do
        # expect: 期待値を定義
        # to: マッチャーを適用
        # match_array: 配列の要素が一致するかチェック（順序不問）
        expect(Todo.incomplete).to match_array([incomplete_todo1, incomplete_todo2])
      end
    end

    describe '.completed' do
      it '完了済みのTodoのみを返すこと' do
        expect(Todo.completed).to match_array([completed_todo1, completed_todo2])
      end
    end

    describe '.recent' do
      it '作成日時の降順で返すこと' do
        # 新しいTodoを作成
        newest_todo = create(:todo)
        # pluck: 特定のカラムの値を配列で取得
        expect(Todo.recent.pluck(:id).first).to eq(newest_todo.id)
      end
    end
  end

  # ============================================
  # ドメインメソッドテスト
  # ============================================
  # ビジネスロジックのテスト
  describe 'ドメインメソッド' do
    # let: 遅延評価される変数（使われるまで実行されない）
    let(:todo) { create(:todo, :incomplete) }

    describe '#mark_as_completed' do
      it 'Todoを完了状態にすること' do
        # 実行前の状態を確認
        expect(todo.completed).to be false
        expect(todo.completed_at).to be_nil

        # メソッド実行
        result = todo.mark_as_completed

        # 戻り値を確認
        expect(result).to be true

        # 状態変化を確認
        # reload: データベースから最新の状態を再読み込み
        todo.reload
        expect(todo.completed).to be true
        expect(todo.completed_at).to be_present
      end
    end

    describe '#mark_as_incomplete' do
      let(:completed_todo) { create(:todo, :completed) }

      it 'Todoを未完了状態にすること' do
        expect(completed_todo.completed).to be true

        result = completed_todo.mark_as_incomplete

        expect(result).to be true
        completed_todo.reload
        expect(completed_todo.completed).to be false
        expect(completed_todo.completed_at).to be_nil
      end
    end

    describe '#toggle_completion!' do
      context '未完了のTodoの場合' do
        it '完了状態に切り替わること' do
          expect { todo.toggle_completion! }
            .to change { todo.reload.completed }.from(false).to(true)
        end
      end

      context '完了済みのTodoの場合' do
        let(:completed_todo) { create(:todo, :completed) }

        it '未完了状態に切り替わること' do
          expect { completed_todo.toggle_completion! }
            .to change { completed_todo.reload.completed }.from(true).to(false)
        end
      end
    end

    describe '#status' do
      it '未完了の場合は"未完了"を返すこと' do
        expect(todo.status).to eq('未完了')
      end

      it '完了済みの場合は"完了"を返すこと' do
        completed_todo = create(:todo, :completed)
        expect(completed_todo.status).to eq('完了')
      end
    end

    describe '#formatted_completed_at' do
      it '未完了の場合はnilを返すこと' do
        expect(todo.formatted_completed_at).to be_nil
      end

      it '完了済みの場合はフォーマットされた日時を返すこと' do
        completed_at = Time.zone.parse('2025-01-15 10:30:00')
        completed_todo = create(:todo, completed: true, completed_at: completed_at)
        expect(completed_todo.formatted_completed_at).to eq('2025年01月15日 10:30')
      end
    end
  end
end
