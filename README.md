# GearMate



A full-stack reminder application with Flutter frontend and FastAPI backend.



## Project Structure



```This project is a starting point for a Flutter application.

gear_mate/

├── client/             # Flutter frontendA few resources to get you started if this is your first Flutter project:

│   ├── lib/

│   ├── android/- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)

│   ├── ios/- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

│   ├── web/

│   └── ...For help getting started with Flutter development, view the

└── api/                # FastAPI backend[online documentation](https://docs.flutter.dev/), which offers tutorials,

    ├── main.pysamples, guidance on mobile development, and a full API reference.

    ├── requirements.txt
    └── ...
```

## Quick Start

### Backend (FastAPI)

1. Navigate to the api folder:
```bash
cd api
```

2. Create and activate virtual environment:
```bash
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
```

3. Install dependencies:
```bash
pip install -r requirements.txt
```

4. Run the server:
```bash
uvicorn main:app --reload
```

API will be available at `http://localhost:8000`
- Swagger Docs: `http://localhost:8000/docs`

### Frontend (Flutter)

1. Navigate to the client folder:
```bash
cd client
```

2. Get dependencies:
```bash
flutter pub get
```

3. Run the app:
```bash
flutter run
```

## Development

- **Backend README**: See `api/README.md` for detailed API documentation
- **Frontend README**: See `client/README.md` for Flutter development guide

### Testing

## 1. unitTest

### Enter venv environment
```bash
cd api
source venv/bin/activate  # On Windows: venv\Scripts\activate
pip install -r requirements.txt
cd ..
```

### Perform unit test
```bash
pytest unitTest -v --cov=routers.firefighters --cov=routers.stations --cov=routers.inspections --cov-report=html --cov-branch
```

## 2. Auto-test
### Test on client site
```bash
cd client
```
### Run all integration tests
```bash
flutter test integration_test/
# For disable notification
flutter test --dart-define=DISABLE_NOTIFICATIONS=true integration_test
```