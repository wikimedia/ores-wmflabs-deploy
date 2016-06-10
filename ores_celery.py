#!/usr/bin/env python3
import glob
import logging
import logging.config

import yamlconf

from ores.score_processors import Celery

config_paths = sorted(glob.glob("config/*.yaml") +
                      glob.glob("/etc/ores/*.yaml"))

config = yamlconf.load(*(open(p) for p in config_paths))

with open("logging_config.yaml") as f:
    logging_config = yamlconf.load(f)
    logging.config.dictConfig(logging_config)

if 'data_paths' in config['ores'] and \
    'nltk' in config['ores']['data_paths']:
    import nltk
    nltk.data.path.append(config['ores']['data_paths']['nltk'])

score_processor = Celery.from_config(config, config['ores']['score_processor'])
application = score_processor.application

if __name__ == '__main__':
    logging.getLogger('ores').setLevel(logging.DEBUG)
    application.worker_main(argv=["celery_worker", "--loglevel=INFO"])
