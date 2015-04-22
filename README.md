# CircleCI Cancel

A clockwork application that cancels superfluous builds in queue or running. Builds are cancelled if there is a newer build queued for the same branch.

## Usage

Deploy to Heroku with the following environment variables:

* CIRCLECI_API_TOKEN e.g. `a17098...`
* CIRCLECI_USERNAME e.g. `gumroad`
* CIRCLECI_PROJECT e.g. `web`