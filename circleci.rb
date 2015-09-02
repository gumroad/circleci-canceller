require "rest-client"
require "json"

class CircleCi

  def initialize(api_token, username, project)
    @api_token = api_token
    @username = username
    @project = project
    @base = "https://circleci.com/api/v1"
  end

  def recent_builds
    response = RestClient.get("#{@base}/project/#{@username}/#{@project}", options)
    JSON.parse(response.to_str)
  end

  def get_build(build_number)
    response = RestClient.get("#{@base}/project/#{@username}/#{@project}/#{build_number}", options)
    JSON.parse(response.to_str)
  end

  def cancel_build(build_number)
    response = RestClient.post("#{@base}/project/#{@username}/#{@project}/#{build_number}/cancel", nil, options)
    JSON.parse(response.to_str)
  end

  def is_build_in_deploy(build_number)
    revision = get_build(build_number)["vcs_revision"]

    circleci.recent_builds.any? do |build|
      build["vcs_revision"] == revision && build["branch"] == "deploy"
    end
  end

  private

  def options
    {
      accept: :json,
      params: {
        "circle-token" => @api_token
      }
    }
  end
end
