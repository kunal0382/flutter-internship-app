import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/task_model.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get tasks collection reference for current user
  CollectionReference get _tasksCollection {
    final userId = _auth.currentUser?.uid;
    if (userId == null) {
      throw Exception('User not authenticated');
    }
    return _firestore.collection('users').doc(userId).collection('tasks');
  }

  // Add a new task
  Future<void> addTask({
    required String title,
    required String description,
  }) async {
    try {
      final task = TaskModel(
        id: '',
        title: title,
        description: description,
        createdDate: DateTime.now(),
      );

      await _tasksCollection.add(task.toMap());
    } catch (e) {
      throw Exception('Failed to add task: $e');
    }
  }

  // Get tasks stream (real-time updates)
  Stream<List<TaskModel>> getTasksStream() {
    return _tasksCollection
        .orderBy('createdDate', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return TaskModel.fromFirestore(doc);
      }).toList();
    });
  }

  // Delete a task
  Future<void> deleteTask(String taskId) async {
    try {
      await _tasksCollection.doc(taskId).delete();
    } catch (e) {
      throw Exception('Failed to delete task: $e');
    }
  }

  // Update a task
  Future<void> updateTask({
    required String taskId,
    required String title,
    required String description,
  }) async {
    try {
      await _tasksCollection.doc(taskId).update({
        'title': title,
        'description': description,
      });
    } catch (e) {
      throw Exception('Failed to update task: $e');
    }
  }
}
