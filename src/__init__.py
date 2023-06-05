from flask import Flask, render_template
from logging import StreamHandler, Formatter
from flask import has_request_context, request
from flask.logging import default_handler
import os

# Azure App-Insights
# Note: This will fail if APPLICATIONINSIGHTS_CONNECTION_STRING is not set
from applicationinsights.flask.ext import AppInsights


# ----------------------------
# Set up formatting for log entries
# ----------------------------
class RequestFormatter(Formatter):
    def format(self, record):
        if has_request_context():
            record.url = request.url
            record.remote_addr = request.remote_addr
        else:
            record.url = None
            record.remote_addr = None

        return super().format(record)


# ----------------------------
# Custom Exception: Missing Environment variable
# ----------------------------
class MissingEnvironmentVariableException(Exception):
    pass


# ----------------------------
# Get environment variables (throw if not found)
# ----------------------------
def get_environment_variable(key):
    try:
        key_value = os.environ[key]
    except KeyError:
        raise MissingEnvironmentVariableException(
            "Environment variable {key} does not exist"
        )
    return key_value


# ----------------------------
# Logging Factory Function
# https://opentelemetry-python-contrib.readthedocs.io/en/latest/instrumentation/flask/flask.html
# ----------------------------
def register_logger(app):
    instrument_key = get_environment_variable("APPINSIGHTS_INSTRUMENTATIONKEY")

    # Store key in app.config (as required by )
    app.config["APPINSIGHTS_INSTRUMENTATIONKEY"] = instrument_key

    # Set formatting for log messages
    formatter = RequestFormatter(
        "[%(asctime)s] %(remote_addr)s requested %(url)s\n"
        "%(levelname)s in %(module)s: %(message)s"
    )

    default_handler.setFormatter(formatter)

    # Ensure all logs are ALSO redirected to stderr/stdin
    streamHandler = StreamHandler()
    app.logger.addHandler(streamHandler)

    # Instrument flask
    appinsights = AppInsights(app)

    # Flush logs after each request (but could be less frequent, if so desired)
    @app.after_request
    def after_request(response):
        appinsights.flush()
        return response


# ----------------------------
# Application Factory Function
# ----------------------------
def create_app():
    """Create Flask App and register all routes etc"""
    app = Flask(__name__)

    # Register logger
    register_logger(app)

    # Register_blueprints(app)
    register_app_routes(app)
    register_error_pages(app)

    return app


# ----------------------------
# Register app routes
# ----------------------------
def register_app_routes(app):
    """Register the routes associated with the Flask application."""

    @app.route("/")
    def index():
        for x in range(1, 20, 1):
            app.logger.debug("This is a debug log message ~ {x}")
            app.logger.info("This is an information log message ~ {x}")
            app.logger.warn("This is a warning log message ~ {x}")
            app.logger.error("This is an error message ~ {x}")
            app.logger.critical("This is a critical message ~ {x}")

        return render_template("index.html")


# ----------------------------
# Register error pages
# ----------------------------
def register_error_pages(app):
    @app.errorhandler(404)
    def page_not_found(e):
        return render_template("404.html"), 404
