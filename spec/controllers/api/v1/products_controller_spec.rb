require 'rails_helper'

RSpec.describe Api::V1::ProductsController, type: :controller do
  describe "GET #show" do
    before(:each) do
      @product = FactoryGirl.create :product
      get :show, params: { id: @product.id }
    end

    it "returns the information about a reporter on a hash" do
      product_response = json_response
      expect(product_response[:title]).to eq @product.title
    end

    it { expect(response).to have_http_status 200 }

    it "has the user as a embeded object" do
      product_response = json_response
      expect(product_response[:user][:email]).to eq @product.user.email
    end
  end

  describe "GET #index" do
    before(:each) do
      5.times { FactoryGirl.create :product }
      get :index
    end

    it "returns 5 records from the database" do
      products_response = json_response
      expect(products_response.length).to eq(5)
    end

    it { expect(response).to have_http_status 200 }

    it "returns the user object into each product" do
      products_response = json_response
      products_response.each do |product_response|
        expect(product_response[:user]).to be_present
      end
    end
  end

  describe "POST #create" do
    context "when is successfully created" do
      before(:each) do
        user = FactoryGirl.create :user
       @product_attributes = FactoryGirl.attributes_for :product
        api_authorization_header user.auth_token
        post :create, params: { user_id: user.id, product: @product_attributes }
      end

      it "renders the json representation for the product record just created" do
        product_response = json_response
        expect(product_response[:title]).to eql @product_attributes[:title]
      end

      it { expect(response).to have_http_status 201 }
    end

    context "when is not created" do
      before(:each) do
        user = FactoryGirl.create :user
        @invalid_product_attributes = { title: "Smart TV", price: "Twelve dollars" }
        api_authorization_header user.auth_token
        post :create, params: { user_id: user.id, product: @invalid_product_attributes }
      end

      it "renders an errors json" do
        product_response = json_response
        expect(product_response).to have_key(:errors)
      end

      it "renders the json errors on why the user could not create" do
        product_response = json_response
        expect(product_response[:errors][:price]).to include "is not a number"
      end

      it { expect(response).to have_http_status 422 }
    end
  end

  describe "PUT/PATCH #update" do
    before(:each) do
      @user = FactoryGirl.create :user
      @product = FactoryGirl.create :product, user: @user
      api_authorization_header @user.auth_token
    end

    context "when is successfully updated" do
      before (:each) do
        patch :update, params: { user_id: @user.id, id: @product.id,
                                 product: { title: "New TV" } }
      end

      it "renders the json representation for the updated" do
        product_response = json_response
        expect(product_response[:title]).to eq "New TV"
      end

      it { expect(response).to have_http_status 200 }
    end

    context "when is not updated" do
      before(:each) do
        patch :update, params: { user_id: @user.id, id: @product.id,
                                 product: { price: "two" } }
      end

      it "renders an error json" do
        product_response = json_response
        expect(product_response).to have_key(:errors)
      end

      it "renders the json errors on why the user could not update" do
        product_response = json_response
        expect(product_response[:errors][:price]).to include "is not a number"
      end

      it { expect(response).to have_http_status 422 }
    end
  end

  describe "DELETE #destroy" do
    before(:each) do
      @user = FactoryGirl.create :user
      @product = FactoryGirl.create :product, user: @user
      api_authorization_header @user.auth_token
      delete :destroy, params: { user_id: @user.id, id: @product.id }
    end

    it { expect(response).to have_http_status 204 }
  end

  describe "GET #index" do
    before(:each) do
      4.times { FactoryGirl.create :product }
    end

    context "when is not receiving any product_ids parameter" do
      before(:each) do
        get :index
      end

      it "returns 4 records from the database" do
        products_response = json_response
        expect(products_response.length).to eq(4)
      end

      it "returns the user object into each product" do
        products_response = json_response
        products_response.each do |product_response|
          expect(product_response[:user]).to be_present
        end
      end

      it { expect(response).to have_http_status 200 }
    end

    context "when product_ids parameter is sent" do
      before(:each) do
        @user = FactoryGirl.create :user
        3.times { FactoryGirl.create :product, user: @user }
        get :index, params: { product_ids: @user.product_ids }
      end

      it "returns just the products that belong to the user" do
        products_response = json_response
        products_response.each do |product_response|
          expect(product_response[:user][:email]).to eq @user.email
        end
      end
    end
  end
end
