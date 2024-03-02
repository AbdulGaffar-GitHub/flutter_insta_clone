import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:instagram_clone/model/post.dart';
import 'package:instagram_clone/resources/storage_methods.dart';
import 'package:instagram_clone/utils/constants.dart';
import 'package:uuid/uuid.dart';

class FirestoreMethods {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<String> uploadPost(
    String description,
    Uint8List file,
    String uid,
    String username,
    String profImg,
  ) async {
    String res = "some error occured";
    try {
      String photoUrl =
          await StorageMethods().uploadImageToStorage("posts", file, true);

      String postId = const Uuid().v1();

      Post post = Post(
        description: description,
        username: username,
        uid: uid,
        postId: postId,
        datePublished: DateTime.now(),
        postUrl: photoUrl,
        profImg: profImg,
        likes: [],
        likesNotifId: [],
      );
      _firestore.collection("posts").doc(postId).set(
            post.toJson(),
          );
      res = "success";
    } catch (e) {
      res = e.toString();
    }
    return res;
  }

  Future<void> likePost(String postId, String uid, List likes, String userName,
      String photoUrl) async {
    DocumentSnapshot snap =
        await _firestore.collection('posts').doc(postId).get();
    String notifId = const Uuid().v1();
    // print(snap.data());
    Post data = Post.fromSnap(snap);
    String userId = data.uid;
    String postBio = data.description;

    try {
      if (likes.contains(uid)) {
        await _firestore.collection('posts').doc(postId).update({
          'likes': FieldValue.arrayRemove([uid]),
        });
        // Delete the corresponding notification
        await _firestore
            .collection("users")
            .doc(userId)
            .collection("notifications")
            .where('postId', isEqualTo: postId)
            .where('type', isEqualTo: LIKE)
            .where('actionUid', isEqualTo: uid)
            .get()
            .then((snapshot) {
          for (DocumentSnapshot doc in snapshot.docs) {
            doc.reference.delete();
          }
        });
      } else {
        await _firestore.collection('posts').doc(postId).update({
          'likes': FieldValue.arrayUnion([uid]),
        });
        if (userId != uid) {
          await _firestore
              .collection("users")
              .doc(userId)
              .collection("notifications")
              .doc(notifId)
              .set({
            'notifId': notifId,
            'actionUid': uid,
            'postId': postId,
            'username': userName,
            'photoUrl': photoUrl,
            'content': "liked your post ",
            'postBio': postBio,
            'type': LIKE,
            'datePublished': DateTime.now(),
          });
        }
      }
    } catch (e) {
      print(e.toString());
    }
  }

  Future<String> postCommment(String postId, String text, String uid,
      String name, String profilePic) async {
    DocumentSnapshot snap =
        await _firestore.collection('posts').doc(postId).get();
    String notifId = const Uuid().v1();
    // print(snap.data());
    Post data = Post.fromSnap(snap);
    String userId = data.uid;
    String postBio = data.description;
    String res = '';
    try {
      if (text.isNotEmpty) {
        String commentId = const Uuid().v1();
        await _firestore
            .collection('posts')
            .doc(postId)
            .collection('comments')
            .doc(commentId)
            .set({
          'profilePic': profilePic,
          'name': name,
          'uid': uid,
          'text': text,
          'commentId': commentId,
          'datePublished': DateTime.now(),
        });

        if (userId != uid) {
          await _firestore
              .collection("users")
              .doc(userId)
              .collection("notifications")
              .doc(notifId)
              .set({
            'notifId': notifId,
            'actionUid': uid,
            'postId': postId,
            'username': name,
            'photoUrl': profilePic,
            'content': "commented on your post ",
            'postBio': postBio,
            'comment': text,
            'type': COMMENT,
            'datePublished': DateTime.now(),
          });
        }

        res = 'success';
      } else {
        res = "comment can\'t be empty";
        print("text is empty");
      }
    } catch (e) {
      res = e.toString();
      print(e.toString());
    }
    return res;
  }

  //delete posts
  Future<String> deletePost(String postId) async {
    String res = 'Something went wrong';
    try {
      await _firestore.collection('posts').doc(postId).delete();
      res = 'Post deleted';
    } catch (e) {
      res = e.toString();
      print(e.toString());
    }
    return res;
  }

  Future<void> followUser(String uid, String followId) async {
    try {
      DocumentSnapshot snap =
          await _firestore.collection('users').doc(uid).get();
      List following = (snap.data()! as dynamic)['following'];
      String name = (snap.data()! as dynamic)['username'];
      String profilePic = (snap.data()! as dynamic)['photoUrl'];
      String notifId = const Uuid().v1();
      // print(uid);
      // print(followId);
      if (following.contains(followId)) {
        await _firestore.collection('users').doc(followId).update({
          'followers': FieldValue.arrayRemove([uid])
        });
        await _firestore.collection('users').doc(uid).update({
          'following': FieldValue.arrayRemove([followId])
        });

        await _firestore
            .collection("users")
            .doc(followId)
            .collection("notifications")
            .where('actionUid', isEqualTo: uid)
            .where('type', isEqualTo: FOLLOW)
            .get()
            .then((snapshot) {
          for (DocumentSnapshot doc in snapshot.docs) {
            doc.reference.delete();
          }
        });
      } else {
        await _firestore.collection('users').doc(followId).update({
          'followers': FieldValue.arrayUnion([uid])
        });
        await _firestore.collection('users').doc(uid).update({
          'following': FieldValue.arrayUnion([followId])
        });

        await _firestore
            .collection("users")
            .doc(followId)
            .collection("notifications")
            .doc(notifId)
            .set({
          'notifId': notifId,
          'actionUid': uid,
          'username': name,
          'photoUrl': profilePic,
          'content': "started following you",
          'type': FOLLOW,
          'datePublished': DateTime.now(),
        });
      }
    } catch (e) {
      print(e.toString());
    }
  }

  Future<String> editProfile(
      String uid, Uint8List profilePic, String email, String bio) async {
    String res = '';
    try {
      String photoUrl = await StorageMethods()
          .uploadImageToStorage("profilePics", profilePic, false);
      await _firestore.collection("users").doc(uid).update({
        'photoUrl': photoUrl,
        'email': email,
        'bio': bio,
      });
      res = 'success';
    } catch (e) {
      res = e.toString();
      return e.toString();
    }

    return res;
  }
}
