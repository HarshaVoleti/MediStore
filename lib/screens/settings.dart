import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:medistore/Models/colors.dart';
import 'package:medistore/screens/phone.dart';

class SetttingScreen extends StatefulWidget {
  const SetttingScreen({super.key});

  @override
  State<SetttingScreen> createState() => _SetttingScreenState();
}

class _SetttingScreenState extends State<SetttingScreen> {
  final storeId = FirebaseAuth.instance.currentUser!.uid;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Settings'),
      ),
      body: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            const SizedBox(
              height: 40,
            ),
            StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('stores')
                    .doc(storeId)
                    .snapshots(),
                builder: (context, snapshots) {
                  if (!snapshots.hasData) {
                    return const Text('Loading...');
                  }
                  final data = snapshots.data!.data() as Map<String, dynamic>;
                  return Container(
                    width: double.infinity,
                    padding: EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.inversePrimary,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Store Name: ${data['name']}',
                          style: const TextStyle(
                            fontSize: 20,
                          ),
                        ),
                        Text(
                          'Store Address: ${data['address']}',
                          style: const TextStyle(
                            fontSize: 20,
                          ),
                        ),
                        Text(
                          'Store Phone: ${data['number']}',
                          style: const TextStyle(
                            fontSize: 20,
                          ),
                        ),
                        Text(
                          'Store Email: ${data['emailId']}',
                          style: const TextStyle(
                            fontSize: 20,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
            InkWell(
              onTap: () {
                showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: const Text('Log out'),
                        content: Text(
                          'Are you sure you want to logout from the app?',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () {
                              FirebaseAuth.instance.signOut();
                              Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => PhoneAuth(),
                                  ),
                                  (route) => false);
                            },
                            child: const Text('Cancel'),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Text('Update'),
                          ),
                        ],
                      );
                    });
              },
              child: Container(
                margin: EdgeInsets.only(top: 10, left: 10, right: 10),
                width: double.infinity,
                height: 50,
                decoration: BoxDecoration(
                  color: buttonbg,
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: const Text(
                  'Logout',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 25,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
