# Daily Meal Suggestions - Backend API Documentation

## Overview
Backend API for "Daily Meal Suggestions" feature - intelligent meal planning system that generates personalized daily meal recommendations based on user's nutrient gaps, health conditions, and meal preferences.

## Architecture

### Recent Improvements (Dec 2025)

**Service Refactoring:**
1. **Dynamic Nutrient Mapping** - Replaced hardcoded nutrient IDs (1-26) with dynamic query from nutrient table
2. **Database-Driven Requirements** - Uses UserVitaminRequirement/UserMineralRequirement instead of Harris-Benedict formula
3. **User Validation** - Added checks for age, gender, weight, height with descriptive error messages
4. **N+1 Query Fix** - Batch nutrient queries with `WHERE dish_id = ANY($1)` instead of individual queries
5. **Schema Alignment** - Updated all queries to match actual database schema:
   - Table names: `Meal`/`MealItem` (not meallog)
   - Column names: `dish_id`/`drink_id` (not id), `condition_id` (not healthcondition_id)
   - Amount columns: `amount_per_100g`/`amount_per_100ml` (not amount)

**Testing:**
- Test script: `backend/test_daily_meal_suggestion.js`
- Sample user: truongngoclinh312@gmail.com (ID: 2, 19yo, Female, 42kg, 160cm)
- Results: Successfully generates 3+3+3+2 = 11 suggestions for 4 meals

### Files Created
```
backend/
├── services/
│   └── dailyMealSuggestionService.js      [660 lines] - Core business logic
├── controllers/
│   └── dailyMealSuggestionController.js   [230 lines] - API endpoint handlers
├── routes/
│   └── dailyMealSuggestions.js            [80 lines] - Route definitions
└── others/
    └── index.js                           [UPDATED] - Route registration
```

### Service Layer (`dailyMealSuggestionService.js`)

**Core Algorithm:**
1. **Get user settings** - meal counts, times, percentages, health profile
2. **Calculate daily nutrient gaps** - RDA targets minus consumed nutrients
3. **Distribute gaps by meal** - breakfast 25%, lunch 35%, dinner 30%, snack 10%
4. **Filter contraindications** - exclude foods that conflict with health conditions
5. **Score & rank options** - optimal dish/drink combinations (0-100 score)
6. **Save suggestions** - persist to database with scores

**Key Methods:**

```javascript
// Generate complete daily suggestions
generateDailySuggestions(userId, date)
  Returns: { success, date, nutrientGaps, suggestions: {breakfast, lunch, dinner, snack} }

// Get existing suggestions
getSuggestions(userId, date)
  Returns: { breakfast: [...], lunch: [...], dinner: [...], snack: [...] }

// Accept a suggestion
acceptSuggestion(suggestionId)
  Returns: { ...suggestion, is_accepted: true }

// Reject and generate new
rejectSuggestion(suggestionId)
  Returns: { success, message }

// Delete suggestion
deleteSuggestion(suggestionId)

// Cleanup operations
cleanupOldSuggestions()           // Remove >7 days old
cleanupPassedMeals(userId)        // Remove past meal times
```

**RDA Calculation:**
- Uses database requirement tables (UserVitaminRequirement, UserMineralRequirement, UserAminoRequirement, UserFiberRequirement, UserFattyAcidRequirement)
- Nutrient mapping via VitaminNutrient and MineralNutrient join tables
- Personalized requirements per user (age, gender, activity level)
- Dynamic nutrient tracking (no hardcoded IDs)

**Scoring Algorithm:**
```javascript
Score = Σ(min(nutrient_provided, gap) / gap) / nutrient_count × 100

Example:
- Meal needs: 500 kcal, 20g protein, 10g fiber
- Dish provides: 450 kcal, 25g protein, 8g fiber
- Score = [(450/500) + (20/20) + (8/10)] / 3 × 100 = 90.0
```

### Controller Layer (`dailyMealSuggestionController.js`)

RESTful API endpoints with Vietnamese error messages.

**Endpoints:**

| Method | Endpoint | Description | Auth |
|--------|----------|-------------|------|
| POST | `/api/suggestions/daily-meals` | Generate suggestions | ✅ Required |
| GET | `/api/suggestions/daily-meals` | Get suggestions | ✅ Required |
| GET | `/api/suggestions/daily-meals/stats` | Get statistics | ✅ Required |
| PUT | `/api/suggestions/daily-meals/:id/accept` | Accept suggestion | ✅ Required |
| PUT | `/api/suggestions/daily-meals/:id/reject` | Reject & regenerate | ✅ Required |
| DELETE | `/api/suggestions/daily-meals/:id` | Delete suggestion | ✅ Required |
| POST | `/api/suggestions/daily-meals/cleanup` | Cleanup old (admin) | ✅ Admin only |
| POST | `/api/suggestions/daily-meals/cleanup-passed` | Cleanup passed meals | ✅ Required |

