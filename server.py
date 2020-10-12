from api.app import APP

if __name__ == "__main__":
    APP.config.from_object(__name__)
    APP.debug = True
    APP.run()
