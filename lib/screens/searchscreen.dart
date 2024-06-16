import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:medistore/screens/customerdetails.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  TextEditingController searchController = TextEditingController();
  String query = '';
  final storeId = FirebaseAuth.instance.currentUser!.uid;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Search'),
      ),
      body: Container(
        padding: EdgeInsets.all(10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: searchController,
                    onChanged: (value) {
                      setState(() {
                        query = value;
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
            StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('stores')
                    .doc(storeId)
                    .collection('customers')
                    .snapshots(),
                builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  if (snapshot.hasError) {
                    return Center(
                      child: Text('Error: ${snapshot.error}'),
                    );
                  }
                  if (snapshot.data!.docs.isEmpty) {
                    return const Center(
                      child: Text('No data found'),
                    );
                  }
                  if (query.isEmpty) {
                    return const Center(
                      child: Text('Enter a name to search'),
                    );
                  }
                  return Expanded(
                    child: ListView(
                      shrinkWrap: true,
                      children: snapshot.data!.docs.map((document) {
                        if (document['name']
                                .toString()
                                .toLowerCase()
                                .contains(query.toLowerCase()) ||
                            document['number'].toString().contains(query)) {
                          final data = document.data() as Map<String, dynamic>;
                          return ListTile(
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => CustomerDetails(
                                    custId: document.id,
                                  ),
                                ),
                              );
                            },
                            leading: CircleAvatar(
                              backgroundImage: data['image'] != null
                                  ? NetworkImage(data['image'])
                                  : null,
                            ),
                            title: Text(data['name']),
                            subtitle: Text(data['number']),
                          );
                        } else {
                          return const SizedBox();
                        }
                      }).toList(),
                    ),
                  );
                }),
          ],
        ),
      ),
    );
  }
}
