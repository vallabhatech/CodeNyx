# CodeNyx — Hackathon Companion App

Technical Architecture & System Design Specification (v3)

---

# 1. Overview

CodeNyx is a mobile application designed to support and coordinate participants during a college hackathon event.

The application acts as a **central digital hub** where participants can:

• Join their assigned team
• View hackathon announcements
• Track event schedule
• Share updates and progress through a social feed
• Request mentor assistance
• Submit their project

The system is designed to support **350+ participants and ~70–100 teams** during the hackathon.

The architecture prioritizes:

• Fast development
• Stability during real-time activity
• Minimal backend complexity
• Efficient storage usage
• High engagement through a shared event feed

The application is built using **Flutter** for the frontend and **Supabase** for backend services.

---

# 2. Technology Stack

## Frontend

Flutter (cross-platform mobile framework)

Libraries:

flutter_riverpod → state management
go_router → navigation
supabase_flutter → backend integration
flutter_image_compress → image compression
image_picker → image selection
flutter_hooks (optional) → UI state simplification

Key design goals:

• modular architecture
• reactive UI updates
• efficient media handling
• minimal navigation complexity

---

## Backend

Supabase

Services used:

• PostgreSQL Database
• Realtime subscriptions
• Storage (for compressed social feed images)
• REST API auto-generation

Reasons for Supabase:

• relational database ideal for structured data
• realtime updates for social feed
• simple backend infrastructure
• ideal for rapid hackathon development

---

# 3. Core User Flow

Application lifecycle flow:

```
App Launch
↓
Splash Screen
↓
Team Join Screen
↓
Team Verification
↓
Team Dashboard
↓
Main Feature Modules
```

---

# 4. Application Screens

## 4.1 Splash Screen

Purpose:
Display branding while initializing the application.

Displayed for **2–3 seconds**.

Elements:

CodeNyx Logo
Hackathon Title
Animated loading indicator

After loading → navigate to **Team Join Screen**.

---

## 4.2 Team Join Screen

Participants authenticate using hackathon credentials.

Inputs required:

• Hackathon Email
• Team ID

Example:

Email: [participant@college.edu](mailto:participant@college.edu)
Team ID: TEAM-142

Validation logic:

1. Verify team exists
2. Verify email belongs to that team
3. Mark participant as joined

If successful:

Navigate to **Team Dashboard**.

---

# 5. Core Dashboard

The **Team Dashboard** acts as the main navigation hub.

Information shown:

Team Name
Project Title
Members Joined Count

Example:

Team: Quantum Coders
Members Joined: 3 / 4
Project: AI Resume Analyzer

Primary modules accessible from dashboard:

Announcements
Schedule
Social Feed
Mentor Requests
Project Submission

---

# 6. Feature Modules

---

# 6.1 Announcements System

Organizers can broadcast updates to all participants.

Examples:

Mentor session starting in Hall B
Lunch available in cafeteria
Submission deadline updated

Implementation:

Announcements stored in database.

App subscribes using **Supabase realtime**.

Updates appear instantly across all devices.

---

# 6.2 Hackathon Schedule

Displays official hackathon timeline.

Example:

9:00 AM — Opening Ceremony
11:00 AM — Mentor Round
2:00 PM — Checkpoint
8:00 PM — Final Submission

Schedule data is stored in database.

Participants can quickly reference upcoming events.

---

# 6.3 Social Feed (Hackathon Activity Feed)

Participants can share updates, progress, and moments during the hackathon.

Example posts:

• “Finally deployed our backend!”
• “Looking for UI help”
• “Debugging for 3 hours straight”
• “Free pizza near Hall B”

Post features:

• text updates
• optional image uploads
• like posts
• optional comments

Feed is ordered by **most recent activity**.

Images are stored in **Supabase Storage** after compression.

Purpose of the feed:

• increase engagement
• showcase team progress
• create a shared hackathon atmosphere

---

# 6.4 Image Compression Pipeline

To maintain performance and stay within Supabase free tier limits, all images are **compressed on the client before upload**.

Upload pipeline:

```
User selects image
↓
Flutter app compresses image locally
↓
Image resized to max width/height 1080px
↓
Quality reduced to ~70%
↓
Compressed image generated
↓
Upload to Supabase Storage
↓
Public URL saved in posts.image_url
```

Typical compression results:

```
Original camera image: 4–6 MB
Compressed image: 400–800 KB
```

Compression settings:

```
maxWidth: 1080
maxHeight: 1080
quality: 70
format: JPEG
```

Benefits:

• faster uploads
• reduced bandwidth usage
• lower storage consumption
• smoother feed loading

