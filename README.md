# Deploy WordPress plugin

[![Test](https://github.com/yukihiko-shinoda/action-deploy-wordpress-plugin/workflows/Test/badge.svg)](https://github.com/yukihiko-shinoda/action-deploy-wordpress-plugin/actions?query=workflow%3ATest)
[![Docker Cloud Automated build](https://img.shields.io/docker/cloud/automated/futureys/deploy-wordpress-plugin.svg)](https://hub.docker.com/r/futureys/deploy-wordpress-plugin/builds)
[![Docker Cloud Build Status](https://img.shields.io/docker/cloud/build/futureys/deploy-wordpress-plugin.svg)](https://hub.docker.com/r/futureys/deploy-wordpress-plugin/builds)
[![Docker Image Size (latest semver)](https://img.shields.io/docker/image-size/futureys/deploy-wordpress-plugin)](https://hub.docker.com/r/futureys/deploy-wordpress-plugin/dockerfile)
[![Twitter URL](https://img.shields.io/twitter/url?style=social&url=https%3A%2F%2Fgithub.com%2Fyukihiko-shinoda%2Faction-deploy-wordpress-plugin)](http://twitter.com/share?text=Deploy%20WordPress%20plugin&url=https://github.com/marketplace/actions/deploy-wordpress-plugin&hashtags=wordpress)

This is deployment action for WordPress Plugin from Git repository to SubVersion on WordPress.org.

## requirement

Your WordPress Plugin project can accept that:

- Tag revision on Git repository before deploy into WordPress.org
- Tag name of revision on source Git repository to deploy is the same as version number of plugin’s main PHP file on tagged revision of source Git repository

## out of scope

- Deploying old version than latest version
- [Deploying Assets](https://developer.wordpress.org/plugins/wordpress-org/plugin-assets/)
  (Even if Git repository includes assets, this project will deploy
   the revision content as it is under trunk and tags
   of SubVersion repository on WordPress.org.)

## excluding strategy

The process executes rsync from Git working tree to SubVersion working tree with ```.rsync-filter```.

### default behavior

rsync will read [default .rsync-filter file](https://github.com/yukihiko-shinoda/dockerfile-deploy-wordpress-plugin/blob/main/runner/project/roles/rsync_git_to_svn/templates/.rsync-filter.j2).

### customizing behavior

If ```.rsync-filter``` file is exist on the root of Git working tree, rsync will read it. The most primitive how to write it is to list up files and directories you want to exclude. For more details, following contents will be helpful.

- [linux - Using Rsync filter to include/exclude files - Stack Overflow](https://stackoverflow.com/questions/35364075/using-rsync-filter-to-include-exclude-files)
- [rsync(1) - Linux man page](https://linux.die.net/man/1/rsync)

## Usage

The code example is given first and some key points are explained later.

Ex:

```yaml
name: Deploy WordPress plugin
on:
  push:
    # 1. Trigger by pushing tag
    tags:
      - '[0-9]+.[0-9]+.[0-9]+'
jobs:
  build:
    name: Deploy WordPress plugin
    # 2. Specify Linux runner
    runs-on: ubuntu-20.04
    steps:
      # 3. Checkout before Use this deployment action
      - name: Checkout
        uses: actions/checkout@v3
      # 4. Use action with environment variable set by secrets
      - name: Deploy
        uses: yukihiko-shinoda/action-deploy-wordpress-plugin@v2
        env:
          SVN_REPOSITORY_URL: ${{ secrets.SvnRepositoryUrl }}
          SVN_USER_NAME: ${{ secrets.SvnUserName }}
          SVN_USER_PASSWORD: ${{ secrets.SvnUserPassword }}
```

### key point

#### 1. Trigger by pushing tag

If you prefer, you can use [filter pattern](https://help.github.com/en/actions/automating-your-workflow-with-github-actions/workflow-syntax-for-github-actions#filter-pattern-cheat-sheet).

#### 2. Specify Linux runner

We recommend Linux runner. Windows and Mac also may use this action,
however we are not running test on these environment to save testing cost now.

#### 3. Checkout before Use this deployment action

This deployment action assumes that the Git repository has been checked out.

#### 4. Use action with environment variable set by secrets

In this example, environment variables are [presented by secrets](https://help.github.com/en/actions/automating-your-workflow-with-github-actions/creating-and-using-encrypted-secrets). At least, you'd better to use secret for ```SVN_USER_NAME``` and ```SVN_USER_PASSWORD```.
