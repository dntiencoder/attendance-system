import 'package:cloud_firestore/cloud_firestore.dart';
import '../domain/company_settings_model.dart';

class SettingsRepository {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<CompanySettingsModel> getSettings() {
    return _db.collection('company_settings')
        .doc('main')
        .snapshots()
        .map((doc) => CompanySettingsModel.fromFirestore(doc));
  }

  Future<void> updateSettings(CompanySettingsModel settings) async {
    await _db.collection('company_settings').doc('main').set(settings.toFirestore(), SetOptions(merge: true));
  }
}
