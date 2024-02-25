import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'utilities/server_util.dart';

class AddRoom extends StatefulWidget {
  const AddRoom({super.key, required this.userData});
  final Map userData;
  @override
  State<AddRoom> createState() => _AddRoomState();
}

class _AddRoomState extends State<AddRoom> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _roomNoController = TextEditingController();
  final TextEditingController _monthlyRentController = TextEditingController();

  List<File> roomImages = [];
  List<String> roomPaths = [];

  Future<void> _pickImage(ImageSource source) async {
    final pickedImage = await ImagePicker().pickImage(source: source);
    if (pickedImage != null) {
      setState(() {
        roomImages.add(File(pickedImage.path));
        roomPaths.add(pickedImage.path.split('/').last);
      });
    }
  }

  bool error = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Room Form'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(labelText: 'Title'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                maxLines: null, // Allows unlimited lines
                decoration: InputDecoration(
                    labelText: 'Description',
                    border: const OutlineInputBorder()),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a description';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              Visibility(
                  visible: roomImages.isNotEmpty,
                  child: Card(
                      child: Container(
                    height: 200,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: roomImages.length,
                      itemBuilder: (context, index) {
                        return Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Image.file(roomImages[index]),
                        );
                      },
                    ),
                  ))),
              ElevatedButton(
                onPressed: () async {
                  await _pickImage(ImageSource.gallery);
                },
                child: Text('Add Room Image'),
              ),
              Visibility(
                  visible: error,
                  child: const Text(
                    'Add Some Images',
                    style: TextStyle(color: Colors.red),
                  )),
              SizedBox(height: 16),
              TextFormField(
                controller: _locationController,
                decoration: InputDecoration(labelText: 'Location'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a location';
                  }
                  return null;
                },
              ),
              TextFormField(
                keyboardType: TextInputType.number,
                controller: _roomNoController,
                decoration: const InputDecoration(labelText: 'Number of Rooms'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the number of rooms for your apartment';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _monthlyRentController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: 'Monthly Rent'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter the monthly rent';
                  }
                  // Add additional validation if needed (e.g., ensure it's a valid number)
                  return null;
                },
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () async {
                  if (roomImages.isEmpty) {
                    setState(() {
                      error = true;
                    });
                  }
                  if (_formKey.currentState!.validate() &&
                      roomImages.isNotEmpty) {
                    // Form is valid, handle the form submission here
                    // Access the form data using the controllers
                    debugPrint('Title: ${_titleController.text}');
                    debugPrint('Description: ${_descriptionController.text}');
                    debugPrint('Room Images: $roomImages');
                    debugPrint('Room Paths: $roomPaths');
                    debugPrint('Location: ${_locationController.text}');
                    debugPrint('Monthly Rent: ${_monthlyRentController.text}');
                    var room = dbref.child('rooms').push();
                    var key = room.key;
                    await room.set({
                      "title": _titleController.text,
                      'description': _descriptionController.text,
                      'images': roomPaths,
                      'location': _locationController.text,
                      'rent': _monthlyRentController.text,
                      'ownerId': userRef.currentUser!.uid,
                      'noOfRooms': _roomNoController.text,
                      'occupiedRooms': 0,
                      'ownerName': widget.userData['username'],
                      'ownerContact': widget.userData['contact'],
                    });
                    for (var i = 0; i < roomPaths.length; i++) {
                      debugPrint('$i ');
                      await storageRef
                          .child('rooms/$key/${roomPaths[i]}')
                          .putFile(roomImages[i]);
                    }
                    if (context.mounted) {
                      Navigator.pop(context);
                    }
                  }
                },
                child: const Text('Add Room'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
