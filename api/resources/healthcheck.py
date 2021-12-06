import os

from flask import Response, request, session
from flask_httpauth import HTTPBasicAuth
from flask_restful import Resource


class HealthCheckAPI(Resource):
    def get(self):
        return Response(status=200)
