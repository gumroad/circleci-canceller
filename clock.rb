require "clockwork"
require_relative "job_cancel"

USERNAME = ENV["CIRCLECI_USERNAME"]
PROJECTS = (ENV["CIRCLECI_PROJECTS"] || ENV["CIRCLECI_PROJECT"]).split
API_TOKEN = ENV["CIRCLECI_API_TOKEN"]

LOG = Logger.new(STDOUT)
LOG.level = Logger::INFO

module Clockwork
  configure do |config|
    config[:logger] = LOG
  end

  PROJECTS.each do |project|
    every(20.seconds, "cancel superfluous builds for project: #{project}") do
      api_token = ENV["CIRCLECI_API_TOKEN_#{project}"] || API_TOKEN
      branches_to_ignore = (ENV["BRANCHES_TO_IGNORE_#{project}"] || "").split
      branches_that_deploy = (ENV["BRANCHES_THAT_DEPLOY_#{project}"] || "").split
      JobCancel.perform(api_token, USERNAME, project, branches_to_ignore, branches_that_deploy)
    end
  end
end
