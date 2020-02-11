#!/usr/bin/env sh
set -eu
export GIT_PATH_CHECKED_OUT="${GITHUB_WORKSPACE}"
export DEPLOY_VERSION="${GITHUB_REF#refs/tags/}"
exec entrypoint-deploy-wordpress-plugin "${@}"
