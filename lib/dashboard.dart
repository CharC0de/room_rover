import 'dart:async';

import 'package:flutter/material.dart';
import 'package:room_rover/user_details.dart';
import 'utilities/server_util.dart';
import 'add_room.dart';
import 'room_details.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  final _contactController = TextEditingController();
  final _searchController = TextEditingController();
  StreamSubscription? userStream;
  StreamSubscription? roomStream;
  Map userData = {};
  Map roomData = {};
  Map searchData = {};
  final _formKey = GlobalKey<FormState>();
  getUserData() {
    userStream = dbref
        .child('users/${userRef.currentUser!.uid}')
        .onValue
        .listen((event) {
      if (event.snapshot.value != null) {
        var result = (event.snapshot.value as Map).cast<String, dynamic>();

        setState(() {
          userData = result;
        });
        debugPrint(userData.toString());
      }
    });
  }

  getRoomData() {
    roomStream =
        dbref.child('rooms').orderByChild('title').onValue.listen((event) {
      if (event.snapshot.value != null) {
        var result = (event.snapshot.value as Map).cast<String, dynamic>();
        setState(() {
          roomData = result;
          searchData = roomData;
        });
        debugPrint(userData.toString());
        debugPrint(searchData.toString());
      }
    });
  }

  Future<Widget> getImage(id, image) async {
    Widget pic = const SizedBox(
      width: 1,
      height: 1,
    );
    try {
      final url = await storageRef.child("rooms/$id/$image").getDownloadURL();
      pic = Image.network(
        url,
        fit: BoxFit.cover,
      );
    } catch (e) {
      debugPrint('Error getting profile picture: $e');
      // Handle error gracefully, maybe show a default avatar
    }
    return Visibility(
        visible: id != null && image != null,
        child: SizedBox(height: 200, width: double.infinity, child: pic));
  }

  Widget asyncBuilder(context, snapshot) {
    if (snapshot.connectionState == ConnectionState.waiting) {
      return const CircularProgressIndicator();
    } else if (snapshot.hasError) {
      return Text('Error: ${snapshot.error}');
    } else {
      return snapshot.data ?? const Text('Image not found');
    }
  }

  @override
  void initState() {
    getUserData();
    getRoomData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: TextField(
            controller: _searchController,
            onChanged: (value) {
              debugPrint(searchData.toString());

              setState(() {
                if (value.isNotEmpty) {
                  searchData = Map.fromEntries(searchData.entries.where(
                      ((element) => element.value['title']
                          .toLowerCase()
                          .contains(_searchController.text.toLowerCase()))));
                } else {
                  searchData = roomData;
                }
              });
            },
            decoration: const InputDecoration(
              prefixIcon: Icon(Icons.search),
              labelText: ' Search Room Name',
            )),
        actions: [
          IconButton(
              onPressed: () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (context) => UserDetailsScreen(
                          userData: userData,
                        )));
              },
              icon: const Icon(Icons.person)),
          IconButton(
              onPressed: () {
                userRef.signOut();
                Navigator.pop(context);
              },
              icon: const Icon(Icons.logout))
        ],
      ),
      body: searchData.isNotEmpty
          ? ListView.builder(
              itemCount: searchData.length,
              itemBuilder: (context, index) {
                var roomId = searchData.keys.elementAt(index);
                var room = searchData[roomId];
                return ListTile(
                    onTap: () => Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) =>
                            RoomDetails(roomData: room, roomId: roomId))),
                    title: Card(
                      clipBehavior: Clip.antiAliasWithSaveLayer,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      elevation: 5,
                      margin: const EdgeInsets.all(10),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          FutureBuilder(
                              future: getImage(roomId, room["images"][0]),
                              builder: ((context, snapshot) =>
                                  asyncBuilder(context, snapshot))),
                          Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 5),
                              child: Text(
                                room['title'],
                                style: const TextStyle(
                                    fontSize: 25, fontWeight: FontWeight.w700),
                              )),
                          Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 5),
                              child: Text(
                                room['location'],
                              )),
                          Row(
                            children: [
                              const Padding(
                                  padding: EdgeInsets.all(5),
                                  child: Icon(Icons.person_4)),
                              Text(room['ownerName'])
                            ],
                          )
                        ],
                      ),
                    ));
              })
          : roomData.isEmpty
              ? const Center(
                  child: Text('Add Some Rooms'),
                )
              : const Center(
                  child: Text('Room Does Not Exist'),
                ),
      floatingActionButton: userData['type'] == 'user'
          ? FloatingActionButton(
              onPressed: () {
                showDialog<String>(
                    context: context,
                    builder: (context) => AlertDialog(
                            title: const Text('Register as Owner'),
                            content: Form(
                                key: _formKey,
                                child: TextFormField(
                                  validator: (value) =>
                                      value == null || value.isEmpty
                                          ? "Enter Contact Number"
                                          : null,
                                  controller: _contactController,
                                  keyboardType: TextInputType.phone,
                                  decoration: const InputDecoration(
                                      labelText: 'Contact Number'),
                                )),
                            actions: [
                              TextButton(
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () async {
                                  if (_formKey.currentState!.validate()) {
                                    try {
                                      await dbref
                                          .child(
                                              'users/${userRef.currentUser!.uid}')
                                          .update({
                                        'type': 'owner',
                                        'contact': _contactController.text
                                      });

                                      if (context.mounted) {
                                        Navigator.of(context).pop();
                                      }
                                    } catch (e) {
                                      debugPrint(e.toString());
                                    }
                                  }
                                },
                                child: const Text('Confirm'),
                              ),
                            ]));
              },
              child: const Icon(Icons.person_4_rounded),
            )
          : userData['type'] == 'owner'
              ? FloatingActionButton(
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => AddRoom(
                              userData: userData,
                            )));
                  },
                  child: const Icon(Icons.add_home),
                )
              : null,
    );
  }

  @override
  void deactivate() {
    userStream!.cancel();
    super.deactivate();
  }
}
