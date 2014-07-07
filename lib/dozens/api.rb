require 'httparty'

module Dozens
  class API
    include HTTParty

    format :json

    base_uri 'http://dozens.jp/api'
    headers 'Content-Type' => 'application/json'
    headers 'Accept' => 'application/json'

    def initialize(user, key)
      @user = user
      @key = key

      r = self.class.get("/authorize.json", :headers => { "X-Auth-User" => @user, "X-Auth-Key" => @key })
      @token = r['auth_token']
    end

    def update_record(record_id, new_value, ttl=60)
      options = { :body => { "content" => new_value, "ttl" => ttl }.to_json, :headers => authorization_headers }
      self.class.post("/record/update/#{ record_id }.json", options)
    end

    def get_record_list(zone_name)
      self.class.get("/record/#{ zone_name }.json", { :headers => authorization_headers })
    end

    private

    def authorization_headers
      { "X-Auth-Token" => @token }
    end
  end
end
