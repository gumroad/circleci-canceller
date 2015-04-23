# GircleCI

A clockwork application that cancels superfluous builds in queue or running.

## Features

* Collects new build state frequently, once every 20 seconds.
* Cancels builds if a newer build is queued for the same branch.
* Ignores select branches.
* Ignores builds that are already in or have completed the deployment phase.

## Usage

Deploy to Heroku with the following environment variables:

* CIRCLECI_API_TOKEN e.g. `a17098...`
* CIRCLECI_USERNAME e.g. `gumroad`
* CIRCLECI_PROJECT e.g. `web`
* BRANCHES_TO_IGNORE space delimited e.g. `staging master`
* BRANCHES_THAT_DEPLOY space delimited e.g. `deploy`
