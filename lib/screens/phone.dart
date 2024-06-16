import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:medistore/screens/home.dart';

class PhoneAuth extends StatefulWidget {
  const PhoneAuth({super.key});

  @override
  State<PhoneAuth> createState() => _PhoneAuthState();
}

class _PhoneAuthState extends State<PhoneAuth> {
  TextEditingController passwordController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  String email = '';
  String password = '';
  bool visible = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
          title: const Text('Phone Auth'),
        ),
        body: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              const Text(
                'Enter Your Email',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Helvetica Neue',
                  fontSize: 30,
                  // color: text2,
                  fontWeight: FontWeight.w300,
                ),
              ),
              const SizedBox(
                height: 40,
              ),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: emailController,
                      onChanged: (value) {
                        setState(() {
                          email = value;
                        });
                      },
                      autofillHints: const <String>[AutofillHints.oneTimeCode],
                      style: const TextStyle(
                        fontFamily: 'Helvetica Neue',
                        fontSize: 20,
                        color: Colors.black,
                        fontWeight: FontWeight.w300,
                      ),
                      textAlign: TextAlign.start,
                      cursorColor: Colors.grey,
                      cursorHeight: 25,
                      showCursor: true,
                      decoration: InputDecoration(
                        hintText: 'myemail@gmail.com',
                        hintStyle: TextStyle(color: Colors.grey[400]),
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 10),
                        focusedBorder: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(
                              10,
                            ),
                          ),
                        ),
                        border: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(
                              10,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      obscureText: visible,
                      onChanged: (value) {
                        password = value;
                      },
                      style: const TextStyle(
                        fontFamily: 'Helvetica Neue',
                        fontSize: 20,
                        color: Colors.black,
                        fontWeight: FontWeight.w300,
                      ),
                      textAlign: TextAlign.start,
                      cursorColor: Colors.grey,
                      cursorHeight: 25,
                      decoration: InputDecoration(
                        hintText: '********',
                        suffixIcon: IconButton(
                          onPressed: () {
                            // Toggle password visibility
                            setState(() {
                              visible = !visible;
                            });
                          },
                          icon: Icon(
                            visible ? Icons.visibility_off : Icons.visibility,
                          ),
                        ),
                        hintStyle: TextStyle(color: Colors.grey[400]),
                        contentPadding:
                            const EdgeInsets.symmetric(horizontal: 10),
                        focusedBorder: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(
                              10,
                            ),
                          ),
                        ),
                        border: const OutlineInputBorder(
                          borderRadius: BorderRadius.all(
                            Radius.circular(
                              10,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(
                height: 30,
              ),
              InkWell(
                onTap: () {
                  // Verify and login
                  FirebaseAuth.instance
                      .signInWithEmailAndPassword(
                    email: email,
                    password: password,
                  )
                      .then((value) {
                    // Navigate to home screen
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const HomePage(),
                      ),
                      (route) => false,
                    );
                  }).catchError((error) {
                    // Show error message
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(error.toString()),
                      ),
                    );
                  });
                },
                child: Container(
                  width: double.infinity,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.purple,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    'Login',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 25,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ));
  }
}
