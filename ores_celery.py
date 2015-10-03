#!/usr/bin/env python3
import logging

import yamlconf
from ores.score_processors import Celery

config = yamlconf.load(open("ores.wmflabs.org.yaml"))

if 'data_paths' in config['ores'] and \
    'nltk' in config['ores']['data_paths']:
    import nltk
    nltk.data.path.append(config['ores']['data_paths']['nltk'])

score_processor = Celery.from_config(config, config['ores']['score_processor'])
application = score_processor.application

if __name__ == '__main__':
    logging.basicConfig(
        level=logging.INFO,
        format='%(asctime)s %(levelname)s:%(name)s -- %(message)s'
    )
    application.worker_main(argv=["celery_worker", "--loglevel=INFO"])