---

# 6.5 Storage Configuration

Supabase Storage is used for storing compressed feed images.

Storage bucket:

```
feed-images
```

Bucket configuration:

```
Public bucket: true
Max file size: 2 MB
Allowed MIME types:
image/jpeg
image/png
image/webp
```

Upload rules:

• images must be compressed before upload
• server rejects files larger than 2 MB
• image URLs are stored in the posts table

---

# 6.6 Mentor Request System

Teams can request mentor assistance.

Categories include:

AI
Backend
Mobile
UI/UX
Blockchain

Request contains:

Team ID
Category
Description

Mentor can update request status:

pending
accepted
resolved

Mentor dashboard (optional) can display incoming requests.

---

# 6.7 Project Submission

Teams submit their final project through the app.

Required fields:

GitHub Repository
Demo Video Link
Project Description

Optional:

Presentation Slides

Submission is stored in database and visible to organizers.

Each team can submit **only once**.

---

# 7. Database Schema

Relational PostgreSQL schema.

---

## teams table

Stores team metadata.

Fields:

team_id (primary key)
team_name
project_name
created_at

---

## team_members table

Stores participant information.

Fields:

id
team_id (foreign key)
email
name
joined (boolean)

---

## announcements table

Fields:

id
title
message
created_at

---

## schedule table

Fields:

id
event_name
event_time
description

---

## posts table

Stores social feed posts.

Fields:

id
user_email
team_id
content
image_url
created_at

---

## likes table

Tracks likes on posts.

Fields:

id
post_id
user_email
created_at

Constraint:

```
UNIQUE(post_id, user_email)
```

Ensures a user can like a post only once.

---

## comments table (optional)

Fields:

id
post_id
user_email
comment
created_at

---

## mentor_requests table

Fields:

id
team_id
category
description
status
created_at

status values:

pending
accepted
resolved

---

## submissions table

Fields:

team_id
github_link
demo_video
description
submitted_at

---

# 8. Feed Query Strategy

Posts are retrieved in reverse chronological order.

Example query:

```
SELECT * FROM posts
ORDER BY created_at DESC
LIMIT 20
```

Pagination strategy:

```
Load first 20 posts
↓
User scrolls
↓
Fetch next batch
```

This prevents heavy database queries.

---

# 9. Realtime Architecture

Supabase Realtime is used for:

Announcements
Social Feed updates
Mentor Requests

Example feed update flow:

```
User creates post
↓
Database insert
↓
Supabase realtime broadcast
↓
All clients update feed instantly
```

Realtime events listened:

INSERT → new post appears
DELETE → post removed
UPDATE → edited post updates

---

# 10. Scalability

Expected load:

350+ participants
70–100 teams

Estimated database usage:

```
< 20 MB
```

Estimated storage usage:

```
400–700 MB (compressed images)
```

Supabase free tier supports:

```
500 MB database
1 GB storage
2 GB bandwidth
```

This architecture comfortably fits within the free tier.

---

# 11. Security Model

Basic access rules:

Participants can:

• post on social feed
• like posts
• submit project for their team
• request mentor help

Restrictions:

• users cannot modify other teams
• users cannot like a post multiple times
• submissions limited to one per team
• organizer tools restricted

Server validation ensures:

```
post.user_email must match authenticated user
```

---

# 12. Folder Structure (Flutter)

Recommended structure:

```
lib/

app/
router.dart
app.dart

core/
constants/
theme/

features/

auth/
team_join_screen.dart
auth_repository.dart

dashboard/
dashboard_screen.dart

announcements/
announcements_screen.dart

schedule/
schedule_screen.dart

social_feed/
feed_screen.dart
create_post_screen.dart
feed_repository.dart
image_upload_service.dart

mentor_requests/
mentor_request_screen.dart

submission/
submission_screen.dart

services/
supabase_service.dart
```

---

# 13. Future Improvements

Possible extensions:

Push Notifications
Judge Dashboard
Team Progress Tracker
Live Leaderboard
Hackathon Analytics
Hashtags (#progress #help #idea)

---

# 14. Design Philosophy

CodeNyx focuses on:

Fast onboarding
Minimal complexity
High participant engagement
Efficient media handling

Participants should be able to:

Join their team within 10 seconds
See important information instantly
Share updates easily
Submit projects without confusion

The goal is to create a **central digital hub for the entire hackathon event**.

---

# 15. MVP Scope

Minimum viable product includes:

Splash Screen
Team Join Authentication
Team Dashboard
Announcements
Schedule
Social Feed (text + compressed images)
Project Submission

All other features are optional enhancements.

---

End of Technical Architecture Specification
