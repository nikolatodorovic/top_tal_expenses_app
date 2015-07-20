require 'rails_helper'

describe Api::ExpensesController do

  # because of the jBuilder I need to render views
  render_views

  describe 'GET #index' do

    context 'is not authenticated' do
      it 'returns unauthorized' do
        get :index, { format: :json }
        expect(response.status).to eq 401
      end
    end

    context 'without data' do
      it 'returns no expenses' do
        user = create(:user_regular)
        token = AuthToken.issue_token({ user_id: user.id })
        request.env['HTTP_AUTHORIZATION'] = token
        get :index, { format: :json }
        expect(response.status).to eq 200
        expect(response.body).to eq('[]')
      end
    end

    context 'with some data' do
      it 'returns one expense' do
        expense = create(:expense)
        user = expense.user
        token = AuthToken.issue_token({ user_id: user.id })
        request.env['HTTP_AUTHORIZATION'] = token
        get :index, { format: :json }
        expect(response.status).to eq 200
        parsed_response = JSON.parse response.body
        expect(parsed_response.count).to be 1
      end
    end

    context 'user manager' do
      it 'does not have permissions' do
        user = create(:user_manager)
        token = AuthToken.issue_token({ user_id: user.id })
        request.env['HTTP_AUTHORIZATION'] = token
        get :index, { format: :json }
        expect(response.status).to eq 403
      end
    end

  end

  describe 'GET #show' do

    context 'is not authenticated' do
      it 'returns unauthorized' do
        expense = create(:expense)
        get :show, { id: expense.id, format: :json }
        expect(response.status).to eq 401
      end
    end

    context 'user manager' do
      it 'does not have permissions' do
        expense = create(:expense)
        user = create(:user_manager)
        expense.user = user
        token = AuthToken.issue_token({ user_id: user.id })
        request.env['HTTP_AUTHORIZATION'] = token
        get :show, { id: expense.id, format: :json }
        expect(response.status).to eq 403
        parsed_response = JSON.parse response.body
        expect(parsed_response['error']).to eq "Doesn't have permissions"
      end
    end

    context 'user admin' do
      it 'has permissions on other user\'s expense' do
        expense = create(:expense)
        user = create(:user_admin)
        token = AuthToken.issue_token({ user_id: user.id })
        request.env['HTTP_AUTHORIZATION'] = token
        get :show, { id: expense.id, format: :json }
        expect(response.status).to eq 200
        parsed_response = JSON.parse response.body
        expect(parsed_response['amount']).to eq expense.amount.to_s
      end
    end

    context 'user regular' do
      it 'does not have permissions on other user\'s expense' do
        expense = create(:expense)
        user = create(:user_regular)
        expense.user = user
        token = AuthToken.issue_token({ user_id: user.id })
        request.env['HTTP_AUTHORIZATION'] = token
        get :show, { id: expense.id, format: :json }
        expect(response.status).to eq 403
        parsed_response = JSON.parse response.body
        expect(parsed_response['error']).to eq "Doesn't have permissions"
      end
    end

  end
  

  describe 'POST #create' do

    context 'creates new expense' do
      it 'has one more expense in the database' do
        expense = create(:expense)
        user = create(:user_admin)
        expense.user = user
        expect(Expense.all.count).to eq 1
        token = AuthToken.issue_token({ user_id: user.id })
        request.env['HTTP_AUTHORIZATION'] = token
        expense_new = build(:expense)
        post :create, { expense: {amount: expense_new.amount, for_timeday: expense_new.for_timeday, description: expense_new.description}, format: :json }
        expect(response.status).to eq 201
        expect(Expense.all.count).to eq 2
      end
    end

  end


  describe 'POST #update' do

    context 'update an existing expense' do

      it 'has the same number of expenses in the database' do
        expense_old = create(:expense)
        user = create(:user_admin)
        expense_old.user = user
        expect(Expense.all.count).to eq 1
        token = AuthToken.issue_token({ user_id: user.id })
        request.env['HTTP_AUTHORIZATION'] = token
        expense_new = build(:expense)
        put :update, { id: expense_old.id, expense: {amount: expense_new.amount, for_timeday: expense_new.for_timeday, description: expense_new.description}, format: :json }
        expect(response.status).to eq 204
        expect(Expense.all.count).to eq 1
      end

      it 'has different amount' do
        expense_old = create(:expense)
        user = create(:user_admin)
        expense_old.user = user
        expect(Expense.all.count).to eq 1
        token = AuthToken.issue_token({ user_id: user.id })
        request.env['HTTP_AUTHORIZATION'] = token
        expense_new = build(:expense)
        put :update, { id: expense_old.id, expense: {amount: expense_new.amount, for_timeday: expense_new.for_timeday, description: expense_new.description}, format: :json }
        expect(response.status).to eq 204
        parsed_response = JSON.parse response.body
        expect(parsed_response['amount']).not_to eq expense_old.amount.to_s
      end

    end

  end

end