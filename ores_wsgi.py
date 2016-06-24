#!/usr/bin/env python3
import logging

from ores.applications import wsgi

application = wsgi.build()

if __name__ == '__main__':
    logging.getLogger('ores').setLevel(logging.DEBUG)

    application.debug = True
    application.run(host="0.0.0.0", processes=64, debug=True)
