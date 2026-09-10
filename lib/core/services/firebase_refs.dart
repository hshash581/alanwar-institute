import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreRefs {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  static CollectionReference get users => _db.collection('users');
  static CollectionReference get usernames => _db.collection('usernames');
  static CollectionReference get students => _db.collection('students');
  static CollectionReference get teachers => _db.collection('teachers');
  static CollectionReference get classes => _db.collection('classes');
  static CollectionReference get subjects => _db.collection('subjects');
  static CollectionReference get schedules => _db.collection('schedules');
  static CollectionReference get attendance => _db.collection('attendance');
  static CollectionReference get payments => _db.collection('payments');
  static CollectionReference get assignments => _db.collection('assignments');
  static CollectionReference get announcements => _db.collection('announcements');
  static CollectionReference get notifications => _db.collection('notifications');
  static CollectionReference get settings => _db.collection('settings');
  static CollectionReference get counters => _db.collection('counters');

  static DocumentReference counter(String name) => counters.doc(name);

  static Future<String> nextSequence(String prefix) async {
    final docRef = counter(prefix);
    String result = '';
    await _db.runTransaction((transaction) async {
      final snapshot = await transaction.get(docRef);
      int current = 0;
      if (snapshot.exists) {
        current = (snapshot.data() as Map<String, dynamic>)['current'] ?? 0;
      }
      final next = current + 1;
      transaction.set(docRef, {'current': next});
      result = '$prefix-$next';
    });
    return result;
  }
}
