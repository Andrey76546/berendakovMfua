from myapp.app import add


def test_add_positive_numbers() -> None:
    assert add(2, 3) == 5


def test_add_opposite_numbers() -> None:
    assert add(-1, 1) == 0


def test_add_zeroes() -> None:
    assert add(0, 0) == 0
