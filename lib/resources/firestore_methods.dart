import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:instagram_clone/model/post.dart';
import 'package:instagram_clone/resources/storage_methods.dart';
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
          likes: []);
      _firestore.collection("posts").doc(postId).set(
            post.toJson(),
          );
      res = "success";
    } catch (e) {
      res = e.toString();
    }
    return res;
  }

  Future<void> likePost(String postId, String uid, List likes) async {
    try {
      if (likes.contains(uid)) {
        await _firestore.collection('posts').doc(postId).update({
          'likes': FieldValue.arrayRemove([uid]),
        });
      } else {
        await _firestore.collection('posts').doc(postId).update({
          'likes': FieldValue.arrayUnion([uid]),
        });
      }
    } catch (e) {
      print(e.toString());
    }
  }

  Future<String> postCommment(String postId, String text, String uid,
      String name, String profilePic) async {
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

  Future<void> followUser(
      String uid,
      String followId
      ) async{
      try{
       DocumentSnapshot snap = await _firestore.collection('users').doc(uid).get();
       List following = (snap.data()! as dynamic)['following'];
       print(uid);
       print(followId);
       if(following.contains(followId)){
         await _firestore.collection('users').doc(followId).update({
           'followers' : FieldValue.arrayRemove([uid])
         });
         await _firestore.collection('users').doc(uid).update({
           'following' : FieldValue.arrayRemove([followId])
         });
       }else{
         await _firestore.collection('users').doc(followId).update({
           'followers' : FieldValue.arrayUnion([uid])
         });
         await _firestore.collection('users').doc(uid).update({
           'following' : FieldValue.arrayUnion([followId])
         });
       }
       
      }catch(e){
        print(e.toString());
      }
  }
}
