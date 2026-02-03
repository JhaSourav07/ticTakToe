import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/room_model.dart';

class DatabaseService {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Create a new Room
  static Future<void> createRoom(RoomModel room) async {
    await _db.collection('rooms').doc(room.roomId).set(room.toJson());
  }

  // Join an existing Room
  static Future<bool> joinRoom(String roomId, String playerId) async {
    DocumentSnapshot doc = await _db.collection('rooms').doc(roomId).get();

    if (doc.exists) {
      RoomModel room = RoomModel.fromJson(doc.data() as Map<String, dynamic>);
      
      // If room is not full, add player 2
      if (room.player2Id.isEmpty) {
        await _db.collection('rooms').doc(roomId).update({'player2Id': playerId});
        return true;
      }
    }
    return false;
  }

  // Listen to Room updates (Real-time!)
  static Stream<DocumentSnapshot> roomStream(String roomId) {
    return _db.collection('rooms').doc(roomId).snapshots();
  }

  // Update Board Move
  static Future<void> updateGame(String roomId, List<String> board, String nextTurn) async {
    await _db.collection('rooms').doc(roomId).update({
      'board': board,
      'turn': nextTurn,
    });
  }

  // Declare Winner
  static Future<void> setWinner(String roomId, String winner) async {
    await _db.collection('rooms').doc(roomId).update({
      'winner': winner,
      'isGameActive': false,
    });
  }
}