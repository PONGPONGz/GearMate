# GearMate API

FastAPI backend for GearMate application - a firefighting gear management system.

## Setup

1. Create a virtual environment:
```bash
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
```

2. Install dependencies:
```bash
pip install -r requirements.txt
```

3. Create a `.env` file from `.env.example`:
```bash
cp .env.example .env
```

4. Run the development server:
```bash
uvicorn main:app --reload
```

The API will be available at `http://localhost:8000`

## API Documentation

Once the server is running, you can access:
- Swagger UI: `http://localhost:8000/docs`
- ReDoc: `http://localhost:8000/redoc`

## Project Structure

```
api/
├── main.py              # Application entry point
├── dependencies.py      # Shared dependencies (database session)
├── database.py          # Database configuration
├── models.py            # SQLAlchemy ORM models
├── schemas.py           # Pydantic schemas for validation
├── requirements.txt     # Python dependencies
├── Dockerfile           # Docker configuration
├── .env.example        # Environment variables template
├── .gitignore          # Git ignore rules
└── routers/            # API route handlers
    ├── departments.py   # Department management
    ├── stations.py      # Station management
    ├── firefighters.py  # Firefighter management
    ├── gears.py        # Gear management
    ├── inspections.py  # Inspection management
    ├── schedules.py    # Maintenance schedules
    ├── reminders.py    # Maintenance reminders
    └── damage_reports.py # Damage reporting
```

## API Endpoints

| Endpoint | Methods | Description |
|----------|---------|-------------|
| `/` | GET | Root endpoint |
| `/health` | GET | Health check |
| `/departments` | POST, GET | Department management |
| `/stations` | POST, GET | Fire station management |
| `/firefighters` | POST, GET | Firefighter management |
| `/gears` | POST, GET | Firefighting gear management |
| `/inspections` | POST, GET | Gear inspection records |
| `/schedules` | POST, GET | Maintenance scheduling |
| `/reminders` | POST, GET | Maintenance reminders |
| `/damage-reports` | POST, GET | Equipment damage reports |

## Development

### Adding New Endpoints

1. **To an existing resource**: Edit the corresponding router file in `routers/`
2. **For a new resource**: 
   - Create a new router file in `routers/`
   - Import and include it in `main.py` using `app.include_router()`

### Project Architecture

- **main.py**: FastAPI app initialization and router registration
- **dependencies.py**: Reusable dependencies (e.g., database sessions)
- **database.py**: Database engine and session configuration
- **models.py**: SQLAlchemy database models
- **schemas.py**: Pydantic models for request/response validation
- **routers/**: Modular endpoint handlers organized by resource

## Database

The API uses SQLAlchemy ORM with SQLite (default). To use a different database:
1. Update `DATABASE_URL` in `.env`
2. Install the appropriate database driver

## Testing

```bash
pytest
```

## Docker

Build and run using Docker:
```bash
docker build -t gearmate-api .
docker run -p 8000:8000 gearmate-api
```
