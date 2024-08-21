import 'package:flutter/material.dart';

import '../models/user.model.dart';

class SignInSheet extends StatelessWidget {
  SignInSheet({required this.user});
  final User user;

  final _passwordController = TextEditingController();

  Future _signIn(context, user) async {
    if (user.password == _passwordController.text) {
    } else {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            content: Text('Wrong password!'),
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            child: Text(
              'Welcome back, ' + user.user + '.',
              style: TextStyle(fontSize: 20),
            ),
          ),
          Container(
            child: Column(
              children: [
                SizedBox(height: 10),
                SizedBox(height: 10),
                Divider(),
                SizedBox(height: 10),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
