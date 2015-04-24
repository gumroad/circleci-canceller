# GircleCI

A clockwork application that cancels superfluous builds in queue or running.

## Features

* Collects new build state frequently, once every 20 seconds.
* Cancels builds if a newer build is queued for the same branch.
* Ignores select branches.
* Ignores builds that are already in or have completed the deployment phase.

## Usage

Deploy to Heroku with the following environment variables:

* CIRCLECI_USERNAME e.g. `gumroad`
* CIRCLECI_PROJECTS e.g. `web api`
* CIRCLECI_API_TOKEN_[project] e.g. `a17098...`
* BRANCHES_TO_IGNORE_[project] e.g. `master staging`
* BRANCHES_THAT_DEPLOY_[project] e.g. `deploy`

```bash
CIRCLECI_USERNAME=gumroad
CIRCLECI_PROJECTS=web api

CIRCLECI_API_TOKEN_web=a17098...
BRANCHES_TO_IGNORE_web=master staging
BRANCHES_THAT_DEPLOY_web=deploy

CIRCLECI_API_TOKEN_api=ba7698...
BRANCHES_THAT_DEPLOY_api=master
```
