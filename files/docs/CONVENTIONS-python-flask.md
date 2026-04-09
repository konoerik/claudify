# Conventions

> Reference style — pattern-match against these before writing or editing code.
> Modify to reflect actual project choices.

## Route handler

```python
from flask import Blueprint, jsonify, request
from app.models import User
from app.schemas import UserSchema
from app.extensions import db

users_bp = Blueprint("users", __name__, url_prefix="/users")
user_schema = UserSchema()


@users_bp.get("/<int:user_id>")
def get_user(user_id: int):
    user = db.get_or_404(User, user_id)
    return jsonify(user_schema.dump(user))


@users_bp.post("/")
def create_user():
    data = user_schema.load(request.get_json())
    user = User(**data)
    db.session.add(user)
    db.session.commit()
    return jsonify(user_schema.dump(user)), 201
```

## Model

```python
from app.extensions import db


class User(db.Model):
    id: int = db.Column(db.Integer, primary_key=True)
    email: str = db.Column(db.String(255), unique=True, nullable=False)
    created_at = db.Column(db.DateTime, server_default=db.func.now())

    def __repr__(self) -> str:
        return f"<User {self.email}>"
```

## Test

```python
def test_get_user(client, user_factory):
    user = user_factory(email="test@example.com")
    response = client.get(f"/users/{user.id}")
    assert response.status_code == 200
    assert response.json["email"] == "test@example.com"


def test_create_user(client):
    response = client.post("/users/", json={"email": "new@example.com"})
    assert response.status_code == 201
```
