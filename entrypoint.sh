#!/usr/bin/env sh
set -eu
export GIT_PATH_CHECKED_OUT="${GITHUB_WORKSPACE}"
export DEPLOY_VERSION="${GITHUB_REF#refs/tags/}"
if [ "${DEPLOY_VERSION}" = "${EXPECT_DEPLOY_VERSION_FOR_TEST}" ]; then
  export DEPLOY_VERSION = "${DEPLOY_VERSION_FOR_TEST}"
fi
exec entrypoint-deploy-wordpress-plugin "${@}"
