# User Activity Log - Analytics System

## ✅ BACKEND IMPLEMENTATION COMPLETE

### Database Schema
Created `UserActivityLog` table with the following structure:
```sql
CREATE TABLE "UserActivityLog" (
  log_id SERIAL PRIMARY KEY,
  user_id INT REFERENCES "User"(user_id) ON DELETE CASCADE,
  action TEXT,
  log_time TIMESTAMP DEFAULT NOW()
);

-- Indexes for performance
CREATE INDEX idx_user_activity_user_time ON "UserActivityLog"(user_id, log_time DESC);
CREATE INDEX idx_user_activity_action ON "UserActivityLog"(action);
```

### API Endpoints

All endpoints require admin authentication (Bearer token in Authorization header).

#### 1. Get User Activity Logs
**GET** `/admin/users/:userId/activity`

Query parameters:
- `startDate` (optional): Filter activities after this date
- `endDate` (optional): Filter activities before this date
- `action` (optional): Filter by action type (supports partial match)
- `limit` (default: 50): Number of records to return
- `offset` (default: 0): Pagination offset

Response:
```json
{
  "success": true,
  "data": [
    {
      "log_id": 1,
      "action": "login",
      "log_time": "2025-11-14T20:09:57.000Z",
      "full_name": "User Name",
      "email": "user@example.com"
    }
  ],
  "total": 20,
  "limit": 50,
  "offset": 0
}
```

#### 2. Get User Activity Analytics
**GET** `/admin/users/:userId/activity/analytics`

Query parameters:
- `period` (default: 7d): Time period - `24h`, `7d`, `30d`, `90d`

Response:
```json
{
  "success": true,
  "period": "7d",
  "startDate": "2025-11-07T20:00:00.000Z",
  "endDate": "2025-11-14T20:00:00.000Z",
  "analytics": {
    "totalActivities": 20,
    "engagementScore": 43,
    "actionBreakdown": [
      {
        "action": "meal_created",
        "count": 6,
        "first_occurrence": "2025-11-14T20:08:51.000Z",
        "last_occurrence": "2025-11-14T20:09:57.000Z"
      }
    ],
    "timeline": [
      {
        "time_bucket": "2025-11-14T00:00:00.000Z",
        "count": 20,
        "actions": ["login", "meal_created", "food_searched"]
      }
    ],
    "hourlyPattern": [
      { "hour": 20, "count": 18 },
      { "hour": 21, "count": 2 }
    ],
    "weeklyPattern": [
      { "day": "Thu", "count": 20 }
    ],
    "recentMeals": [
      {
        "meal_date": "2025-11-14",
        "meal_type": "breakfast",
        "items_count": 1,
        "total_calories": 2750
      }
    ]
  }
}
```

#### 3. Log User Activity (Manual)
**POST** `/admin/users/:userId/activity`

Request body:
```json
{
  "action": "login"
}
```

Response:
```json
{
  "success": true,
  "message": "Activity logged successfully",
  "log": {
    "log_id": 21,
    "user_id": 9,
    "action": "login",
    "log_time": "2025-11-14T20:10:00.000Z"
  }
}
```

#### 4. Get Platform Activity Overview
**GET** `/admin/activity/overview`

Query parameters:
- `period` (default: 7d): Time period - `24h`, `7d`, `30d`, `90d`

Response:
```json
{
  "success": true,
  "period": "7d",
  "overview": {
    "totalActivities": 20,
    "activeUsers": 1,
    "topUsers": [
      {
        "user_id": 9,
        "full_name": "User Name",
        "email": "user@example.com",
        "activity_count": 20
      }
    ],
    "activityTypes": [
      { "action": "meal_created", "count": 6 },
      { "action": "food_searched", "count": 3 }
    ],
    "timeline": [
      {
        "time_bucket": "2025-11-14T00:00:00.000Z",
        "count": 20
      }
    ]
  }
}
```

### Engagement Score Calculation

The engagement score (0-100) is calculated based on:
- **60%**: Activity frequency
  - Expected activities per day based on period:
    - 24h: 10 activities = 100%
    - 7d: 30 activities = 100%
    - 30d: 100 activities = 100%
    - 90d: 200 activities = 100%
- **40%**: Meal logging consistency
  - Expected meals: period in days × 3 meals/day
  - Actual meals logged vs expected

Formula:
```javascript
activityScore = (totalActivities / expectedActivities) * 60
mealScore = (mealsLogged / expectedMeals) * 40
engagementScore = Math.min(100, activityScore + mealScore)
```

### Common Activity Action Types

