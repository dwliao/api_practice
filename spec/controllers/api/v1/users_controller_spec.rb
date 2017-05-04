require 'rails_helper'

RSpec.describe Api::V1::UsersController, type: :controller do

  before(:each) { request.headers['Accept'] = "application/vnd.marketplace.v1" }

  describe "GET #show" do
    before(:each) do
      @user = FactoryGirl.create :user
      get :show, params: { id: 1 }, format: :json
    end

    it "returns the information about a reporter on a hash" do
      user_response = JSON.parse(response.body, symbolize_names: true)
      expect(user_response[:email]).to eq @user.email
    end

    it { expect(response).to have_http_status(200) }
  end

  describe "POST #create" do
    context "when is successfully created" do
      before(:each) do
        @user_attributes = FactoryGirl.attributes_for :user
        post :create, params: { user: @user_attributes }, format: :json
      end

      it "renders the json representation for the user record just created" do
        user_response = JSON.parse(response.body, symbolize_names: true)
        expect(user_response[:email]).to eq @user_attributes[:email]
      end

      it { expect(response).to have_http_status(201) }
    end

    context "when is not created" do
      before(:each) do
        #notice I'm not including the email
        @invalid_user_attributes = { password: "12345678",
                                     password_confirmation: "12345678" }
        post :create, params: { user: @invalid_user_attributes }, format: :json
      end

      it "renders an errors json" do
        user_response = JSON.parse(response.body, symbolize_names: true)
        expect(user_response).to have_key(:errors)
      end

      it "renders the json errors on why the user could not be created" do
        user_response = JSON.parse(response.body, symbolize_names: true)
        expect(user_response[:errors][:email]).to include "can't be blank"
      end

      it { expect(response).to have_http_status(422) }
    end
  end

  describe "PUT/PATCH #update" do
    context "when is successfully updated" do
      before(:each) do
        @user = FactoryGirl.create :user
        put :update, params: { id: @user.id,
                              user: { email: "newmail@example.com" } }, format: :json
      end

      it "renders the json representation for the updated user" do
        user_response = JSON.parse(response.body, symbolize_names: true)
        expect(user_response[:email]).to eq("newmail@example.com")
      end

      it { expect(response).to have_http_status(200) }

      context "when is not created" do
        before(:each) do
          @user = FactoryGirl.create :user
          put :update, params: { id: @user.id,
                                 user: { email: "bademail.com" } }, format: :json
        end

        it "renders an errors json" do
          user_response = JSON.parse(response.body, symbolize_names: true)
          expect(user_response).to have_key(:errors)
        end

        it "renders the json errors on why the user could not be created" do
          user_response = JSON.parse(response.body, symbolize_names: true)
          expect(user_response[:errors][:email]).to include "is invalid"
        end

        it { expect(response).to have_http_status(422) }
      end
    end
  end

  describe "DELETE #destroy" do
    before(:each) do
      @user = FactoryGirl.create :user
      delete :destroy, params: { id: @user.id }, format: :json
    end

    it { expect(response).to have_http_status(204) }
  end
end
