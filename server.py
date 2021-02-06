import logging
from flask_session import Session

from api.app import APP

app_log = logging.getLogger()
# app_log.info(dir(APP))

if __name__ == "__main__":
    APP.config.from_object(__name__)
    APP.debug = True
    APP.run()
