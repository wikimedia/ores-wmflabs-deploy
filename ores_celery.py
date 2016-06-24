#!/usr/bin/env python3
import logging

from ores.applications import celery

application = celery.build()

if __name__ == '__main__':
    logging.getLogger('ores').setLevel(logging.DEBUG)
    application.worker_main(argv=["celery_worker", "--loglevel=INFO"])
