require_relative "circleci"

include Clockwork

API_TOKEN = ENV["CIRCLECI_API_TOKEN"]
USERNAME = ENV["CIRCLECI_USERNAME"]
PROJECT = ENV["CIRCLECI_PROJECT"]
BRANCHES_TO_IGNORE = (ENV["BRANCHES_TO_IGNORE"] || "").split
BRANCHES_THAT_DEPLOY = (ENV["BRANCHES_THAT_DEPLOY"] || "").split

LOG = Logger.new(STDOUT)
LOG.level = Logger::WARN

def log_build(build, action)
  LOG.warn("Build: #{build['build_num']} #{build['branch']} #{action}")
end

handler do |job|
  circleci = CircleCi.new(API_TOKEN, USERNAME, PROJECT)

  LOG.info("Starting Job: #{job}")

  # Build the hash of branches => builds.
  branch_builds = {}
  circleci.recent_builds.each do |build|
    next if build["lifecycle"] == "finished" || build["lifecycle"] == "not_run"

    excluded = false

    case
    when BRANCHES_TO_IGNORE.include?(build["branch"])
      log_build(build, "ignoring")
      excluded = true
    when BRANCHES_THAT_DEPLOY.include?(build["branch"]) && build["lifecycle"] == "running"
      build = circleci.get_build(build["build_num"])
      if build["steps"].any? { |step| step["actions"].any? { |action| action["type"] == "deploy" } }
        log_build(build, "ignoring because it's in deployment stage")
        excluded = true
      end
    end

    (branch_builds[build["branch"]] ||= []) << build unless excluded
  end

  branch_builds.each do |branch, builds|
    # Sort the builds of the branch oldest to newest.
    builds.sort_by! { |build| build["build_num"] }

    # Remove the last build for each branch, we want to keep it.
    log_build(builds.last, "keeping")
    builds.pop

    # Cancel the remaining builds.
    builds.each do |build|
      log_build(build, "canceling")
      circleci.cancel_build(build["build_num"])
    end
  end

  LOG.info("Finished Job: #{job}")
end

every(20.seconds, "cancel circleci builds")

LOG.info("Started")
