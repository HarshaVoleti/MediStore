import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:medistore/screens/addcustomer.dart';

class CustomerDetails extends StatefulWidget {
  const CustomerDetails({super.key, required this.custId});
  final String custId;

  @override
  State<CustomerDetails> createState() => _CustomerDetailsState();
}

class _CustomerDetailsState extends State<CustomerDetails> {
  void addMedicine(Map<String, dynamic> medicine) {
    FirebaseFirestore.instance
        .collection('stores')
        .doc(FirebaseAuth.instance.currentUser!.uid)
        .collection('customers')
        .doc(widget.custId)
        .collection('medicines')
        .add(medicine);
  }

  @override
  Widget build(BuildContext context) {
    final storeId = FirebaseAuth.instance.currentUser!.uid;
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Customer Details'),
      ),
      body: Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            StreamBuilder(
                stream: FirebaseFirestore.instance
                    .collection('stores')
                    .doc(storeId)
                    .collection('customers')
                    .doc(widget.custId)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  final customer =
                      snapshot.data!.data() as Map<String, dynamic>;
                  final image = customer['image'] ?? '';
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Container(
                        width: double.infinity,
                        alignment: Alignment.center,
                        child: CircleAvatar(
                          radius: 50,
                          backgroundImage: image.isEmpty
                              ? null
                              : NetworkImage(image) as ImageProvider,
                        ),
                      ),
                      SizedBox(
                        height: 20,
                      ),
                      Text(
                        'Name: ${customer!['name']}',
                        style: TextStyle(
                          fontSize: 20,
                        ),
                      ),
                      Text(
                        'Phone: ${customer['number']}',
                        style: TextStyle(
                          fontSize: 20,
                        ),
                      ),
                      Text(
                        'Address: ${customer['address']}',
                        style: TextStyle(
                          fontSize: 20,
                        ),
                      ),
                      Row(
                        children: [
                          const Text(
                            "Medicines",
                            style: TextStyle(
                              fontFamily: 'Helvetica Neue',
                              fontSize: 30,
                              color: Colors.black,
                              fontWeight: FontWeight.w300,
                            ),
                          ),
                          const Spacer(),
                          IconButton(
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (context) {
                                  return MedicineDialog(
                                    addMedicineCallback: addMedicine,
                                  );
                                },
                              );
                            },
                            icon: const Icon(Icons.add),
                          ),
                        ],
                      ),
                      StreamBuilder(
                          stream: FirebaseFirestore.instance
                              .collection('stores')
                              .doc(storeId)
                              .collection('customers')
                              .doc(widget.custId)
                              .collection('medicines')
                              .snapshots(),
                          builder:
                              (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const Center(
                                child: CircularProgressIndicator(),
                              );
                            }
                            if (snapshot.hasError) {
                              return Center(
                                child: Text(
                                    'Something went wrong ${snapshot.error}'),
                              );
                            }
                            if (snapshot.data!.docs.isEmpty) {
                              return const Center(
                                child: Text('No medicies found'),
                              );
                            }
                            return Container(
                              height: 200,
                              width: size.width,
                              child: ListView.builder(
                                shrinkWrap: true,
                                scrollDirection: Axis.horizontal,
                                itemCount: snapshot.data!.docs.length,
                                itemBuilder: (context, index) {
                                  final data = snapshot.data!.docs[index].data()
                                      as Map<String, dynamic>;
                                  final id = snapshot.data!.docs[index].id;
                                  final name = data['name'];
                                  final price = data['price'];
                                  final quantity = data['quantity'];
                                  Timestamp mfdstamp = data['mfd'];
                                  Timestamp expstamp = data['exp'];
                                  DateTime mfd = mfdstamp.toDate();
                                  DateTime exp = expstamp.toDate();
                                  return Container(
                                    margin: EdgeInsets.only(right: 10),
                                    // width: 150,
                                    decoration: BoxDecoration(
                                      color: Colors.grey[300],
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Container(
                                      padding: EdgeInsets.all(10),
                                      child: Wrap(
                                        direction: Axis.vertical,
                                        // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                        children: [
                                          Text(
                                            data['name'] ?? 'Medicine',
                                            textAlign: TextAlign.justify,
                                            style: const TextStyle(
                                              // color: Colors.white,
                                              fontSize: 16,
                                            ),
                                          ),
                                          Text(
                                            'Quantity: ${data['quantity']}',
                                            textAlign: TextAlign.justify,
                                            style: const TextStyle(
                                              // color: Colors.white,
                                              fontSize: 16,
                                            ),
                                          ),
                                          Text(
                                            'Price: ${data['price']}',
                                            style: const TextStyle(
                                              // color: Colors.white,
                                              fontSize: 16,
                                            ),
                                          ),
                                          Text(
                                            'Discount: ${data['discount']}%',
                                            style: const TextStyle(
                                              // color: Colors.white,
                                              fontSize: 16,
                                            ),
                                          ),
                                          Text(
                                            'Total Price: ${data['totalPrice']}',
                                            style: const TextStyle(
                                              // color: Colors.white,
                                              fontSize: 16,
                                            ),
                                          ),
                                          Text(
                                            '${mfd.month}/${mfd.year.toString().substring(2, 4)} - ${exp.month}/${exp.year.toString().substring(2, 4)}',
                                            style: const TextStyle(
                                              // color: Colors.white,
                                              fontSize: 16,
                                            ),
                                          ),
                                          Divider(),
                                          Container(
                                            width: size.width * 0.35,
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.spaceEvenly,
                                              children: [
                                                InkWell(
                                                  onTap: () {
                                                    showDialog(
                                                      context: context,
                                                      builder: (context) {
                                                        return MedicineUpdate(
                                                          storeId: storeId,
                                                          custId: widget.custId,
                                                          medId: id,
                                                        );
                                                      },
                                                    );
                                                  },
                                                  child: Icon(
                                                    Icons.edit,
                                                  ),
                                                ),
                                                InkWell(
                                                  onTap: () {
                                                    showDialog(
                                                        context: context,
                                                        builder: (context) {
                                                          return AlertDialog(
                                                            title: const Text(
                                                                'Delete Medicine'),
                                                            content: const Text(
                                                                'Are you sure you want to delete this medicine?'),
                                                            actions: <Widget>[
                                                              TextButton(
                                                                onPressed: () {
                                                                  Navigator.pop(
                                                                      context);
                                                                },
                                                                child:
                                                                    const Text(
                                                                  'Cancel',
                                                                  style:
                                                                      TextStyle(
                                                                    color: Colors
                                                                        .red,
                                                                  ),
                                                                ),
                                                              ),
                                                              TextButton(
                                                                onPressed: () {
                                                                  Navigator.pop(
                                                                      context);
                                                                  FirebaseFirestore
                                                                      .instance
                                                                      .collection(
                                                                          'stores')
                                                                      .doc(
                                                                          storeId)
                                                                      .collection(
                                                                          'customers')
                                                                      .doc(widget
                                                                          .custId)
                                                                      .collection(
                                                                          'medicines')
                                                                      .doc(id)
                                                                      .delete();
                                                                },
                                                                child:
                                                                    const Text(
                                                                  'Delete',
                                                                  style:
                                                                      TextStyle(
                                                                    color: Colors
                                                                        .red,
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          );
                                                        });
                                                  },
                                                  child: Icon(
                                                    Icons.delete,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            );
                          }),
                    ],
                  );
                }),
          ],
        ),
      ),
    );
  }
}

class MedicineUpdate extends StatefulWidget {
  MedicineUpdate(
      {super.key,
      required this.storeId,
      required this.custId,
      required this.medId});
  String storeId;
  String custId;
  String medId;

  @override
  State<MedicineUpdate> createState() => _MedicineUpdateState();
}

class _MedicineUpdateState extends State<MedicineUpdate> {
  TextEditingController nameController = TextEditingController();
  TextEditingController quantityController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  TextEditingController discountController = TextEditingController();

  DateTime mfd = DateTime.now();
  DateTime exp = DateTime.now();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchData();
  }

  void fetchData() async {
    await FirebaseFirestore.instance
        .collection("stores")
        .doc(widget.storeId)
        .collection("customers")
        .doc(widget.custId)
        .collection("medicines")
        .doc(widget.medId)
        .get()
        .then((value) {
      setState(() {
        nameController.text = value.data()!['name'];
        quantityController.text = value.data()!['quantity'].toString();
        priceController.text = value.data()!['price'].toString();
        discountController.text = value.data()!['discount'].toString();
        mfd = value.data()!['mfd'].toDate();
        exp = value.data()!['exp'].toDate();
      });
    });
  }

  @override
  void dispose() {
    nameController.dispose();
    quantityController.dispose();
    priceController.dispose();
    discountController.dispose();
    super.dispose();
  }

  void addMedicine() {
    final medDoc = FirebaseFirestore.instance
        .collection("stores")
        .doc(widget.storeId)
        .collection("customers")
        .doc(widget.custId)
        .collection("medicines")
        .doc(widget.medId);
    if (nameController.text.isEmpty ||
        quantityController.text.isEmpty ||
        priceController.text.isEmpty ||
        discountController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all fields'),
        ),
      );
      return;
    }

    double price = double.parse(priceController.text);
    double quantity = double.parse(quantityController.text);
    double itemPrice = price * quantity;
    double discount = double.parse(discountController.text);
    double totalPrice = itemPrice - (itemPrice * discount / 100);
    medDoc.update({
      'name': nameController.text,
      'quantity': int.parse(quantityController.text),
      'price': price,
      'discount': discount,
      'totalPrice': totalPrice,
      'mfd': mfd,
      'exp': exp,
    });

    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Medicine'),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextFormField(
              controller: nameController,
              style: const TextStyle(fontSize: 20),
              decoration: const InputDecoration(hintText: 'Name'),
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: quantityController,
              style: const TextStyle(fontSize: 20),
              decoration: const InputDecoration(hintText: 'Quantity'),
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: priceController,
              style: const TextStyle(fontSize: 20),
              decoration: const InputDecoration(hintText: 'Price'),
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: discountController,
              style: const TextStyle(fontSize: 20),
              decoration: const InputDecoration(hintText: 'Discount (%)'),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  children: [
                    const Text('Mf Date'),
                    const SizedBox(height: 10),
                    InkWell(
                      onTap: () async {
                        DateTime? selectedDate = await showDatePicker(
                          context: context,
                          initialDate: mfd,
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (selectedDate != null) {
                          setState(() {
                            mfd = selectedDate;
                          });
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Text(
                          '${mfd.day}/${mfd.month}/${mfd.year}',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
                Column(
                  children: [
                    const Text('Exp Date'),
                    const SizedBox(height: 10),
                    InkWell(
                      onTap: () async {
                        DateTime? selectedDate = await showDatePicker(
                          initialEntryMode: DatePickerEntryMode.calendar,
                          initialDatePickerMode: DatePickerMode.day,
                          context: context,
                          initialDate: exp,
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (selectedDate != null) {
                          setState(() {
                            exp = selectedDate;
                          });
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Text(
                          '${exp.day}/${exp.month}/${exp.year}',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          onPressed: addMedicine,
          child: const Text('Add Medicine'),
        ),
      ],
    );
  }
}
