require 'api_constraints'

MarketPlaceApi::Application.routes.draw do
  # Api definition
  namespace :api, defaults: { format: :json },
                              constraints: { subdomain: 'api' }, path: '/' do
    scope module: :vi,
              constraints: ApiConstraints.new(version: 1, default: true) do
                # We are going to list our resources here
    end
  end
end
