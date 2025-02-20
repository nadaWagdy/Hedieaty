# Hedieaty - Gift List Management App

## 📌 Overview

Hedieaty is a cross-platform mobile application built with **Flutter** that allows users to create, manage, and share gift lists for special occasions. The app enables users to add gifts, organize them into event-based lists, and share these lists with friends and family. Friends can view the lists and pledge gifts to help streamline gifting experiences.

## 🚀 Features

- **User Authentication**: Secure login and registration.
- **Event Management**: Create, edit, delete, and categorize events.
- **Gift List Management**: Add, edit, delete, and categorize gifts.
- **Gift Pledging**: Friends can pledge gifts to prevent duplicate purchases.
- **Sorting & Filtering**: Sort events by name, category, and status.
- **Cloud Synchronization**: Data stored and synced in real time using Firebase.
- **Dark Mode Support**: UI designed with a modern dark theme.
- **Notification System**: Alerts users when a friend pledges a gift.

## 🛠 Tech Stack

- **Frontend**: Flutter (Dart)
- **Backend**: Firebase (Real-time Database, Authentication, Cloud Storage)
- **Database**: Firebase (Real-time Database, SQLite Local Database)

## 🎨 UI Layout

### 1️⃣ Home Page

- Displays a list of friends with profile pictures and event status.
- Quick access to create a new event or gift list.
- Search functionality for finding gift lists.

### 2️⃣ Event List Page

- Displays user-created events with sorting options.
- CRUD operations for event management.

### 3️⃣ Gift List Page

- Displays gifts associated with selected events.
- CRUD operations for gift management.
- Visual indicators for pledged gifts.

### 4️⃣ Gift Details Page

- Displays all details of a gift

### 5️⃣ Friend’s Pages

- Friends can view and pledge gifts from shared lists.
- Users receive notifications when a gift is pledged.

### 6️⃣ Profile Page

- User profile management.
- Overview of created events and pledged gifts.

### 7️⃣ My Pledged Gifts Page

- Displays a list of gifts the user has pledged to friends.
- Allows modifications if the pledge is still pending.
