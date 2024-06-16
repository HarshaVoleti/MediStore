import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:medistore/Models/colors.dart';
import 'package:medistore/screens/addCustomer.dart';
import 'package:medistore/screens/customerDetails.dart';
import 'package:medistore/screens/searchscreen.dart';

class CustomersListScreen extends StatefulWidget {
  const CustomersListScreen({super.key});

  @override
  State<CustomersListScreen> createState() => _CustomersListScreenState();
}

class _CustomersListScreenState extends State<CustomersListScreen> {
  @override
  Widget build(BuildContext context) {
    final storeId = FirebaseAuth.instance.currentUser!.uid;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Customers List'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SearchScreen(),
                ),
              );
            },
            icon: const Icon(
              Icons.search,
            ),
          ),
        ],
      ),
      body: Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddCustomerScreen(),
                  ),
                );
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
                  'Add Customer',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 25,
                  ),
                ),
              ),
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
                      child: Text('Something went wrong ${snapshot.error}'),
                    );
                  }
                  if (snapshot.data!.docs.isEmpty) {
                    return const Center(
                      child: Text('No customers found'),
                    );
                  }
                  return Expanded(
                    child: ListView.builder(
                      itemCount: snapshot.data!.docs.length,
                      itemBuilder: (context, index) {
                        final data = snapshot.data!.docs[index].data()
                            as Map<String, dynamic>;
                        final id = snapshot.data!.docs[index].id;
                        final name = data['name'];
                        final number = data['number'];
                        final pic = data['image'];
                        return ListTile(
                          leading: CircleAvatar(
                            backgroundImage:
                                pic != null ? NetworkImage(pic) : null,
                          ),
                          title: Text(snapshot.data!.docs[index]['name']),
                          subtitle: Text(snapshot.data!.docs[index]['number']),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => CustomerDetails(
                                  custId: id,
                                ),
                              ),
                            );
                          },
                        );
                      },
                    ),
                  );
                })
          ],
        ),
      ),
    );
  }
}
