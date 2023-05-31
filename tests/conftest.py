# Pytest Fixtures
import pytest
from src import create_app


@pytest.fixture(scope='module')
def test_client():
    flask_app = create_app()

    # Create a test client using Flask
    with flask_app.test_client() as testing_client:
        yield testing_client
