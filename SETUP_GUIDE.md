# Smart Cooking Helper - Setup Guide

## Prerequisites

### Backend Requirements
- Python 3.8 or higher
- PostgreSQL 12 or higher
- pip (Python package manager)

### Frontend Requirements
- Flutter SDK 3.0 or higher
- Android Studio / Xcode (for mobile development)
- Firebase account

## Backend Setup

### 1. Install Dependencies

```bash
cd smart-cooking-helper/backend
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
pip install -r requirements.txt
```

### 2. Database Setup

1. Create PostgreSQL database:
```sql
CREATE DATABASE smart_cooking_helper;
```

2. Update database connection in `.env` file:
```
DATABASE_URL=postgresql://username:password@localhost:5432/smart_cooking_helper
```

3. Run database migrations:
```bash
# Execute the schema file
psql -U username -d smart_cooking_helper -f ../database/schema.sql
```

### 3. Environment Variables

Create a `.env` file in the `backend` directory:

```env
DATABASE_URL=postgresql://user:password@localhost:5432/smart_cooking_helper
API_URL=http://localhost:8000/api

# Firebase Configuration
FIREBASE_PROJECT_ID=your-firebase-project-id
FIREBASE_PRIVATE_KEY=your-firebase-private-key
FIREBASE_CLIENT_EMAIL=your-firebase-client-email

# External API Keys
RECIPE_API_KEY=your-recipe-api-key
NUTRITION_API_KEY=your-nutrition-api-key
BARCODE_API_KEY=your-barcode-api-key
```

### 4. Run Backend Server

```bash
cd smart-cooking-helper/backend
python main.py
```

The API will be available at `http://localhost:8000`
API documentation at `http://localhost:8000/docs`

## Frontend Setup

### 1. Install Flutter Dependencies

```bash
cd smart-cooking-helper/frontend
flutter pub get
```

### 2. Firebase Configuration

1. Create a Firebase project at https://console.firebase.google.com
2. Enable Authentication (Email/Password, Google, Anonymous)
3. Enable Firestore Database
4. Enable Storage
5. Download `google-services.json` (Android) and `GoogleService-Info.plist` (iOS)
6. Place configuration files in appropriate directories

### 3. Firebase Options Setup

Run FlutterFire CLI to configure Firebase:
```bash
flutterfire configure
```

Or manually update `lib/firebase_options.dart` with your Firebase configuration.

### 4. Environment Variables

Create a `.env` file in the `frontend` directory:

```env
API_URL=http://localhost:8000/api
```

For Android emulator, use: `http://10.0.2.2:8000/api`
For iOS simulator, use: `http://localhost:8000/api`

### 5. Run Flutter App

```bash
cd smart-cooking-helper/frontend
flutter run
```

## Project Structure

```
smart-cooking-helper/
├── backend/
│   ├── app/
│   │   ├── api/          # API routes
│   │   ├── database/     # Database models and connection
│   │   ├── models/       # Pydantic schemas
│   │   └── services/     # Business logic
│   ├── main.py          # FastAPI application entry
│   └── requirements.txt  # Python dependencies
├── frontend/
│   ├── lib/
│   │   ├── models/       # Data models
│   │   ├── screens/      # UI screens
│   │   ├── services/     # API and Firebase services
│   │   └── widgets/      # Reusable widgets
│   └── pubspec.yaml     # Flutter dependencies
└── database/
    └── schema.sql       # PostgreSQL schema
```

## Features Implementation

### Authentication
- Email/Password authentication via Firebase
- Google Sign-In
- Guest mode (Anonymous authentication)

### Recipe Features
- Search recipes by name/ingredients
- AI-powered recommendations based on available ingredients
- Today's recipe recommendation
- Step-by-step cooking instructions

### Cooking Assistant
- Voice narration for instructions
- Integrated timer for cooking steps
- Image/video support for each step
- Progress tracking

### Smart Features
- Barcode scanning for ingredients
- Nutrition information lookup
- Shopping list generation
- Favorites and cooking history

### Nutrition Tracking
- Daily intake tracking
- Nutrition breakdown per recipe
- Health recommendations

## API Endpoints

### Recipes
- `GET /api/recipes/search` - Search recipes
- `POST /api/recipes/recommendations` - Get AI recommendations
- `POST /api/recipes/today-recommendation` - Today's recommendation
- `GET /api/recipes/{recipe_id}` - Get recipe details

### Nutrition
- `GET /api/nutrition/scan-barcode` - Scan barcode
- `GET /api/nutrition/info` - Get nutrition info
- `POST /api/nutrition/shopping-list` - Get missing ingredients
- `POST /api/nutrition/daily-intake-track` - Track daily intake

### Favorites & History
- `GET /api/favorites` - Get user favorites
- `POST /api/favorites/add` - Add to favorites
- `POST /api/favorites/remove` - Remove from favorites
- `GET /api/history/recent` - Get cooking history
- `POST /api/history/add` - Add to history

## Troubleshooting

### Backend Issues
- Ensure PostgreSQL is running
- Check database connection string
- Verify all environment variables are set
- Check API logs for errors

### Frontend Issues
- Run `flutter clean` and `flutter pub get`
- Verify Firebase configuration
- Check API URL in `.env` file
- Ensure camera permissions are granted (for scanner)

### Database Issues
- Verify PostgreSQL is accessible
- Check user permissions
- Ensure schema is properly created
- Run seed data if needed

## Development Notes

- Backend uses FastAPI with async/await
- Frontend uses Provider/Riverpod for state management
- Database uses PostgreSQL with SQLAlchemy ORM
- Firebase handles authentication and file storage
- External APIs can be integrated for recipe/nutrition data

## Next Steps

1. Configure Firebase project
2. Set up external API keys (recipe, nutrition, barcode APIs)
3. Seed database with sample recipes
4. Test all features
5. Deploy backend to cloud (Heroku, AWS, etc.)
6. Build and deploy mobile app
