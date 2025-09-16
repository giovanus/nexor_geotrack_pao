import pytest
from fastapi.testclient import TestClient
from app.main import app
from app.auth import create_access_token
from datetime import datetime

client = TestClient(app)

@pytest.fixture
def auth_token():
    token = create_access_token({"sub": "admin"})
    return token

def test_create_gps_data(auth_token):
    headers = {"Authorization": f"Bearer {auth_token}"}
    gps_data = {
        "device_id": "test-device",
        "lat": 48.8566,
        "lon": 2.3522,
        "timestamp": datetime.now().isoformat()
    }
    response = client.post("/data/", json=gps_data, headers=headers)
    assert response.status_code == 200
    assert response.json()["device_id"] == "test-device"
    assert response.json()["lat"] == 48.8566
    assert response.json()["lon"] == 2.3522

def test_get_gps_data(auth_token):
    headers = {"Authorization": f"Bearer {auth_token}"}
    response = client.get("/data/", headers=headers)
    assert response.status_code == 200
    assert isinstance(response.json(), list)