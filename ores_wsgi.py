#!/usr/bin/env python3
import logging
import logging.config

import yamlconf

from ores.wsgi import server

with open("ores.wmflabs.org.yaml") as f:
    config = yamlconf.load(f)

with open("logging_config.yaml") as f:
    logging_config = yamlconf.load(f)
    logging.config.dictConfig(logging_config)

if 'data_paths' in config['ores'] and \
   'nltk' in config['ores']['data_paths']:
    import nltk
    nltk.data.path.append(config['ores']['data_paths']['nltk'])

logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s %(levelname)s:%(name)s -- %(message)s'
)

application = server.configure(config)


if __name__ == '__main__':
    logging.getLogger('ores.metrics_collectors').setLevel(logging.DEBUG)

    application.debug = True
    application.run(host="0.0.0.0", processes=64, debug=True)
