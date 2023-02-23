import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class MessageChip extends StatelessWidget {
  const MessageChip({
    Key? key,
    required this.poruka,
  }) : super(key: key);

  final Map<String, dynamic> poruka;

  @override
  Widget build(BuildContext context) {
    final uid = FirebaseAuth.instance.currentUser!.uid;

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        crossAxisAlignment: poruka['od'] == uid
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(
                color: poruka['od'] == uid
                    ? Color.fromRGBO(31, 93, 120, 1)
                    : Colors.grey,
                borderRadius: BorderRadius.all(Radius.circular(16.0))),
            padding: EdgeInsets.all(8.0),
            child: Text(
              poruka['poruka'],
              maxLines: 100,
              style: TextStyle(
                color: Colors.white,
              ),
            ),
          ),
          Text(
            poruka['datumVreme'].toDate().toString().substring(11, 16),
          ),
        ],
      ),
    );
  }
}
