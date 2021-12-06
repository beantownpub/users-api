import logging

def init_logger(log_level='INFO'):
    if __name__ != '__main__':
        app_log = logging.getLogger()
        gunicorn_logger = logging.getLogger('gunicorn.error')
        app_log.handlers = gunicorn_logger.handlers
        app_log.setLevel(log_level)
        return app_log
