"""
This file (test_routes.py) contains functional tests
"""


def test_index_page(test_client):
    """
    GIVEN a Flask application configured for testing
    WHEN the '/' page is requested (GET)
    THEN check the response is valid
    AND contains some relevant text (Title)
    """
    response = test_client.get('/')
    assert response.status_code == 200
    assert b'Built using Docker' in response.data