**Security:**
- All routes require authentication (`authenticateToken` middleware)
- Ownership verification on accept/reject/delete operations
- Admin-only access for manual cleanup

### Routes Layer (`dailyMealSuggestions.js`)

Express Router with comprehensive route documentation.

**Base Path:** `/api/suggestions/daily-meals`

**Route Order (Important!):**
```javascript
// Specific routes BEFORE parameterized routes
GET  /stats                  // Must be before /:id
POST /cleanup                // Must be before /:id
POST /cleanup-passed         // Must be before /:id
PUT  /:id/accept            // Parameterized routes last
PUT  /:id/reject
DELETE /:id
```

## API Usage Examples

### 1. Generate Daily Suggestions

**Request:**
```bash
POST /api/suggestions/daily-meals
Authorization: Bearer <token>
Content-Type: application/json

{
  "date": "2025-12-08"  // Optional, defaults to today
}
```

**Response:**
```json
{
  "success": true,
  "message": "Đã tạo gợi ý bữa ăn thành công",
  "data": {
    "date": "2025-12-08",
    "nutrientGaps": {
      "1": 1850.5,  // Energy kcal
      "2": 65.2,    // Protein
      "7": 420.0    // Calcium
      // ... more nutrients
    },
    "suggestions": {
      "breakfast": [
        { "meal_type": "breakfast", "dish_id": 152, "score": 87.5 },
        { "meal_type": "breakfast", "drink_id": 68, "score": 72.3 }
      ],
      "lunch": [...],
      "dinner": [...],
      "snack": [...]
    }
  }
}
```

### 2. Get Current Suggestions

**Request:**
```bash
GET /api/suggestions/daily-meals?date=2025-12-08
Authorization: Bearer <token>
```

**Response:**
```json
{
  "success": true,
  "data": {
    "breakfast": [
      {
        "id": 123,
        "user_id": 1,
        "date": "2025-12-08",
        "meal_type": "breakfast",
        "dish_id": 152,
        "dish_name": "Fermented Fish Vermicelli",
        "dish_vietnamese_name": "Bún Mắm Cá Linh",
        "dish_category": "main_course",
        "drink_id": null,
        "is_accepted": false,
        "is_rejected": false,
        "suggestion_score": 87.50,
        "created_at": "2025-12-08T07:00:00Z"
      },
      {
        "id": 124,
        "dish_id": null,
        "drink_id": 68,
        "drink_name": "Sweet Tonic Drink",
        "drink_vietnamese_name": "Nước Sâm Bổ Lượng",
        "suggestion_score": 72.30
      }
    ],
    "lunch": [...],
    "dinner": [...],
    "snack": [...]
  }
}
```

### 3. Accept a Suggestion

**Request:**
```bash
PUT /api/suggestions/daily-meals/123/accept
Authorization: Bearer <token>
```

**Response:**
```json
{
  "success": true,
  "message": "Đã chấp nhận gợi ý",
  "data": {
    "id": 123,
    "is_accepted": true,
    "is_rejected": false,
    "updated_at": "2025-12-08T08:30:00Z"
  }
}
```

### 4. Reject and Get New Suggestion

**Request:**
```bash
PUT /api/suggestions/daily-meals/123/reject
Authorization: Bearer <token>
```

**Response:**
```json
{
  "success": true,
  "message": "Đã từ chối gợi ý và tạo gợi ý mới",
  "data": {
    "success": true,
    "message": "Suggestion rejected and new one generated"
  }
}
```

### 5. Get Statistics

**Request:**
```bash
GET /api/suggestions/daily-meals/stats?startDate=2025-12-01&endDate=2025-12-08
Authorization: Bearer <token>
```

**Response:**
```json
{
  "success": true,
  "data": [
    {
      "meal_type": "breakfast",
      "total_suggestions": 16,
      "accepted_count": 12,
      "rejected_count": 3,
      "avg_score": 82.45,
      "days_with_suggestions": 8
    },
    {
      "meal_type": "lunch",
      "total_suggestions": 16,
      "accepted_count": 10,
      "rejected_count": 4,
      "avg_score": 78.90,
      "days_with_suggestions": 8
    }
  ]
}
```

### 6. Delete a Suggestion

**Request:**
```bash
DELETE /api/suggestions/daily-meals/123
Authorization: Bearer <token>
```

**Response:**
```json
{
  "success": true,
  "message": "Đã xóa gợi ý"
}
```

### 7. Cleanup Passed Meals

**Request:**
```bash
POST /api/suggestions/daily-meals/cleanup-passed
Authorization: Bearer <token>
```

**Response:**
```json
{
  "success": true,
  "message": "Đã dọn dẹp gợi ý đã qua giờ",
  "data": {
    "cleanup_passed_meal_suggestions": "Cleaned up 3 passed meal suggestions"
  }
}
```

## Integration Points

