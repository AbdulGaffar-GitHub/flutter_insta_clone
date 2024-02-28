import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:instagram_clone/utils/constants.dart';

class NotificationCard extends StatefulWidget {
  final snap;

  const NotificationCard({super.key, required this.snap});

  @override
  State<NotificationCard> createState() => _NotificationCardState();
}

class _NotificationCardState extends State<NotificationCard> {
  String duration = "";
  String? content = '';
  String getDuration(DateTime startDate, DateTime endDate) {
    Duration difference = endDate.difference(startDate);
    if (difference.inSeconds < 60) {
      return '${difference.inSeconds}s';
    }
    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m';
    }
    if (difference.inHours < 24) {
      return '${difference.inHours}h';
    }
    if (difference.inDays < 7) {
      return '${difference.inDays}d';
    }
    if (difference.inDays < 30) {
      return '${(difference.inDays / 7).floor()}w';
    }
    if (difference.inDays < 365) {
      return '${(difference.inDays / 30).floor()}mo';
    }
    return '${(difference.inDays / 365).floor()}y';
  }

  @override
  void initState() {
    super.initState();
    DateTime startDate = (widget.snap['datePublished'] as Timestamp).toDate();
    duration = getDuration(startDate, DateTime.now());
    // content = widget.snap['postBio'];
    // final int maxLength = 10;

    // if (content != null) {
    //   if (content!.length > maxLength) {
    //     content = content!.substring(0, maxLength) + '...';
    //   }
    // }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 18.0,
        vertical: 12.0,
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundImage: NetworkImage(widget.snap['photoUrl']),
            radius: 20,
          ),
          SizedBox(
            width: 10,
          ),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: widget.snap['username'],
                  style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
                ),
                TextSpan(
                  text: "  ${widget.snap['content']} \n",
                  style: TextStyle(fontWeight: FontWeight.normal),
                ),
                if (widget.snap['type'] != FOLLOW)
                  widget.snap['type'] == COMMENT
                      ? TextSpan(
                          text: " ${widget.snap['comment']}  ",
                          style: TextStyle(
                              fontWeight: FontWeight.normal,
                              color: Colors.grey),
                        )
                      : TextSpan(
                          text: " \"${widget.snap['postBio']}\" ",
                          style: TextStyle(fontWeight: FontWeight.normal),
                        ),
                TextSpan(
                  text: " $duration",
                  style: TextStyle(fontWeight: FontWeight.w200),
                )
              ],
            ),
            softWrap: true,
          ),
        ],
      ),
    );
  }
}
