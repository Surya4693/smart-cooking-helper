# Smart Cooking Helper - Testing Guide

## Backend Testing

### Unit Tests

Create `backend/tests/test_recipes.py`:
```python
import pytest
from app.services.recipe_service import RecipeService
from app.database.database import SessionLocal

@pytest.fixture
def db():
    return SessionLocal()

@pytest.fixture
def recipe_service():
    return RecipeService()

def test_search_recipes(db, recipe_service):
    results = recipe_service.search_recipes(db, "tomato")
    assert isinstance(results, list)
    assert len(results) > 0

def test_get_recipe_details(db, recipe_service):
    recipe = recipe_service.get_recipe_details(db, "recipe-1")
    assert recipe is not None
    assert "title" in recipe

def test_get_recommendations(db, recipe_service):
    ingredients = ["tomato", "onion", "rice"]
    recommendations = recipe_service.get_recommendations(db, ingredients)
    assert isinstance(recommendations, list)
```

### Integration Tests

```python
from fastapi.testclient import TestClient
from main import app

client = TestClient(app)

def test_search_endpoint():
    response = client.get("/api/recipes/search?q=tomato")
    assert response.status_code == 200
    assert "recipes" in response.json()

def test_today_recommendation():
    response = client.post("/api/recipes/today-recommendation", 
        json={"dietary_preferences": ["vegetarian"]})
    assert response.status_code == 200
```

### Run Tests

```bash
# Run all tests
pytest

# Run with coverage
pytest --cov=app

# Run specific test
pytest tests/test_recipes.py::test_search_recipes -v
```

## Frontend Testing

### Widget Tests

Create `frontend/test/widgets/recipe_card_test.dart`:
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:smart_cooking_helper/models/recipe_model.dart';

void main() {
  group('Recipe Card Widget', () {
    testWidgets('displays recipe information', (WidgetTester tester) async {
      final recipe = Recipe(
        id: '1',
        title: 'Test Recipe',
        // ... other properties
      );

      // Build widget
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(body: RecipeCard(recipe: recipe)),
        ),
      );

      // Verify
      expect(find.text('Test Recipe'), findsOneWidget);
      expect(find.byIcon(Icons.timer), findsOneWidget);
    });
  });
}
```

### Run Widget Tests

```bash
# Run all tests
flutter test

# Run specific test
flutter test test/widgets/recipe_card_test.dart

# Run with coverage
flutter test --coverage
```

## API Testing

### Manual Testing with Curl

```bash
# Search recipes
curl -X GET "http://localhost:8000/api/recipes/search?q=tomato"

# Get recommendations
curl -X POST "http://localhost:8000/api/recipes/recommendations" \
  -H "Content-Type: application/json" \
  -d '{"available_ingredients": ["tomato", "onion", "rice"]}'

# Get today recommendation
curl -X POST "http://localhost:8000/api/recipes/today-recommendation" \
  -H "Content-Type: application/json" \
  -d '{"dietary_preferences": ["vegetarian"]}'

# Add to favorites
curl -X POST "http://localhost:8000/api/favorites/add" \
  -H "Content-Type: application/json" \
  -H "user-id: user-123" \
  -d '{"recipe_id": "recipe-1"}'
```

### Postman Collection

1. Create new collection: "Smart Cooking Helper"
2. Add requests:

**Search Recipes**
```
Method: GET
URL: {{base_url}}/api/recipes/search?q=tomato
```

**Get Recommendations**
```
Method: POST
URL: {{base_url}}/api/recipes/recommendations
Body: {
  "available_ingredients": ["tomato", "onion", "rice"]
}
```

**Get Favorites**
```
Method: GET
URL: {{base_url}}/api/favorites
Headers: {
  "user-id": "user-123"
}
```

### Load Testing with Artillery

Install Artillery:
```bash
npm install -g artillery
```

Create `load-test.yml`:
```yaml
config:
  target: "http://localhost:8000"
  phases:
    - duration: 60
      arrivalRate: 10

scenarios:
  - name: "Search Recipes"
    flow:
      - get:
          url: "/api/recipes/search?q=tomato"

  - name: "Get Recommendations"
    flow:
      - post:
          url: "/api/recipes/recommendations"
          json:
            available_ingredients: ["tomato", "onion"]
```

Run test:
```bash
artillery run load-test.yml
```

## Database Testing

### Test Data Setup

```sql
-- Insert test recipes
INSERT INTO recipes VALUES (...);
INSERT INTO nutrition_info VALUES (...);

-- Verify data
SELECT COUNT(*) FROM recipes;
SELECT * FROM recipes WHERE title LIKE '%tomato%';
```

### Database Integrity Tests

```python
def test_database_schema(db):
    # Check tables exist
    inspector = inspect(db.bind)
    tables = inspector.get_table_names()
    
    assert 'recipes' in tables
    assert 'nutrition_info' in tables
    assert 'user_profiles' in tables
```

## Performance Testing

### Backend Performance

```bash
# Time database query
time curl -X GET "http://localhost:8000/api/recipes/search?q=tomato"

# Check query execution time in logs
tail -f logs/app.log | grep "query_time"
```

### Frontend Performance

```bash
# Run performance profiling
flutter run -v > flutter.log 2>&1

# Check frame rate
grep "jank" flutter.log

# Memory usage
flutter run --track-widget-creation
```

## Continuous Testing

### GitHub Actions CI/CD

Create `.github/workflows/test.yml`:
```yaml
name: Tests

on: [push, pull_request]

jobs:
  backend-tests:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - uses: actions/setup-python@v2
        with:
          python-version: 3.9
      - run: pip install -r backend/requirements.txt
      - run: pytest backend/tests

  frontend-tests:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - uses: subosito/flutter-action@v1
        with:
          flutter-version: '3.0.0'
      - run: cd frontend && flutter pub get
      - run: cd frontend && flutter test
```

## Test Coverage Goals

- **Backend**: Aim for 80%+ coverage
- **Frontend**: Aim for 70%+ coverage for critical features
- **API Endpoints**: 100% coverage

## Testing Checklist

### Before Release
- [ ] All unit tests pass
- [ ] All integration tests pass
- [ ] Load testing completed (100+ req/sec)
- [ ] Database backup tested
- [ ] Error handling verified
- [ ] Security scanning passed
- [ ] Documentation updated
- [ ] Staging environment verified

### Regression Testing
- [ ] Previous features still work
- [ ] No new bugs introduced
- [ ] Performance maintained
- [ ] All API endpoints respond correctly

## Common Issues & Solutions

### Test Database Connection Issues
```python
# Use test database
TEST_DATABASE_URL = "postgresql://user:pass@localhost:5432/test_db"

# Clean up after tests
@pytest.fixture(autouse=True)
def cleanup(db):
    yield
    db.query(Recipe).delete()
    db.commit()
```

### Flaky Tests
- Increase timeout values
- Use proper async/await handling
- Mock external dependencies

### Test Speed
- Parallelize tests with pytest-xdist
- Use in-memory databases for tests
- Mock external API calls

## Monitoring & Metrics

### Key Metrics to Monitor
- API response time (target: <200ms)
- Database query time (target: <100ms)
- Error rate (target: <0.1%)
- CPU usage (target: <70%)
- Memory usage (target: <80%)

### Tools
- Sentry for error tracking
- Datadog for APM
- New Relic for monitoring
- Prometheus + Grafana for metrics

## Test Maintenance

1. Keep tests updated with code changes
2. Remove obsolete tests
3. Add tests for new features
4. Review test coverage regularly
5. Optimize slow tests
6. Document test scenarios
