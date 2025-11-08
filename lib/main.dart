import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    title: "Search Doctors for Appointment",
    home: ProductSearchScreen(),
  ));
}

class ProductSearchScreen extends StatefulWidget {
  const ProductSearchScreen({super.key});

  @override
  State<ProductSearchScreen> createState() => _ProductSearchScreenState();
}

class _ProductSearchScreenState extends State<ProductSearchScreen> {
  final TextEditingController _nameController = TextEditingController();
  String _statusMessage = "";
  Map<String, dynamic>? _doctorData;

  Future<void> _searchDoctor() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      setState(() {
        _statusMessage = "Please enter the Doctor name.";
        _doctorData = null;
      });
      return;
    }

    final querySnapshot = await FirebaseFirestore.instance
        .collection('doctors')
        .where('name', isEqualTo: name)
        .get();

    if (querySnapshot.docs.isEmpty) {
      setState(() {
        _statusMessage = "Doctor not found";
        _doctorData = null;
      });
    } else {
      final doctor = querySnapshot.docs.first.data();
      setState(() {
        _statusMessage = "";
        _doctorData = doctor;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Search Doctors for appointment"),
        backgroundColor: Colors.indigo,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: "Enter Doctor name",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _searchDoctor,
              child: const Text("Search"),
            ),
            const SizedBox(height: 20),
            if (_statusMessage.isNotEmpty)
              Text(
                _statusMessage,
                style: const TextStyle(color: Colors.red, fontSize: 16),
              ),
            if (_doctorData != null) ...[
              SizedBox(
                  width: double.infinity,
                  child: Card(
                    margin: const EdgeInsets.only(top: 20),
                    elevation: 3,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Name: ${_doctorData!['name']}",
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                          Text("Age: ${_doctorData!['age']}"),
                          Text("Specialization: ${_doctorData!['specialization']}"),
                          Text("Price: ₹${_doctorData!['price']}"),
                          
                        ],
                      ),
                    ),
                  ),
                )
            ],
          ],
        ),
      ),
    );
  }
}
