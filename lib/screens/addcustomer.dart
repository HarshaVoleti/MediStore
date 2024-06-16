import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:medistore/Models/colors.dart';

class AddCustomerScreen extends StatefulWidget {
  const AddCustomerScreen({super.key});

  @override
  State<AddCustomerScreen> createState() => _AddCustomerScreenState();
}

class _AddCustomerScreenState extends State<AddCustomerScreen> {
  TextEditingController nameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  final storeId = FirebaseAuth.instance.currentUser!.uid;
  bool isImagePicked = false;
  DateTime mfd = DateTime.now();
  DateTime exp = DateTime.now();
  XFile? image;

  List<Map<String, dynamic>> medicines = [];

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    addressController.dispose();
    super.dispose();
  }

  void addMedicine(Map<String, dynamic> medicine) {
    setState(() {
      medicines.add(medicine);
    });
  }

  Future<void> saveCustomer() async {
    if (nameController.text.isEmpty ||
        phoneController.text.isEmpty ||
        addressController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please Fill all fields'),
        ),
      );
      return;
    }

    final task = await FirebaseStorage.instance
        .ref('customers')
        .child(nameController.text)
        .putFile(File(image!.path));
    final imageURL = await task.ref.getDownloadURL();

    CollectionReference customers = FirebaseFirestore.instance
        .collection('stores')
        .doc(storeId)
        .collection('customers');

    DocumentReference customerRef = await customers.add({
      'name': nameController.text,
      'number': phoneController.text,
      'address': addressController.text,
      'image': imageURL,
    });
    customerRef.update({'CustId': customerRef.id});

    CollectionReference medicinesRef = customerRef.collection('medicines');

    for (var medicine in medicines) {
      final docref = await medicinesRef.add(medicine);
      docref.update({'MedId': docref.id});
    }

    nameController.clear();
    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Customer added successfully'),
      ),
    );
  }

  void pickImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? pickedImage =
        await _picker.pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      setState(() {
        image = pickedImage;
        isImagePicked = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: const Text('Add Customer'),
      ),
      body: SingleChildScrollView(
        child: Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              InkWell(
                onTap: pickImage,
                child: CircleAvatar(
                  radius: 50,
                  backgroundImage: isImagePicked
                      ? FileImage(
                          File(image!.path),
                        )
                      : NetworkImage(
                          'https://www.pngitem.com/pimgs/m/146-1468479_my-profile-icon-blank-profile-picture-circle-hd.png',
                        ),
                  backgroundColor: Theme.of(context).colorScheme.inversePrimary,
                  child: isImagePicked
                      ? null
                      : Icon(
                          Icons.person,
                          size: 50,
                          color: Colors.white,
                        ),
                ),
              ),
              const SizedBox(height: 40),
              TextFormField(
                controller: nameController,
                style: const TextStyle(
                  fontFamily: 'Helvetica Neue',
                  fontSize: 20,
                  color: Colors.black,
                  fontWeight: FontWeight.w300,
                ),
                decoration: const InputDecoration(hintText: 'Name'),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: phoneController,
                style: const TextStyle(
                  fontFamily: 'Helvetica Neue',
                  fontSize: 20,
                  color: Colors.black,
                  fontWeight: FontWeight.w300,
                ),
                decoration: const InputDecoration(hintText: 'Phone'),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: addressController,
                style: const TextStyle(
                  fontFamily: 'Helvetica Neue',
                  fontSize: 20,
                  color: Colors.black,
                  fontWeight: FontWeight.w300,
                ),
                decoration: const InputDecoration(hintText: 'Address'),
              ),
              const SizedBox(height: 20),
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
              Container(
                height: 170,
                child: medicines.isEmpty
                    ? Center(
                        child: Text('No medicines added'),
                      )
                    : ListView.builder(
                        scrollDirection: Axis.horizontal,
                        shrinkWrap: true,
                        // gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        //   crossAxisCount: 2,
                        //   mainAxisSpacing: 20,
                        //   crossAxisSpacing: 20,
                        //   childAspectRatio: 3 / 3,
                        // ),
                        itemCount: medicines.length,
                        itemBuilder: (context, index) {
                          if (medicines.isEmpty) {
                            return const Center(
                              child: Text('No medicines added'),
                            );
                          }
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
                                    medicines[index]['name'] ?? 'Medicine',
                                    textAlign: TextAlign.justify,
                                    style: const TextStyle(
                                      // color: Colors.white,
                                      fontSize: 16,
                                    ),
                                  ),
                                  Text(
                                    'Quantity: ${medicines[index]['quantity']}',
                                    textAlign: TextAlign.justify,
                                    style: const TextStyle(
                                      // color: Colors.white,
                                      fontSize: 16,
                                    ),
                                  ),
                                  Text(
                                    'Price: ${medicines[index]['price']}',
                                    style: const TextStyle(
                                      // color: Colors.white,
                                      fontSize: 16,
                                    ),
                                  ),
                                  Text(
                                    'Discount: ${medicines[index]['discount']}%',
                                    style: const TextStyle(
                                      // color: Colors.white,
                                      fontSize: 16,
                                    ),
                                  ),
                                  Text(
                                    'Total Price: ${medicines[index]['totalPrice']}',
                                    style: const TextStyle(
                                      // color: Colors.white,
                                      fontSize: 16,
                                    ),
                                  ),
                                  Text(
                                    '${medicines[index]['mfd'].month}/${medicines[index]['mfd'].year.toString().substring(2, 4)} - ${medicines[index]['exp'].month}/${medicines[index]['exp'].year.toString().substring(2, 4)}',
                                    style: const TextStyle(
                                      // color: Colors.white,
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
              const SizedBox(height: 20),
              InkWell(
                onTap: saveCustomer,
                child: Container(
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
            ],
          ),
        ),
      ),
    );
  }
}

class MedicineDialog extends StatefulWidget {
  final Function(Map<String, dynamic>) addMedicineCallback;

  const MedicineDialog({Key? key, required this.addMedicineCallback})
      : super(key: key);

  @override
  State<MedicineDialog> createState() => _MedicineDialogState();
}

class _MedicineDialogState extends State<MedicineDialog> {
  TextEditingController nameController = TextEditingController();
  TextEditingController quantityController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  TextEditingController discountController = TextEditingController();

  DateTime mfd = DateTime.now();
  DateTime exp = DateTime.now();

  @override
  void dispose() {
    nameController.dispose();
    quantityController.dispose();
    priceController.dispose();
    discountController.dispose();
    super.dispose();
  }

  void addMedicine() {
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

    widget.addMedicineCallback({
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
