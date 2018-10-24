"""
Deployment script for ORES setup on Wikimedia Labs

Fabric script for doing multiple operations on ORES servers,
both production and staging.

## Setting up a new server ##

This assumes that the puppet role has been applied, and then you
can initialize it with:

    fab initialize_server:hosts="<fqdn1>;<fqdn2>"

This:
    1. Sets up the virtualenv appropriately
    2. Sets up latest models
    3. Does a deploy / restarts uwsgi

For first time use, just doing this step should provide a working server!

## Deploying a code update to staging ##

This pushes the 'staging' branch to the staging server. Make sure to push
the changes you want to test / stage to the 'staging' branch before running
this! You can run this with:

    fab stage

This updates the staging server (ores-staging.wmflabs.org) with code from
the staging branch, and restarts uwsgi so the changes take effect.

## Deploying a code update to 'production' ##

This pushes the 'deploy' branch to the production servers. Make sure to push
the changes you want deployed to the 'deploy' branch before running this!
This can be simply run by:

    fab deploy

This updates all the web workers of ores to the new code and restarts them.
"""
import glob
import os

from fabric.api import cd, env, put, roles, shell_env, sudo

env.roledefs = {
    'web': ['ores-web-01.eqiad.wmflabs',
            'ores-web-03.eqiad.wmflabs',
            'ores-web-02.eqiad.wmflabs'],
    'staging': ['ores-staging-01.eqiad.wmflabs'],
    'worker': ['ores-worker-01.eqiad.wmflabs', 'ores-worker-02.eqiad.wmflabs',]
}
env.use_ssh_config = True
env.shell = '/bin/bash -c'

base_dir = '/srv/ores'
config_dir = base_dir + '/config'
venv_dir = base_dir + '/venv'
data_dir = base_dir + '/data'
config_config_dir = config_dir + "/config"

staging_branch = "master"
deploy_branch = "deploy"

def sr(*cmd):
    with shell_env(HOME='/srv/ores'):
        return sudo(' '.join(cmd), user='www-data')


def initialize_staging_server():
    initialize_server(staging_branch)
    restart_uwsgi()
    restart_celery()


def initialize_web_server():
    initialize_server(deploy_branch)
    restart_uwsgi()


def initialize_worker_server():
    initialize_server(deploy_branch)
    restart_celery()


def git_clone(branch=deploy_branch):
    sr('rm', '-rf', config_dir)
    sr('mkdir', '-p', config_dir)
    sr('chmod', '-R', '775', config_dir)
    # They need to be one command
    sr('cd', '/', '&&', 'git', 'clone', '--recursive',
            'https://github.com/wikimedia/ores-wmflabs-deploy.git', config_dir)
    sr('cd', config_dir, '&&', 'git', 'checkout', branch)


def initialize_server(branch=deploy_branch):
    """
    Setup an initial deployment on a fresh host.

    This currently does:

    - Creates the virtualenv
    - Installs virtualenv
    """
    sudo("mkdir -p " + base_dir)
    sudo("chown www-data:www-data " + base_dir)
    git_clone(branch)
    sr('mkdir', '-p', venv_dir)
    sr('virtualenv', '--python', 'python3', '--system-site-packages', venv_dir)
    update_virtualenv()


@roles('web', 'worker')
def update_git(branch=deploy_branch):
    with cd(config_dir):
        sr('git', 'fetch', 'origin')
        sr('git', 'reset', '--hard', 'origin/%s' % branch)
        sr('git', 'submodule', 'update', '--init', '--recursive')
        sr('git', 'submodule', 'foreach', 'git lfs pull')


@roles('web')
def restart_uwsgi():
    sudo('service uwsgi-ores restart')


@roles('worker')
def restart_celery():
    sudo('service celery-ores-worker restart')


@roles('web')
def deploy_web():
    sudo('apt-get install git-lfs -y')
    update_git()
    update_custom_config()
    update_virtualenv()
    restart_uwsgi()


@roles('worker')
def deploy_celery():
    sudo('apt-get install git-lfs -y')
    update_git()
    update_custom_config()
    update_virtualenv()
    restart_celery()


@roles('web', 'worker')
def update_virtualenv():
    # Don't you never, ever remove --no-deps, otherwise hell breaks loose
    clean_virtualenv()
    with cd(venv_dir):
#        sr(venv_dir + '/bin/pip', 'install',
#           '--use-wheel', '--no-deps',
#           config_dir + '/submodules/wheels/pip-*.whl')
        sr(venv_dir + '/bin/pip', 'install',
           '--no-deps', config_dir + '/submodules/wheels/*.whl')


@roles('web', 'worker')
def clean_virtualenv():
    with cd(venv_dir):
        sr(venv_dir + '/bin/pip', 'freeze',
           '|', 'xargs', venv_dir + '/bin/pip', 'uninstall', '-y')


@roles('staging')
def stage():
    update_git(staging_branch)
    update_custom_config(staging_branch)
    update_virtualenv()
    restart_uwsgi()
    restart_celery()


def update_custom_config(branch=deploy_branch):
    """
    Uploads config files to server
    """
    if branch == deploy_branch:
        creds_folder = "wmflabs"
    elif branch == staging_branch:
        creds_folder = "wmflabs-staging"
    else:
        raise RuntimeError("I don't know how to deal with branch {0}"
                           .format(branch))

    # Transfer new custom config
    creds_paths = os.path.join("config", creds_folder, "*.yaml")
    for creds_path in glob.glob(creds_paths):
        # Upload oauth creds
        put(creds_path, config_config_dir, use_sudo=True)

        creds_filename = os.path.basename(creds_path)
        sudo("chown www-data:www-data " +
             os.path.join(config_config_dir, creds_filename))


def run_puppet():
    sudo('puppet agent -tv')
