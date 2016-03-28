venv="/srv/ores/venv"
mkdir -p $venv
virtualenv --python python3 --system-site-packages $venv
$venv/bin/pip freeze | xargs $venv/bin/pip uninstall -y
$venv/bin/pip install --use-wheel --no-deps /srv/ores/deploy/submodules/wheels/*.whl
ln -s /srv/ores/deploy /srv/ores/config
