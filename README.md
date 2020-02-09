# Deploy WordPress plugin

[![test-local](https://github.com/yukihiko-shinoda/action-deploy-wordpress-plugin/workflows/test-local/badge.svg)](https://github.com/yukihiko-shinoda/action-deploy-wordpress-plugin/actions?query=workflow%3Atest-local)
[![docker buikd automated?](https://img.shields.io/docker/cloud/automated/futureys/deploy-wordpress-plugin.svg)](https://hub.docker.com/r/futureys/deploy-wordpress-plugin/builds)
[![docker build passing](https://img.shields.io/docker/cloud/build/futureys/deploy-wordpress-plugin.svg)](https://hub.docker.com/r/futureys/deploy-wordpress-plugin/builds)
[![image size and number of layers](https://images.microbadger.com/badges/image/futureys/deploy-wordpress-plugin.svg)](https://hub.docker.com/r/futureys/deploy-wordpress-plugin/dockerfile)

This is deployment action for WordPress Plugin
from public Git repository to SubVersion on WordPress.org.

## requirement

- Source Git repository is public
- Tagging revision on Git is done before deploy into WordPress.org
- Tag name of revision on source Git repository to deploy is the same as version number of plugin’s main PHP file on tagged revision of source Git repository
- Linux runner only due to GitHub specification when use ```services```.

## out of scope

- Deploying old version than latest version
- [Deploying Assets](https://developer.wordpress.org/plugins/wordpress-org/plugin-assets/)
  (Even if Git repository includes assets, this project will deploy
   the revision content as it is under trunk and tags
   of SubVersion repository on WordPress.org.)

## excluding strategy

The process executes rsync from Git working tree to SubVersion working tree with ```.rsync-filter```.

### default behavior

rsync will read [default .rsync-filter file](https://github.com/yukihiko-shinoda/dockerfile-deploy-wordpress-plugin/blob/master/runner/project/roles/deploy-wordpress-plugin/templates/.rsync-filter.j2).

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
    runs-on: ubuntu-18.04
    services:
      # 3. Run workspace service with ssh password as name "workspace"
      workspace:
        image: futureys/ansible-workspace-deploy-wordpress-plugin:20191127164500
        env:
          SSH_PASSWORD: p@ssW0rd
    steps:
      # 4. Set environment variable "DEPLOY_VERSION" from tag name
      - name: Set deploy version
        run: echo ::set-env name=DEPLOY_VERSION::$(echo ${GITHUB_REF#refs/tags/})
      # 5. Use action with ssh password for workspace and environment varialble set by secrets
      - name: Deploy
        uses: yukihiko-shinoda/action-deploy-wordpress-plugin@v1.1.0
        with:
          workspaceUserPassword: 'p@ssW0rd'
        env:
          SVN_REPOSITORY_URL: ${{ secrets.SvnRepositoryUrl }}
          SVN_USER_NAME: ${{ secrets.SvnUserName }}
          SVN_USER_PASSWORD: ${{ secrets.SvnUserPassword }}
```

key point:

### 1. Triger by pushing tag

If you prefer, you can use [filter pattern](https://help.github.com/en/actions/automating-your-workflow-with-github-actions/workflow-syntax-for-github-actions#filter-pattern-cheat-sheet).

### 2. Specify Linux runner

This action works only on Linux runner due to GitHub specification when use ```services```.

### 3. Run workspace service with ssh password as name "workspace"

This action use workspace container
which Git, SubVersion, and rsync is installed.
By default, action will try to ssh to host name "workspace".

### 4. Set environment variable "DEPLOY VERSION" from tag name

This action reads deploy version from environment variable.
When trigger workflow by pushing tag, ```GITHUB_REF``` will be "refs/tags/tag-name".

### 5. Use action with ssh password for workspace and environment varialble set by secrets

The input ```workspaceUserPassword``` is required to set the same password as the one set to workspace container to ssh.
In this example, environment variables are [presented by secrets](https://help.github.com/en/actions/automating-your-workflow-with-github-actions/creating-and-using-encrypted-secrets). At least, you'd better to use secret for ```SVN_USER_NAME``` and ```SVN_USER_PASSWORD```.