The system tracks these activity types (can be extended):
- `login` - User login
- `logout` - User logout
- `meal_created` - Meal created
- `meal_updated` - Meal updated
- `meal_deleted` - Meal deleted
- `food_searched` - Food search performed
- `profile_updated` - Profile updated
- `settings_changed` - Settings changed
- `water_logged` - Water intake logged
- `bmr_tdee_recomputed` - BMR/TDEE recalculated
- `daily_targets_recomputed` - Daily targets recalculated

### Testing

Comprehensive test file: `backend/test_activity_api.js`

Run tests:
```bash
cd backend
node test_activity_api.js
```

Test coverage:
- ✅ Admin login
- ✅ Create activity logs
- ✅ Fetch activity logs with pagination
- ✅ Get user analytics with all metrics
- ✅ Get platform overview

### Files Created/Modified

**New Files:**
- `backend/controllers/adminActivityController.js` (384 lines)
- `backend/create_activity_table.js` - Database table creation
- `backend/test_activity_api.js` - Comprehensive API tests
- `backend/test_activity_simple.js` - Direct database tests

**Modified Files:**
- `backend/routes/admin.js` - Added 4 activity routes

**Database:**
- Created `UserActivityLog` table
- Created indexes: `idx_user_activity_user_time`, `idx_user_activity_action`

## 🔄 NEXT STEPS - FRONTEND IMPLEMENTATION

### 1. Create Flutter Admin Activity Screen

Location: `lib/screens/admin/admin_user_activity_screen.dart`

Features to implement:
- Period selector (24h, 7d, 30d, 90d)
- Tab navigation: Overview | Timeline | Patterns | Activity Log
- Engagement score gauge
- Action breakdown pie chart
- Timeline chart (line/bar chart)
- Hourly pattern bar chart (24 hours)
- Weekly pattern bar chart (7 days)
- Activity log list with pagination
- Recent meals summary

### 2. Add Chart Library

Add to `pubspec.yaml`:
```yaml
dependencies:
  fl_chart: ^0.66.0  # Recommended for lightweight charts
```

### 3. Create API Service

Location: `lib/services/admin_activity_service.dart`

Methods needed:
```dart
Future<ActivityLogsResponse> getUserActivityLogs(int userId, {String? startDate, String? endDate, String? action, int limit = 50, int offset = 0});
Future<ActivityAnalyticsResponse> getUserActivityAnalytics(int userId, {String period = '7d'});
Future<PlatformOverviewResponse> getPlatformActivityOverview({String period = '7d'});
Future<void> logUserActivity(int userId, String action);
```

### 4. Integrate Activity Logging Throughout App

Add automatic activity logging to:
- `lib/services/auth_service.dart`: Log "login" after successful auth
- Meal creation/update screens: Log "meal_created", "meal_updated"
- Profile screens: Log "profile_updated"
- Food search: Log "food_searched"
- Settings screens: Log "settings_changed"
- Water logging: Log "water_logged"

Create helper:
```dart
Future<void> logActivity(String action) async {
  // Call backend to log activity
  // Handle errors silently (don't disrupt user flow)
}
```

### 5. UI Design Mockup

**Overview Tab:**
- Large engagement score circular gauge (0-100%)
- Grid of metric cards:
  - Total Activities
  - Active Days
  - Most Active Hour
  - Most Common Action
- Recent Meals carousel

**Timeline Tab:**
- Date range selector
- Interactive line/bar chart showing activity over time
- Hover to see details

**Patterns Tab:**
- Hourly Activity Bar Chart (0-23 hours)
- Weekly Activity Bar Chart (Sun-Sat)
- Action Breakdown Pie Chart

**Activity Log Tab:**
- Searchable/filterable list
- Action type filter chips
- Date range picker
- Pagination controls
- Export to CSV option

### 6. Navigation Integration

Add to admin user details screen:
```dart
ElevatedButton.icon(
  icon: Icon(Icons.analytics),
  label: Text('View Activity Analytics'),
  onPressed: () {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AdminUserActivityScreen(userId: widget.userId),
      ),
    );
  },
)
```

## 📊 Sample Data

Test data has been created for User 9 with the following activities:
- 6× meal_created
- 3× food_searched
- 3× login
- 3× logout
- 3× profile_updated
- 1× bmr_tdee_recomputed
- 1× daily_targets_recomputed

Total: 20 activities

## 🎯 Implementation Priority

1. **HIGH**: Create Flutter activity analytics screen (basic UI)
2. **HIGH**: Implement API service layer
3. **MEDIUM**: Add charts (fl_chart integration)
4. **MEDIUM**: Implement automatic activity logging
5. **LOW**: Add export/advanced filtering features

## 📝 Notes

- All SQL queries use proper indexing for performance
- Engagement score algorithm can be tuned based on real usage data
- Activity logging should be non-blocking (fire-and-forget)
- Consider adding activity cleanup job (delete logs older than 6 months)
- Platform overview can be cached for 5-10 minutes to reduce DB load
