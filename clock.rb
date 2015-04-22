require_relative "circleci"

include Clockwork

API_TOKEN = ENV["CIRCLECI_API_TOKEN"]
USERNAME = ENV["CIRCLECI_USERNAME"]
PROJECT = ENV["CIRCLECI_PROJECT"]

LOG = Logger.new(STDOUT)
LOG.level = Logger::WARN

handler do |job|
  circleci = CircleCi.new(API_TOKEN, USERNAME, PROJECT)

  LOG.info("Starting Job: #{job}")

  # Build the hash of branches => builds.
  branch_builds = {}
  circleci.recent_builds.each do |build|
    next if build["lifecycle"] == "finished"
    (branch_builds[build["branch"]] ||= []) << build
  end

  branch_builds.each do |branch, builds|
    # Sort the builds of the branch oldest to newest.
    builds.sort_by! { |build| build["build_num"] }

    # Remove the last build for each branch, we want to keep it.
    LOG.warn("Build: #{builds.last['build_num']} #{builds.last['branch']} keeping")
    builds.pop

    # Cancel the remaining builds.
    builds.each do |build|
      LOG.warn("Build: #{build['build_num']} #{build['branch']} canceling")
      circleci.cancel_build(build["build_num"])
    end
  end

  LOG.info("Finished Job: #{job}")
end

every(20.seconds, "cancel circleci builds")

LOG.info("Started")
