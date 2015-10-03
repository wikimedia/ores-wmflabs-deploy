#!/usr/bin/env python3
import logging
import os

from flask import request

import yamlconf
from ores.wsgi import server

config = yamlconf.load(open("ores.wmflabs.org.yaml"))

if 'data_paths' in config['ores'] and \
    'nltk' in config['ores']['data_paths']:
    import nltk
    nltk.data.path.append(config['ores']['data_paths']['nltk'])

application = server.configure(config)


if __name__ == '__main__':
    logging.basicConfig(
        level=logging.INFO,
        format='%(asctime)s %(levelname)s:%(name)s -- %(message)s'
    )
    application.debug = True
    application.run(host="0.0.0.0", threaded=True, debug=True)
