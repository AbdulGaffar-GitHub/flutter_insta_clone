import 'package:cloud_firestore/cloud_firestore.dart';

class Post {
  final String description;
  final String uid;
  final String username;
  final String postId;
  final datePublished;
  final String postUrl;
  final String profImg;
  final likes;
  final likesNotifId;

  const Post({
    required this.description,
    required this.username,
    required this.uid,
    required this.postId,
    required this.datePublished,
    required this.postUrl,
    required this.profImg,
    required this.likes,
    required this.likesNotifId,
  });

  Map<String, dynamic> toJson() => {
        'username': username,
        'uid': uid,
        'description': description,
        'postId': postId,
        'datePublished': datePublished,
        'postUrl': postUrl,
        'profImg': profImg,
        'likes': likes,
        'likeNotifId': likesNotifId,
      };

  static Post fromSnap(DocumentSnapshot snap) {
    var snapshot = snap.data() as Map<String, dynamic>;
    return Post(
      description: snapshot['description'],
      username: snapshot['username'],
      uid: snapshot['uid'],
      postId: snapshot['postId'],
      datePublished: snapshot['datePublished'],
      postUrl: snapshot['postUrl'],
      profImg: snapshot['profImg'],
      likes: snapshot['likes'],
      likesNotifId: snapshot['likesNotifId'],
    );
  }
}
