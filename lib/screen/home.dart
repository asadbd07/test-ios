import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:singer_otp/main.dart';
import 'dart:async';
import 'package:geolocator/geolocator.dart';
import '../constants.dart';

class Home extends StatelessWidget {
  const Home({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Generate OTP"),
      ),
      body: const OtpForm(),
    );
  }
}

// Create a Form widget.
class OtpForm extends StatefulWidget {
  const OtpForm({Key? key}) : super(key: key);

  @override
  OtpFormState createState() {
    return OtpFormState();
  }
}

class OtpFormState extends State<OtpForm> {
  final _formKey = GlobalKey<FormState>();
  final String lattitude = '';
  final String longitude = '';

  final siteCode = TextEditingController();

  String _otp = 'Tap GET OTP';

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    siteCode.dispose();
    super.dispose();
  }

  Future<Position> _getGeoLocationPosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled don't continue
      // accessing the position and request users of the
      // App to enable the location services.
      await Geolocator.openLocationSettings();
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Permissions are denied forever, handle appropriately.
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    //permissions are granted and we can
    return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best);
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
                const EdgeInsets.symmetric(vertical: 20.0, horizontal: 40.0),
            child: TextFormField(
              controller: siteCode,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Site Code',
              ),
              // The validator receives the text that the user has entered.
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return "Please enter site code";
                }
                return null;
              },
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 16.0, horizontal: 40.0),
            child: Text(
              'Your OTP:',
              style: TextStyle(fontSize: 20.0),
            ),
          ),
          Padding(
            padding:
                const EdgeInsets.symmetric(vertical: 40.0, horizontal: 40.0),
            child: Text(
              _otp,
              style: const TextStyle(fontSize: 40.0, fontFamily: 'ProFont'),
            ),
          ),
          ConstrainedBox(
            constraints: const BoxConstraints.tightFor(width: 150, height: 50),
            child: ElevatedButton(
              onPressed: () async {
                Position position = await _getGeoLocationPosition();

                String url = "$apiBaseURL/create/otp/";
                String token = await _token();

                var response = await http.post(Uri.parse(url), headers: {
                  "Accept": "application/json",
                  "Authorization": "Bearer $token",
                }, body: {
                  "site_code": siteCode.text,
                  "lattitude": position.latitude.toString(),
                  "longitude": position.longitude.toString(),
                });

                if (response.statusCode == 201) {
                  var x = json.decode(response.body.toString());
                  var otp = OtpCode.fromJson(x);
                  setState(() {
                    _otp = otp.otp;
                  });
                } else if (response.statusCode == 401) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const MyApp()),
                  );
                } else {
                  if (_formKey.currentState!.validate()) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please try again..')),
                    );
                  }
                }
              },
              child: const Text(
                'GET OTP',
                style: TextStyle(fontSize: 20.0),
              ),
            ),
          ),
        ],
      ),
    );
  }

  _token() async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString("token");
    return value;
  }
}

class OtpCode {
  OtpCode({
    required this.otp,
  });

  late String otp;

  OtpCode.fromJson(Map<String, dynamic> json) {
    otp = json['otp'];
  }
}
