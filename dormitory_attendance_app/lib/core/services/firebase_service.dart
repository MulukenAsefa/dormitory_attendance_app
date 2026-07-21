import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';

class FirebaseService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseStorage _storage = FirebaseStorage.instance;

  // Firestore operations
  static Future<DocumentSnapshot> getDocument(String collection, String docId) async {
    return await _firestore.collection(collection).doc(docId).get();
  }

  static Future<QuerySnapshot> getCollection(String collection) async {
    return await _firestore.collection(collection).get();
  }

  static Future<void> setDocument(
    String collection,
    String docId,
    Map<String, dynamic> data,
  ) async {
    await _firestore.collection(collection).doc(docId).set(data);
  }

  static Future<void> updateDocument(
    String collection,
    String docId,
    Map<String, dynamic> data,
  ) async {
    await _firestore.collection(collection).doc(docId).update(data);
  }

  static Future<void> deleteDocument(String collection, String docId) async {
    await _firestore.collection(collection).doc(docId).delete();
  }

  static Stream<DocumentSnapshot> streamDocument(String collection, String docId) {
    return _firestore.collection(collection).doc(docId).snapshots();
  }

  static Stream<QuerySnapshot> streamCollection(String collection) {
    return _firestore.collection(collection).snapshots();
  }

  // Storage operations
  static Future<String?> uploadFile({
    required File file,
    required String path,
    String? contentType,
  }) async {
    try {
      final ref = _storage.ref().child(path);
      final uploadTask = await ref.putFile(
        file,
        SettableMetadata(contentType: contentType),
      );
      return await uploadTask.ref.getDownloadURL();
    } catch (e) {
      print('Error uploading file: $e');
      return null;
    }
  }

  static Future<bool> deleteFile(String path) async {
    try {
      await _storage.ref().child(path).delete();
      return true;
    } catch (e) {
      print('Error deleting file: $e');
      return false;
    }
  }

  static Future<String?> getDownloadUrl(String path) async {
    try {
      return await _storage.ref().child(path).getDownloadURL();
    } catch (e) {
      print('Error getting download URL: $e');
      return null;
    }
  }

  // Batch operations
  static WriteBatch batch() {
    return _firestore.batch();
  }

  static Future<void> commitBatch(WriteBatch batch) async {
    await batch.commit();
  }

  // Transaction operations
  static Future<T> runTransaction<T>(
    Future<T> Function(Transaction) transactionHandler,
  ) async {
    return await _firestore.runTransaction(transactionHandler);
  }
}
