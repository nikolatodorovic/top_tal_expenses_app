require 'rails_helper'

describe Api::UsersController do

  # because of the jBuilder I need to render views
  render_views

  describe 'GET #index' do

    context 'is not authenticated' do
      it 'returns unauthorized' do
        get :index, { format: :json }
        expect(response.status).to eq 401
      end
    end

    context 'with some data' do
      it 'returns some users' do
        FactoryGirl.create_list(:user_regular, 3)
        FactoryGirl.create_list(:user_admin, 2)
        user = create(:user_manager)
        token = AuthToken.issue_token({ user_id: user.id })
        request.env['HTTP_AUTHORIZATION'] = token
        get :index, { format: :json }
        expect(response.status).to eq 200
        parsed_response = JSON.parse response.body
        expect(parsed_response.count).to be 6
      end
    end

    context 'user regular' do
      it 'does not have permissions' do
        user = create(:user_regular)
        token = AuthToken.issue_token({ user_id: user.id })
        request.env['HTTP_AUTHORIZATION'] = token
        get :index, { format: :json }
        expect(response.status).to eq 403
      end
    end

  end

  describe 'POST #create' do

    context 'creates new user' do
      it 'has one more user in the database' do
        user = create(:user_admin)
        expect(User.all.count).to eq 1
        token = AuthToken.issue_token({ user_id: user.id })
        request.env['HTTP_AUTHORIZATION'] = token
        user_new = build(:user_regular)
        post :create, { user: {email: user_new.email, password: user_new.password, first_name: user_new.first_name, last_name: user_new.last_name}, format: :json }
        expect(response.status).to eq 201
        expect(User.all.count).to eq 2
      end
    end

  end

  describe 'POST #update' do

    context 'update an existing user' do

      it 'has the same number of users in the database' do
        user = create(:user_manager)
        user_old = create(:user_regular)
        expect(User.all.count).to eq 2
        token = AuthToken.issue_token({ user_id: user.id })
        request.env['HTTP_AUTHORIZATION'] = token
        user_new = build(:user_regular)
        put :update, { id: user_old.id, user: {first_name: user_new.first_name, last_name: user_new.last_name, password: user_new.password}, format: :json }
        expect(response.status).to eq 204
        expect(User.all.count).to eq 2
      end

      it 'has different first name' do
        user = create(:user_manager)
        user_old = create(:user_regular)
        token = AuthToken.issue_token({ user_id: user.id })
        request.env['HTTP_AUTHORIZATION'] = token
        user_new = build(:user_regular)
        put :update, { id: user_old.id, user: {first_name: user_new.first_name, last_name: user_new.last_name, password: user_new.password}, format: :json }
        expect(response.status).to eq 204
        parsed_response = JSON.parse response.body
        expect(parsed_response['first_name']).not_to eq user_old.first_name
      end

    end

  end

end
