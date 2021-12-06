from .healthcheck import HealthCheckAPI
from .users import AccountAPI, AuthAPI


def init_routes(api):
    api.add_resource(AccountAPI, '/v1/accounts')
    api.add_resource(AuthAPI, '/v1/auth')
    api.add_resource(HealthCheckAPI, '/v1/healthz')
