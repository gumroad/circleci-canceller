require_relative "circleci"

module JobCancel
  module_function

  def perform(api_token, username, project, branches_to_ignore, branches_to_deploy)
    circleci = CircleCi.new(api_token, username, project)

    # Build the hash of branches => builds.
    branch_builds = {}
    circleci.recent_builds.each do |build|
      next if build["lifecycle"] == "finished" || build["lifecycle"] == "not_run"

      excluded = false

      case
      when branches_to_ignore.include?(build["branch"])
        log_build(build, "ignoring")
        excluded = true
      when branches_to_deploy.include?(build["branch"]) && build["lifecycle"] == "running"
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
  end

  private_class_method
  def log_build(build, action)
    LOG.warn("Build: #{build['build_num']} #{build['branch']} #{action}")
  end
end
