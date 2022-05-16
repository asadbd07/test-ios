import 'package:flutter/material.dart';
import 'package:singer_otp/main.dart';

class NotAllowed extends StatelessWidget {
  const NotAllowed({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Device Issue')),
      body: Center(
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 12.0),
              child: Text(
                  'Your Device did not matched with your account.\n Contact with System Administrator.',
                  style: TextStyle(
                      color: Colors.pink,
                      fontWeight: FontWeight.bold,
                      fontSize: 20)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const MyApp()),
                );
              },
              child: const Text('Sign In Again'),
            ),
          ],
        ),
      ),
    );
  }
}
