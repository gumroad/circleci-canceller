require_relative "circleci"

module JobCancel
  module_function

  def perform(api_token, username, project, branches_to_ignore, branches_to_deploy, branches_with_safe_time)
    circleci = CircleCi.new(api_token, username, project)

    # Build the hash of branches => builds.
    branch_builds = {}
    circleci.recent_builds.each do |build|
      next if build["lifecycle"] == "finished" || build["lifecycle"] == "not_run"

      excluded = false

      # exclude builds for ignored branches
      if branches_to_ignore.include?(build["branch"])
        log_build(build, "ignoring")
        excluded = true
      end

      # exclude builds for branches with safe times, if they've been building for more than their safe time
      safe_time = branches_with_safe_time[build["branch"]]
      if build["start_time"] && safe_time && Time.now >= Time.parse(build["start_time"]) + safe_time.to_i.minutes
        log_build(build, "ignoring because it has been running for more than #{safe_time} minutes.")
        excluded = true
      end

      # exclude builds that are in the deployment phase
      if !excluded && branches_to_deploy.include?(build["branch"]) && build["lifecycle"] == "running"
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

      # Remove the last build for each branch if it's not merged into deploy, we want to keep it running.
      unless circleci.is_build_in_deploy(builds.last["build_num"])
        log_build(builds.last, "keeping")
        builds.pop
      end

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
