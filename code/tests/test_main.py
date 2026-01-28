from fastapi.testclient import TestClient

import main


def test_hello_world_returns_message(monkeypatch):
    monkeypatch.setenv("DEMO_ENVIRONMENT_VARIABLE", "Hello from tests")

    client = TestClient(main.app)
    response = client.get("/hello")

    assert response.status_code == 200
    assert response.json() == {"message": "Hello from tests"}


def test_hello_world_missing_env_returns_500(monkeypatch):
    monkeypatch.delenv("DEMO_ENVIRONMENT_VARIABLE", raising=False)

    client = TestClient(main.app)
    response = client.get("/hello")

    assert response.status_code == 500
    assert response.json().get("detail") == "Couldn't retrieve environment variable"