### Database Dependencies
- `user` - User profile (age, gender, weight, height, activity_level)
- `usersetting` - Meal counts, times, percentages
- `Meal`, `MealItem` - Consumed dishes/drinks today (replaces meallog/waterlog)
- `dish`, `drink` - Food items
- `dishnutrient`, `drinknutrient` - Nutrient data (amount_per_100g, amount_per_100ml)
- `userhealthcondition` - User's health conditions
- `foodhealthcondition`, `drugnutrientcontraindication` - Contraindications
- `user_daily_meal_suggestions` - Generated suggestions
- `uservitaminrequirement`, `usermineralrequirement` - Personalized nutrient requirements
- `vitaminnutrient`, `mineralnutrient` - Mapping tables (vitamin/mineral → nutrient_id)

### Required Middleware
```javascript
const authenticateToken = require('../middleware/authenticateToken');
```

Expected to decode JWT and attach `req.user = { id, role }`.

### Database Connection
```javascript
const pool = require('../config/database');
```

PostgreSQL connection pool.

## Error Handling

All endpoints return consistent error format:

```json
{
  "success": false,
  "message": "Lỗi khi tạo gợi ý bữa ăn",
  "error": "User settings not found"
}
```

**Common Errors:**
- `404` - Suggestion not found
- `403` - Unauthorized (not owner)
- `500` - Server error (database, calculation)

## Performance Considerations

**Optimization Strategies:**
1. **Candidate Limiting**: Max 50 dishes, 30 drinks per query
2. **Random Sampling**: `ORDER BY RANDOM() LIMIT N`
3. **Index Usage**: Uses indexes on `user_daily_meal_suggestions(user_id, date)`
4. **Batch Operations**: Single transaction for all meal suggestions
5. **Scoring Cache**: Could add Redis cache for dish/drink scores

**Bottlenecks:**
- Requirement table queries (vitamins/minerals via mapping tables)
- Scoring algorithm (candidate items × tracked nutrients)
- Contraindication filtering (complex joins)
- Batch nutrient queries (uses ANY($1) to avoid N+1 problem)

**Recommended Improvements:**
```javascript
// Cache RDA targets per user (changes infrequently)
const rdaCache = new Map();

// Pre-calculate dish scores for common gaps
const dishScoreCache = new Map();

// Use materialized view for contraindications
CREATE MATERIALIZED VIEW user_contraindicated_foods AS ...
```

## Testing

### Manual Testing with cURL

```bash
# Set your auth token
TOKEN="your_jwt_token_here"

# Generate suggestions
curl -X POST http://localhost:3000/api/suggestions/daily-meals \
  -H "Authorization: Bearer $TOKEN" \
  -H "Content-Type: application/json" \
  -d '{"date":"2025-12-08"}'

# Get suggestions
curl -X GET "http://localhost:3000/api/suggestions/daily-meals?date=2025-12-08" \
  -H "Authorization: Bearer $TOKEN"

# Accept suggestion ID 123
curl -X PUT http://localhost:3000/api/suggestions/daily-meals/123/accept \
  -H "Authorization: Bearer $TOKEN"

# Get stats
curl -X GET "http://localhost:3000/api/suggestions/daily-meals/stats?startDate=2025-12-01" \
  -H "Authorization: Bearer $TOKEN"
```

### Unit Test Structure (TODO)

```javascript
describe('DailyMealSuggestionService', () => {
  describe('generateDailySuggestions', () => {
    it('should generate suggestions for all 4 meals');
    it('should respect max 2 dishes per meal');
    it('should filter contraindicated foods');
    it('should score dishes 0-100');
  });
  
  describe('_calculateRDATargets', () => {
    it('should calculate male BMR correctly');
    it('should apply activity multiplier');
    it('should return 26 nutrient targets');
  });
});
```

## Deployment Checklist

- [ ] Run database migrations (8 files in order)
- [ ] Verify nutrient data (30 dishes × 58 nutrients)
- [ ] Test authentication middleware
- [ ] Configure CORS for frontend domain
- [ ] Set up cron job for daily cleanup
- [ ] Monitor API performance (slow queries)
- [ ] Add logging for suggestion generation
- [ ] Set up error tracking (Sentry, etc.)

## Next Steps

### Phase 3: Flutter Frontend
- Create `daily_meal_suggestion_tab.dart` (2-tab layout)
- Create `meal_selection_dialog.dart` (count selection with validation)
- Create suggestion display widgets with nutrient comparison
- Integrate with Add Meal/Water dialogs (yellow border)

### Phase 4: Integration
- Call `/cleanup-passed` on app launch
- Show suggestions in Smart Suggestions screen
- Highlight accepted suggestions in Add dialogs
- Sync suggestion state across screens

### Phase 5: Enhancements
- Add Redis caching for scores
- Implement A/B testing for algorithms
- Add ML model for personalized scoring
- Support meal swapping (breakfast ↔ lunch)

---
**Created:** 2025-12-08  
**Status:** Backend Complete ✅ | Frontend Pending | Integration Pending  
**Files:** 3 new + 1 updated | 970 lines of code
