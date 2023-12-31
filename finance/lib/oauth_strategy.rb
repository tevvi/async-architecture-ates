require 'omniauth-oauth2'

module OmniAuth
  module Strategies
    class Keepa < OmniAuth::Strategies::OAuth2
      option :name, :keepa

      option :client_options, {
        :site => "http://auth:3000",
        :authorize_url => "http://localhost:3000/oauth/authorize"
      }

      uid { raw_info["public_id"] }

      info do
        {
          :email => raw_info["email"],
          :role => raw_info["role"],
          :public_id => raw_info["public_id"]
        }
      end

      def raw_info
        @raw_info ||= access_token.get('/accounts/current').parsed
      end
    end
  end
end