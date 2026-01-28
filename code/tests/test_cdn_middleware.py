from fastapi import FastAPI, status
from fastapi.testclient import TestClient

from middlewares.cdn_secret_key_middleware import CdnSecretKeyMiddleware


def create_app():
    app = FastAPI()
    app.add_middleware(CdnSecretKeyMiddleware)

    @app.get("/ping")
    def ping():
        return {"ok": True}

    return app


def test_allows_missing_header_if_cdn_disabled(monkeypatch):
    monkeypatch.delenv("CDN_SECRET_KEY", raising=False)
    client = TestClient(create_app())

    response = client.get("/ping")

    assert response.status_code == status.HTTP_200_OK

def test_rejects_missing_header_if_cdn_enabled(monkeypatch):
    monkeypatch.setenv("CDN_SECRET_KEY", "test-cdn-key")
    client = TestClient(create_app())

    response = client.get("/ping")

    assert response.status_code == status.HTTP_403_FORBIDDEN


def test_rejects_wrong_header(monkeypatch):
    monkeypatch.setenv("CDN_SECRET_KEY", "test-cdn-key")
    client = TestClient(create_app())

    response = client.get("/ping", headers={"X-CDN-Secret-Key": "bad-key"})

    assert response.status_code == status.HTTP_403_FORBIDDEN


def test_allows_correct_header(monkeypatch):
    monkeypatch.setenv("CDN_SECRET_KEY", "test-cdn-key")
    client = TestClient(create_app())

    response = client.get("/ping", headers={"X-CDN-Secret-Key": "test-cdn-key"})

    assert response.status_code == status.HTTP_200_OK
    assert response.json() == {"ok": True}
