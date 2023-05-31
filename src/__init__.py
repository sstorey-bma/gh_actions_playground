from flask import Flask, render_template


# ----------------------------
# Application Factory Function
# ----------------------------
def create_app():
    """Create Flask App and register all routes etc"""
    app = Flask(__name__)

    # register_blueprints(app)
    register_app_routes(app)
    register_error_pages(app)
    return app


# ----------------------------
# Helper Functions
# ----------------------------
def register_app_routes(app):
    """Register the routes associated with the Flask application."""

    @app.route('/')
    def index():
        return render_template('index.html')


def register_error_pages(app):
    @app.errorhandler(404)
    def page_not_found(e):
        return render_template('404.html'), 404
