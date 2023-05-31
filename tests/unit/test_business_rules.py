# test_app.py
"""
This file (test_business_rules.py) contains unit tests
"""
from src.modules.business_rules import addition, subtraction, multiply, divide


def test_addition():
    assert addition(1, 1) == 2


def test_subtraction():
    assert subtraction(1, 1) == 0


def test_multiply():
    assert multiply(1, 1) == 1


def test_divide():
    assert divide(1, 1) == 1
    assert divide(4, 2) == 2
