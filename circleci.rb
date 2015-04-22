require "httparty"
require "json"

class CircleCi
  include HTTParty
  base_uri "https://circleci.com/api/v1"

  def initialize(api_token, username, project)
    @api_token = api_token
    @username = username
    @project = project
    @options = {
      "headers" => {
        "Accept" => "application/json"
      }
    }
  end

  def recent_builds
    response = self.class.get("/project/#{@username}/#{@project}?circle-token=#{@api_token}", @options)
    JSON.parse(response.body)
  end

  def cancel_build(build_number)
    response = self.class.post("/project/#{@username}/#{@project}/#{build_number}/cancel?circle-token=#{@api_token}", @options)
    JSON.parse(response.body)
  end
end
