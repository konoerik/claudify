# Architecture

## Quick Reference
**Stack:** Python 3.10+, Flask
**Entry point:** <!-- e.g. wsgi.py, run.py -->
**Key paths:** <!-- e.g. app/blueprints/, app/models/, app/schemas/ -->
**Key constraints:** <!-- e.g. stateless requests, auth via JWT, rate limiting on public routes -->
**Patterns:** App factory, blueprint-per-feature, config classes


## Decisions (ADRs)
<!-- Append new ADRs with /decide -->


## Detail

### App structure
```
<!-- Fill in your project layout, e.g.:
app/
├── __init__.py     # App factory (create_app)
├── config.py       # Config classes (Dev, Prod, Test)
├── extensions.py   # db, migrate, jwt, etc. — init'd separately from app
├── models/         # SQLAlchemy models
├── schemas/        # Marshmallow / Pydantic schemas
└── blueprints/
    ├── auth/       # /auth routes
    └── api/        # /api routes
-->
```

### Blueprints and routes
<!-- List registered blueprints and their URL prefixes. -->

### Data model
<!-- Key models, relationships, and any migration strategy. -->
