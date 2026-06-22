# Firestore Database Schema - Attendance System

This document outlines the Firestore collection structure and data types used in the mobile application.

## 1. Collection: `company_settings`
Contains global configurations for the attendance system.
- **Document ID**: `main` (usually)

| Field | Type | Description |
| :--- | :--- | :--- |
| `companyName` | String | Name of the company |
| `latitude` | Double | Latitude of office location |
| `longitude` | Double | Longitude of office location |
| `radius` | Double | Allowed check-in radius (meters) |
| `dayShiftStart` | String | Day shift start time (e.g., "08:00") |
| `dayShiftEnd` | String | Day shift end time (e.g., "20:00") |
| `nightShiftStart` | String | Night shift start time (e.g., "20:00") |
| `nightShiftEnd` | String | Night shift end time (e.g., "08:00") |
| `rotationDays` | Int | Days between shift group rotations |
| `rotationStartDate` | Timestamp | Start date for calculating rotations |
| `updatedAt` | Timestamp | Last configuration update |

---

## 2. Collection: `users`
Employee profiles and account roles.
- **Document ID**: Firebase Auth `uid`

| Field | Type | Description |
| :--- | :--- | :--- |
| `employeeCode` | String | Unique employee ID (e.g., "EMP001") |
| `name` | String | Full name |
| `email` | String | Email address |
| `role` | String | `admin` \| `employee` |
| `shiftGroup` | String | `A` \| `B` (for rotation logic) |
| `departmentId` | String | Reference to `departments` ID |
| `phone` | String | Phone number |
| `avatarUrl` | String | URL to profile picture |
| `isActive` | Boolean | Account status |
| `createdAt` | Timestamp | Registration date |

---

## 3. Collection: `attendance`
Daily check-in and check-out records.
- **Document ID**: `{yyyy-MM-dd}_{uid}`

| Field | Type | Description |
| :--- | :--- | :--- |
| `uid` | String | Employee UID |
| `employeeCode` | String | Employee Code |
| `shift` | String | `day` \| `night` |
| `attendanceDate` | Timestamp | Date of attendance (at 00:00) |
| `checkIn` | Timestamp | Actual check-in time |
| `checkOut` | Timestamp | Actual check-out time |
| `latitude` | Double | Check-in latitude |
| `longitude` | Double | Check-in longitude |
| `distance` | Double | Distance from office at check-in (meters) |
| `checkOutLatitude` | Double | Check-out latitude |
| `checkOutLongitude` | Double | Check-out longitude |
| `workHours` | Double | Total hours worked |
| `isLate` | Boolean | True if checked in after shift start |
| `isEarlyLeave` | Boolean | True if checked out before shift end |
| `status` | String | `completed` \| `early_leave` \| `late` \| `on_time` |
| `createdAt` | Timestamp | Record creation time |

---

## 4. Collection: `leave_requests`
Absence and leave management.
- **Document ID**: Auto-generated

| Field | Type | Description |
| :--- | :--- | :--- |
| `uid` | String | Employee UID |
| `employeeCode` | String | Employee Code |
| `startDate` | Timestamp | Start of leave |
| `endDate` | Timestamp | End of leave |
| `reason` | String | Reason for leave |
| `status` | String | `pending` \| `approved` \| `rejected` |
| `adminNote` | String | Feedback from manager |
| `createdAt` | Timestamp | Request creation time |
| `updatedAt` | Timestamp | Last update time |

---

## 5. Collection: `departments`
Company organizational units.
- **Document ID**: `depXXX` (e.g., `dep001`)

| Field | Type | Description |
| :--- | :--- | :--- |
| `name` | String | Department name |
| `managerUid` | String | UID of the department manager |
| `createdAt` | Timestamp | Creation time |

---

## 6. Collection: `notifications`
System and manager notifications.
- **Document ID**: Auto-generated

| Field | Type | Description |
| :--- | :--- | :--- |
| `uid` | String | Recipient UID |
| `title` | String | Notification title |
| `body` | String | Message content |
| `type` | String | `system` \| `leave` \| `attendance` |
| `isRead` | Boolean | Read status |
| `createdAt` | Timestamp | Creation time |

---

## 7. Collection: `dev_metadata`
Development and seeding tracking.

| Field | Type | Description |
| :--- | :--- | :--- |
| `seeded` | Boolean | True if initial data was created |
| `seededAt` | Timestamp | Last seeding date |
