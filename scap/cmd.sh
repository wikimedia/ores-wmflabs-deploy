mkdir -p /srv/ores/venv
virtualenv --python python3 --system-site-packages /srv/ores/venv
/srv/ores/venv/bin/pip install --use-wheel --no-deps /srv/ores/ores-wikimedia-config/submodules/wheels/*.whl
ln -s /srv/ores/ores-wikimedia-config /srv/ores/config
sudo service celery-ores-worker restart
sudo service flower-ores restart
