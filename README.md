# Smart Cooking Helper

A comprehensive mobile application that revolutionizes home cooking with AI-powered recipe recommendations, step-by-step cooking assistance, and personalized nutrition tracking.

## 📱 Features

### 1. Authentication & Profiles
- ✅ Firebase Authentication (Google, Email/Password, Guest mode)
- ✅ User profile management with dietary preferences
- ✅ Support for vegetarian, vegan, gluten-free, and other dietary restrictions

### 2. Recipe Search & Recommendation
- ✅ REST API-based recipe search
- ✅ Filter recipes by available ingredients
- ✅ AI-powered suggestions: "You have tomatoes, onions, and rice → Try Tomato Rice"
- ✅ Personalized recommendations based on user preferences

### 3. Cooking Assistant Mode
- ✅ Step-by-step recipe instructions
- ✅ Voice narration support (Text-to-Speech)
- ✅ Background video/image integration
- ✅ Integrated timer for cooking steps
- ✅ Multimedia handling for each cooking step

### 4. Nutrition & Health Info
- ✅ Detailed nutrition breakdown (calories, protein, carbs, fats)
- ✅ Daily intake tracking
- ✅ Health-conscious meal planning

### 5. Smart Features
- ✅ **Ingredient Scanner**: Camera-based scanning of packaged food to fetch nutrition information
- ✅ **Shopping Helper**: Automatic suggestion of missing ingredients and shopping list creation
- ✅ **Favorites & History**: Save favorite recipes and track cooking history

### 6. UI/UX Polish
- ✅ Clean dashboard with "Today's Recommendations" and recipe suggestions
- ✅ Immersive background video/images for cooking experience
- ✅ Dark mode support for comfortable late-night cooking
- ✅ Intuitive navigation and user-friendly interface

## 🏗️ Architecture

### Frontend (Flutter)
- **Framework**: Flutter for cross-platform mobile development
- **State Management**: Provider/Riverpod
- **Key Packages**:
  - Firebase (Auth, Storage, Firestore)
  - Camera & Image Picker
  - Text-to-Speech
  - Video Player
  - HTTP/Dio for API calls

### Backend (FastAPI)
- **Framework**: FastAPI for high-performance REST API
- **Database**: PostgreSQL (primary), Firebase (auth/storage)
- **Key Features**:
  - Async/await support
  - SQLAlchemy ORM
  - RESTful API design
  - CORS middleware

### Database
- **PostgreSQL**: Stores recipes, nutrition data, user profiles, dietary preferences
- **Firebase**: User authentication, session management, multimedia storage

## 📁 Project Structure

```
smart-cooking-helper/
├── backend/                 # FastAPI backend
│   ├── app/
│   │   ├── api/            # API routes
│   │   ├── database/       # Database models and connection
│   │   ├── models/         # Pydantic schemas
│   │   └── services/       # Business logic
│   ├── main.py            # FastAPI application entry
│   └── requirements.txt   # Python dependencies
│
├── frontend/               # Flutter frontend
│   ├── lib/
│   │   ├── models/        # Data models
│   │   ├── screens/       # UI screens
│   │   │   ├── auth/      # Authentication screens
│   │   │   ├── cooking/   # Cooking assistant
│   │   │   ├── home/      # Dashboard
│   │   │   ├── profile/   # User profile
│   │   │   ├── recipe/    # Recipe search
│   │   │   ├── scanner/   # Ingredient scanner
│   │   │   └── shopping/  # Shopping list
│   │   ├── services/      # API and Firebase services
│   │   └── widgets/       # Reusable widgets
│   └── pubspec.yaml       # Flutter dependencies
│
├── database/              # Database scripts
│   └── schema.sql        # PostgreSQL schema
│
├── ABSTRACT.md           # Project abstract
├── SETUP_GUIDE.md        # Detailed setup instructions
└── README.md             # This file
```

## 🚀 Quick Start

### Prerequisites
- Python 3.11+
- Flutter 3.24+
- PostgreSQL 12+
- Firebase account

### Backend Setup

1. **Install dependencies**:
```bash
cd backend
python -m venv venv
python -m venv venv
# Activate the virtual environment (choose one):
# PowerShell (recommended):
.\venv\Scripts\Activate.ps1
# Command Prompt (cmd.exe):
venv\Scripts\activate.bat
# Git Bash / WSL / macOS / Linux:
source venv/bin/activate
pip install -r requirements.txt
```

2. **Setup database**:
```bash
# Create database
createdb smart_cooking_helper
# Windows note: `createdb` may not be on PATH. Use `psql` or the full path to createdb.exe.
# Example (PowerShell / CMD) using psql (Postgres bin must be in PATH):
psql -U postgres -c "CREATE DATABASE smart_cooking_helper;"
# Or use the full path to createdb.exe, e.g.:
# "C:\\Program Files\\PostgreSQL\\13\\bin\\createdb.exe" smart_cooking_helper

# Run schema
psql -U username -d smart_cooking_helper -f ../database/schema.sql
```

3. **Configure environment**:
Create `.env` file in `backend/`:
```env
DATABASE_URL=postgresql://user:password@localhost:5432/smart_cooking_helper
```

4. **Run server**:
```bash
python main.py
```

API available at `http://localhost:8000`
Docs at `http://localhost:8000/docs`

### Frontend Setup

1. **Install dependencies**:
```bash
cd frontend
flutter pub get
```

2. **Configure Firebase**:
- Create Firebase project
- Enable Authentication (Email, Google, Anonymous)
- Enable Firestore and Storage
- Run `flutterfire configure` or update `firebase_options.dart`

3. **Configure environment**:
Create `.env` file in `frontend/`:
```env
API_URL=http://localhost:8000/api
```

4. **Run app**:
```bash
flutter run
```

## 📚 API Documentation

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

## 🔧 Configuration

### Required API Keys
- Recipe API (e.g., Spoonacular, Edamam)
- Nutrition API (e.g., Open Food Facts, USDA)
- Barcode API (e.g., Open Food Facts)

### Firebase Setup
1. Create Firebase project
2. Enable Authentication methods
3. Enable Firestore Database
4. Enable Storage
5. Configure OAuth for Google Sign-In

## 🎯 Key Features Implementation

### AI-Powered Recommendations
The recommendation system analyzes available ingredients and matches them with recipes in the database, scoring based on ingredient overlap and dietary preferences.

### Cooking Assistant
- Step-by-step navigation with progress tracking
- Voice narration using Flutter TTS
- Integrated timer with pause/resume functionality
- Image/video support for visual guidance

### Ingredient Scanner
- Camera integration for barcode scanning
- Nutrition information lookup
- Shopping list integration

### Nutrition Tracking
- Real-time nutrition calculation
- Daily intake monitoring
- Health recommendations based on intake

## 🛠️ Development

### Backend Development
```bash
cd backend
source venv/bin/activate
uvicorn main:app --reload
```

### Frontend Development
```bash
cd frontend
flutter run
```

### Database Migrations
Use Alembic for database migrations (configured in requirements.txt)

## 📝 Notes

- The application uses API keys for external services (recipe search, nutrition, barcode scanning)
- Firebase handles authentication and file storage
- PostgreSQL stores all recipe and user data
- The app supports both light and dark themes

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request

## 📄 License

This project is licensed under the MIT License.

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- FastAPI for the high-performance backend
- Firebase for authentication and storage
- All open-source contributors

---

**Built with ❤️ for home cooks everywhere**
