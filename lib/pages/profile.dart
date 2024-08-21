import 'dart:io';

import 'package:flutter/material.dart';

class Profile extends StatelessWidget {
  const Profile(this.username, {required this.imagePath});
  final String username;
  final String imagePath;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.black,
                      image: DecorationImage(
                        fit: BoxFit.cover,
                        image: FileImage(File(imagePath)),
                      ),
                    ),
                    margin: EdgeInsets.all(20),
                    width: 50,
                    height: 50,
                  ),
                  Text(
                    'Hi ' + username + '!',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              Container(
                margin: EdgeInsets.all(20),
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Color(0xFFFEFFC1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  children: [
                    Icon(
                      Icons.warning_amber_outlined,
                      size: 30,
                    ),
                    SizedBox(
                      height: 10,
                    ),
                    Text(
                      '''If you think this project seems interesting and you want to contribute or need some help implementing it, dont hesitate and lets get in touch!''',
                      style: TextStyle(fontSize: 16),
                      textAlign: TextAlign.left,
                    ),
                    Divider(
                      height: 30,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
