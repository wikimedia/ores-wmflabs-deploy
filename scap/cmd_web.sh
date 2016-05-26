venv="/srv/ores/venv"
deploy_dir="/srv/deployment/ores/deploy"
mkdir -p $venv
virtualenv --python python3 --system-site-packages $venv
$venv/bin/pip freeze | xargs $venv/bin/pip uninstall -y
$venv/bin/pip install --use-wheel --no-deps $deploy_dir/submodules/wheels/*.whl
sudo service uwsgi-ores restart
