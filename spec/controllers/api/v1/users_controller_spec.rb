require 'rails_helper'

RSpec.describe Api::V1::UsersController, type: :controller do

  describe "GET #show" do
    before(:each) do
      @user = FactoryGirl.create :user
      get :show, params: { id: @user.id }
    end

    it "returns the information about a reporter on a hash" do
      user_response = json_response
      expect(user_response[:email]).to eq @user.email
    end

    it { expect(response).to have_http_status(200) }

    it "has the product ids as an embeded object" do
      user_response = json_response
      expect(user_response[:product_ids]).to eq []
    end
  end

  describe "POST #create" do
    context "when is successfully created" do
      before(:each) do
        @user_attributes = FactoryGirl.attributes_for :user
        post :create, params: { user: @user_attributes }
      end

      it "renders the json representation for the user record just created" do
        user_response = json_response
        expect(user_response[:email]).to eq @user_attributes[:email]
      end

      it { expect(response).to have_http_status(201) }
    end

    context "when is not created" do
      before(:each) do
        #notice I'm not including the email
        @invalid_user_attributes = { password: "12345678",
                                     password_confirmation: "12345678" }
        post :create, params: { user: @invalid_user_attributes }
      end

      it "renders an errors json" do
        user_response = json_response
        expect(user_response).to have_key(:errors)
      end

      it "renders the json errors on why the user could not be created" do
        user_response = json_response
        expect(user_response[:errors][:email]).to include "can't be blank"
      end

      it { expect(response).to have_http_status(422) }
    end
  end

  describe "PUT/PATCH #update" do
    before(:each) do
      @user = FactoryGirl.create :user
      api_authorization_header(@user.auth_token)
    end
    context "when is successfully updated" do
      before(:each) do
        put :update, params: { id: @user.id,
                              user: { email: "newmail@example.com" } }
      end

      it "renders the json representation for the updated user" do
        user_response = json_response
        expect(user_response[:email]).to eq("newmail@example.com")
      end

      it { expect(response).to have_http_status(200) }

      context "when is not created" do
        before(:each) do

          put :update, params: { id: @user.id,
                                 user: { email: "bademail.com" } }
        end

        it "renders an errors json" do
          user_response = json_response
          expect(user_response).to have_key(:errors)
        end

        it "renders the json errors on why the user could not be created" do
          user_response = json_response
          expect(user_response[:errors][:email]).to include "is invalid"
        end

        it { expect(response).to have_http_status(422) }
      end
    end
  end

  describe "DELETE #destroy" do
    before(:each) do
      @user = FactoryGirl.create :user
      api_authorization_header(@user.auth_token)
      delete :destroy, params: { id: @user.id }
    end

    it { expect(response).to have_http_status(204) }
  end

end
