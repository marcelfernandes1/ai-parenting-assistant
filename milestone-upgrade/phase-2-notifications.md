# Phase 2: Push Notifications & Reminders

**Goal:** Keep parents engaged with timely, relevant milestone notifications

**Estimated Time:** 1-2 weeks
**Priority:** 🔥 Critical (Retention)
**Progress:** 0/6 tasks complete (0%)

---

## Tasks

### Task 2.1: Add flutter_local_notifications & Configure Permissions
**Status:** ⏳ Pending

**Description:**
Install notification package and configure iOS/Android permissions for local notifications.

**Flutter Package:**
```yaml
# mobile/pubspec.yaml
dependencies:
  flutter_local_notifications: ^17.0.0
```

**iOS Configuration (mobile/ios/Runner/Info.plist):**
```xml
<key>UIBackgroundModes</key>
<array>
  <string>fetch</string>
  <string>remote-notification</string>
</array>
```

**Android Configuration (mobile/android/app/src/main/AndroidManifest.xml):**
```xml
<uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM"/>
<uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
<uses-permission android:name="android.permission.VIBRATE"/>
<uses-permission android:name="android.permission.RECEIVE_BOOT_COMPLETED"/>
```

**Commands:**
```bash
cd mobile
flutter pub get
cd ios && pod install && cd ..
```

**Testing:**
- Build and run on iOS device/simulator
- Build and run on Android device/emulator
- Verify no permission errors

---

### Task 2.2: Create NotificationService in Flutter
**Status:** ⏳ Pending
**Dependencies:** Task 2.1

**Description:**
Create service class to handle notification initialization, scheduling, and display.

**File to Create:**
`mobile/lib/shared/services/notification_service.dart`

**Service Requirements:**

```dart
class NotificationService {
  final FlutterLocalNotificationsPlugin _notifications;

  // Initialize notifications
  Future<void> initialize()

  // Request permissions (iOS)
  Future<bool> requestPermissions()

  // Schedule notification
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDate,
    String? payload,
  })

  // Schedule daily notification at specific time
  Future<void> scheduleDailyNotification({
    required int id,
    required String title,
    required String body,
    required Time time,
  })

  // Cancel specific notification
  Future<void> cancelNotification(int id)

  // Cancel all notifications
  Future<void> cancelAllNotifications()

  // Show immediate notification
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  })

  // Handle notification tap
  void onNotificationTap(NotificationResponse response)
}
```

**Provider:**
Create `mobile/lib/shared/providers/notification_provider.dart` with Riverpod provider

**Testing:**
- Initialize service in main.dart
- Request permissions on first launch
- Test showing immediate notification
- Verify notification tap handling

---

### Task 2.3: Add NotificationPreferences Model to Schema
**Status:** ⏳ Pending

**Description:**
Add database model to store user notification preferences.

**Schema Addition (backend/prisma/schema.prisma):**
```prisma
model NotificationPreferences {
  id                      String  @id @default(uuid())
  userId                  String  @unique
  user                    User    @relation(fields: [userId], references: [id], onDelete: Cascade)

  // Notification type toggles
  milestoneUnlocked       Boolean @default(true)
  upcomingMilestone       Boolean @default(true)
  healthCheckupReminder   Boolean @default(true)
  celebrationAlert        Boolean @default(true)
  weeklyDevelopmentUpdate Boolean @default(true)

  // Quiet hours (24-hour format strings)
  quietHoursStart         String? // e.g., "22:00"
  quietHoursEnd           String? // e.g., "07:00"

  // Device tokens for push notifications (future use)
  deviceTokens            String[] @default([])

  createdAt               DateTime @default(now())
  updatedAt               DateTime @updatedAt
}

// Add to User model
model User {
  // ... existing fields ...
  notificationPreferences NotificationPreferences?
}
```

**Migration:**
```bash
cd backend
npx prisma migrate dev --name add_notification_preferences
npx prisma generate
```

**API Endpoints:**
Create `backend/src/routes/notifications.ts`:
- GET /notifications/preferences - Get user preferences
- PUT /notifications/preferences - Update preferences
- POST /notifications/test - Send test notification

---

### Task 2.4: Install Packages & Create Notification Scheduler
**Status:** ⏳ Pending
**Dependencies:** Task 2.3

**Description:**
Install backend packages and create scheduled job to check for milestone notifications.

**Packages:**
```bash
cd backend
npm install node-cron@^3.0.3
npm install firebase-admin@^12.0.0  # For push notifications
```

**File to Create:**
`backend/src/services/notificationScheduler.ts`

**Scheduler Requirements:**
- Run daily at 9:00 AM (configurable)
- Check all users' baby ages
- Identify newly unlocked milestones (age-appropriate)
- Send notifications via Firebase Cloud Messaging (FCM)
- Respect quiet hours
- Respect user preferences

**Notification Types to Implement:**

1. **Milestone Unlocked** (daily check at 9 AM)
   ```
   🎉 Emma is 6 months old!

   New milestones available:
   • Sitting Up
   • First Solid Foods
   • Self-Feeding with Hands

   Tap to learn more →
   ```

