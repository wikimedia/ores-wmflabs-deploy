#!/usr/bin/env python3
import logging

import yamlconf
from ores.score_processors import celery

config = yamlconf.load(open("ores.wmflabs.org.yaml"))

application = celery.configure(config, "ores_celery")

if __name__ == '__main__':
    logging.basicConfig(
        level=logging.INFO,
        format='%(asctime)s %(levelname)s:%(name)s -- %(message)s'
    )
    application.worker_main(argv=["celery_worker", "--loglevel=INFO"])
