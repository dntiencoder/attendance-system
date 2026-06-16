class AppConfig {
  // Firestore
  static const String companySettingsDocId = 'main';

  // GPS
  static const double defaultRadius = 100; // mét
  static const int gpsTimeoutSeconds = 15;

  // Role
  static const String roleAdmin = 'admin';
  static const String roleEmployee = 'employee';

  // Leave status
  static const String statusPending = 'pending';
  static const String statusApproved = 'approved';
  static const String statusRejected = 'rejected';

  // Notification type
  static const String notifSystem = 'system';
  static const String notifLeaveApproved = 'leave_approved';
  static const String notifLeaveRejected = 'leave_rejected';
}