2. **Upcoming Milestone** (2 weeks before typical age)
   ```
   👀 Heads up!

   Emma may start crawling in the next 2-4 weeks!
   Check out activities to encourage this milestone →
   ```

3. **Health Checkup Reminder** (1 week before due)
   ```
   🏥 Reminder

   Emma's 9-month checkup is due soon
   We've prepared questions based on her development →
   ```

4. **Celebration** (after milestone logged)
   ```
   🏆 Amazing!

   Emma just achieved her 15th milestone!
   You're doing great, parent! 💪
   ```

5. **Weekly Development Update** (Sundays at 8 AM)
   ```
   📊 This Week with Emma

   • 3 new milestones unlocked
   • Physical development: On track ✓
   • Try this activity: [suggestion]

   View progress →
   ```

**Cron Schedule:**
```typescript
import cron from 'node-cron';

// Daily at 9:00 AM
cron.schedule('0 9 * * *', async () => {
  await checkMilestoneUnlocks();
  await checkUpcomingMilestones();
  await checkHealthReminders();
});

// Sundays at 8:00 AM
cron.schedule('0 8 * * 0', async () => {
  await sendWeeklyUpdates();
});
```

**Testing:**
- Run scheduler manually
- Verify notifications sent to test devices
- Check database for notification logs

---

### Task 2.5: Create Notification Settings Screen
**Status:** ⏳ Pending
**Dependencies:** Task 2.2, 2.3

**Description:**
Build UI for users to control notification preferences.

**File to Create:**
`mobile/lib/features/settings/presentation/notification_settings_screen.dart`

**Screen Features:**
- Toggle switches for each notification type:
  - ✅ Milestone Unlocked
  - ✅ Upcoming Milestone
  - ✅ Health Checkup Reminder
  - ✅ Celebration Alerts
  - ✅ Weekly Development Update

- Quiet Hours section:
  - Start time picker
  - End time picker
  - Clear explanation: "No notifications during these hours"

- Test notification button
- Save button (auto-save on toggle)

**UI Requirements:**
- Material 3 design
- Clear labels and descriptions
- Immediate feedback on toggle
- Show loading state during save
- Show success message after save

**Navigation:**
Add link from main Settings screen to Notification Settings

**Testing:**
- Toggle each preference type
- Set quiet hours
- Send test notification
- Verify preferences persist after app restart
- Test that quiet hours are respected

---

### Task 2.6: Implement All 5 Notification Types & Test End-to-End
**Status:** ⏳ Pending
**Dependencies:** All previous tasks

**Description:**
Complete implementation of all notification types and perform comprehensive testing.

**Implementation Checklist:**

**Backend:**
- [ ] Milestone Unlocked: Check baby age vs. milestone age ranges daily
- [ ] Upcoming Milestone: Predict milestones 2-4 weeks ahead
- [ ] Health Checkup: Calculate checkup dates based on baby birth date
- [ ] Celebration: Trigger on milestone creation (webhook/event)
- [ ] Weekly Update: Generate summary of week's progress

**Flutter:**
- [ ] Handle notification tap → navigate to relevant screen
- [ ] Show notification badge on app icon
- [ ] Parse notification payload correctly
- [ ] Deep link to milestone detail/guide screens

**Testing Matrix:**

| Notification Type | Test Case | Expected Result |
|------------------|-----------|-----------------|
| Milestone Unlocked | Baby turns 6 months | Notification at 9 AM with 3 new milestones |
| Upcoming Milestone | Baby is 7.5 months | Notification about crawling (typical at 8 months) |
| Health Checkup | 1 week before 9-month checkup | Reminder notification with prep questions |
| Celebration | User logs 15th milestone | Immediate celebration notification |
| Weekly Update | Sunday morning | Summary of week's milestones and insights |
| Quiet Hours | Notification during quiet hours | No notification delivered |
| Disabled Type | User disables celebration | No celebration notifications |

**End-to-End Testing:**
1. Create test user with baby age = 5 months 29 days
2. Wait until baby turns 6 months (or adjust system date)
3. Verify milestone unlocked notification at 9 AM
4. Tap notification → should open milestones screen with new milestones highlighted
5. Disable milestone unlocked in settings
6. Verify no more milestone unlocked notifications
7. Log a milestone → verify celebration notification appears
8. Set quiet hours 10 PM - 7 AM
9. Trigger notification at 11 PM → should be queued until 7 AM
10. Test weekly update on Sunday morning

**Acceptance Criteria:**
✅ All 5 notification types work correctly
✅ Notifications respect user preferences
✅ Quiet hours are respected
✅ Notification tap navigates correctly
✅ No crashes or errors
✅ Notifications are timely and relevant
✅ Backend scheduler runs reliably
✅ Database stores notification logs

---

## Phase 2 Complete! 🎉

**When all 6 tasks are done:**
- Mark phase as complete in TODO-MILESTONE-UPGRADE.md
- Update progress: 14/53 tasks (26%)
- Commit with message: `[Milestone Upgrade] Complete Phase 2: Push Notifications`
- Move to Phase 3

**Next Phase:** [Phase 3: Progress Tracking & Insights](./phase-3-progress-tracking.md)

---

*Last Updated: 2025-01-31*
