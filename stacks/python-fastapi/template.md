# Python FastAPI + PostgreSQL Project Scaffold

## Directory Structure
```
├── app/
│   ├── __init__.py
│   ├── main.py                 # FastAPI app entry point
│   ├── config.py               # Settings and environment variables
│   ├── database.py             # Database connection and session
│   ├── models/                 # SQLAlchemy models
│   │   └── __init__.py
│   ├── schemas/                # Pydantic schemas
│   │   └── __init__.py
│   ├── routers/                # API route handlers
│   │   └── __init__.py
│   ├── services/               # Business logic
│   │   └── __init__.py
│   └── middleware/             # Custom middleware
│       └── __init__.py
├── alembic/                    # Database migrations
│   └── versions/
├── tests/
│   ├── conftest.py             # Test fixtures
│   ├── test_api/               # API endpoint tests
│   └── test_services/          # Service layer tests
├── .env.example
├── alembic.ini
├── pyproject.toml
├── requirements.txt
└── Dockerfile
```

## Setup Commands
```bash
python -m venv venv
source venv/bin/activate  # or venv\Scripts\activate on Windows
pip install fastapi uvicorn sqlalchemy alembic pydantic python-jose passlib python-dotenv
pip install pytest pytest-cov pytest-asyncio httpx ruff mypy pip-audit
alembic init alembic
```
