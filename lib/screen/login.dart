import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:singer_otp/constants.dart';
import 'home.dart';
import 'not_allowed.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:platform_device_id/platform_device_id.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({Key? key}) : super(key: key);

  @override
  LoginFormState createState() {
    return LoginFormState();
  }
}

// Create a corresponding State class.
// This class holds data related to the form.
class LoginFormState extends State<LoginForm> {
  // Create a global key that uniquely identifies the Form widget
  // and allows validation of the form.
  //
  // Note: This is a GlobalKey<FormState>,
  // not a GlobalKey<LoginFormState>.
  final _formKey = GlobalKey<FormState>();
  final emploYeeid = TextEditingController();
  final password = TextEditingController();

  String _deviceId = '';

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    emploYeeid.dispose();
    password.dispose();
    super.dispose();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String? deviceId;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      deviceId = await PlatformDeviceId.getDeviceId;
    } on PlatformException {
      deviceId = 'Failed to get deviceId.';
    }
    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _deviceId = deviceId!;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Build a Form widget using the _formKey created above.
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding:
                const EdgeInsets.symmetric(vertical: 25.0, horizontal: 0.0),
            child: Image.asset('assets/images/singer_logo.png',
                height: 70, fit: BoxFit.fill),
          ),
          Padding(
            padding:
                const EdgeInsets.symmetric(vertical: 20.0, horizontal: 20.0),
            child: TextFormField(
              controller: emploYeeid,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.people),
                border: OutlineInputBorder(),
                labelText: 'Employee ID',
              ),
              // The validator receives the text that the user has entered.
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter employee id';
                }
                return null;
              },
            ),
          ),
          Padding(
            padding:
                const EdgeInsets.symmetric(vertical: 20.0, horizontal: 20.0),
            child: TextFormField(
              obscureText: true,
              controller: password,
              decoration: const InputDecoration(
                prefixIcon: Icon(Icons.lock),
                border: OutlineInputBorder(),
                labelText: 'Password',
              ),
              // The validator receives the text that the user has entered.
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter password';
                }
                return null;
              },
            ),
          ),
          ConstrainedBox(
            constraints: const BoxConstraints.tightFor(width: 100, height: 40),
            child: ElevatedButton(
              onPressed: () async {
                String url = "$apiBaseURL/token/";
                var response = await http.post(Uri.parse(url), headers: {
                  "Accept": "application/json",
                }, body: {
                  "username": emploYeeid.text,
                  "password": password.text,
                });

                if (response.statusCode == 200) {
                  var x = json.decode(response.body.toString());
                  // ignore: non_constant_identifier_names
                  var Token = TokenStore.fromJson(x);
                  saveUserToken(Token.access);

                  //Check Device
                  String durl = "$apiBaseURL/device/";
                  String token = Token.access;
                  String device = _deviceId;
                  var dresponse = await http.put(Uri.parse(durl), headers: {
                    "Accept": "application/json",
                    "Authorization": "Bearer $token",
                  }, body: {
                    "device_id": device.toString(),
                  });

                  if (dresponse.statusCode == 200) {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const Home()),
                    );
                  } else if (dresponse.statusCode == 404) {
                    String device = _deviceId;
                    String eurl = "$apiBaseURL/check-device/$device/";
                    String token = Token.access;

                    var eresponse = await http.get(
                      Uri.parse(eurl),
                      headers: {
                        "Accept": "application/json",
                        "Authorization": "Bearer $token",
                      },
                    );

                    if (eresponse.statusCode == 200) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const Home()),
                      );
                    } else {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const NotAllowed()),
                      );
                    }
                  } else if (dresponse.statusCode == 500) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Device Already Registered !')),
                    );
                  }
                  // Check Device End

                } else {
                  if (_formKey.currentState!.validate()) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Incorrect Credentials !')),
                    );
                  }
                }
              },
              child: const Text('SIGN IN'),
            ),
          ),
          Expanded(
            child: Align(
              alignment: FractionalOffset.bottomCenter,
              child: Text("Device ID: $_deviceId"),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> saveUserToken(access) async {
    String token = access;
    // ignore: invalid_use_of_visible_for_testing_member
    SharedPreferences.setMockInitialValues({});
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("token", token);
  }
}

class TokenStore {
  TokenStore({
    required this.access,
    required this.refresh,
  });

  late String access;
  late String refresh;

  TokenStore.fromJson(Map<String, dynamic> json) {
    access = json['access'];
    refresh = json['refresh'];
  }
}
