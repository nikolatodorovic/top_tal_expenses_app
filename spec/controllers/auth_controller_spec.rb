require 'rails_helper'

describe AuthController do

  # because of the jBuilder I need to render views
  render_views

  describe 'POST #register' do

    context 'with valid credentials' do

      it 'returns user id' do
        #build a user but does not save it into the database
        user = build(:user_regular)
        post :register, { email: user.email, password: user.password, format: :json }
        expect(response.status).to eq 200
        parsed_response = JSON.parse response.body
        expect(parsed_response['user']['id']).to_not be_nil
      end

    end

    context 'with invalid credentials' do

      it 'does not have email' do
        post :register, { password: "pass", format: :json }
        expect(response.status).to eq 401
        parsed_response = JSON.parse response.body
        expect(parsed_response['errors']).to_not be_nil
        expect(parsed_response['errors']['email'][0]).to eq "can't be blank"
      end

      it 'does not have password' do
        post :register, { email: "email@email.com", format: :json }
        expect(response.status).to eq 401
        parsed_response = JSON.parse response.body
        expect(parsed_response['errors']).to_not be_nil
        expect(parsed_response['errors']['password'][0]).to eq "can't be blank"
      end

    end

  end


  describe 'POST #authenticate' do

    context 'with valid credentials' do

      it 'returns token' do
        user = create(:user_regular)
        post :authenticate, { email: user.email, password: user.password, format: :json }
        expect(response.status).to eq 200
        parsed_response = JSON.parse response.body
        expect(parsed_response['token']).to_not be_nil
      end

      it 'returns token with 3 parts separated by comas' do
        user = create(:user_regular)
        post :authenticate, { email: user.email, password: user.password, format: :json }
        expect(response.status).to eq 200
        parsed_response = JSON.parse response.body
        expect(parsed_response['token'].split('.').count).to eq 3
      end

      it 'returns first name and last name of the user' do
        user = create(:user_regular)
        post :authenticate, { email: user.email, password: user.password, format: :json }
        expect(response.status).to eq 200
        parsed_response = JSON.parse response.body
        expect(parsed_response['user']['first_name']).to eq user.first_name
        expect(parsed_response['user']['last_name']).to eq user.last_name
      end

    end

    context 'with invalid credentials' do

      it 'does not return token' do
        user = create(:user_regular)
        post :authenticate, { email: "no_" + user.email, password: user.password, format: :json }
        expect(response.status).to eq 401
      end

    end

  end

  describe 'POST #token_status' do

    context 'with valid token' do

      it 'returns OK code' do
        user = create(:user_regular)
        token = AuthToken.issue_token({ user_id: user.id })
        post :token_status, { token: token, format: :json }
        expect(response.status).to eq 200
      end

    end

  end

end
