import 'dart:async';

import 'utilities/util.dart';
import 'utilities/server_util.dart';
import 'package:flutter/material.dart';

class RoomDetails extends StatefulWidget {
  const RoomDetails({super.key, required this.roomId});
  final String roomId;
  @override
  State<RoomDetails> createState() => _RoomDetailsState();
}

class _RoomDetailsState extends State<RoomDetails> {
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
    return pic;
  }

  var isRenting = false;
  Map roomRentDetails = {};
  Map roomData = {};
  StreamSubscription? rentStream;
  getRentData() {
    rentStream = dbref.child('rooms/${widget.roomId}/').onValue.listen((event) {
      if (event.snapshot.value != null) {
        var result = (event.snapshot.value as Map).cast<String, dynamic>();
        setState(() {
          roomData = result;
        });
        if (roomData['reservations'] != null) {
          roomRentDetails = Map.fromEntries(roomData['reservations']
              .entries
              .where((element) =>
                  element.value['userId'] == userRef.currentUser!.uid &&
                  element.value['state'] == 'renting'));
          setState(() {
            isRenting = roomRentDetails.isNotEmpty;
          });
        }
      }
    });
  }

  @override
  void initState() {
    super.initState();
    getRentData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Room Details')),
      body: roomData.isEmpty
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
                    child: Text(roomData['title'],
                        style: const TextStyle(
                            fontSize: 30, fontWeight: FontWeight.w700)),
                  ),
                  Row(
                    children: [
                      const Padding(
                          padding: EdgeInsets.all(5),
                          child: Icon(
                            size: 30,
                            Icons.person_4,
                          )),
                      Text(roomData['ownerName'],
                          style: const TextStyle(fontSize: 20))
                    ],
                  ),
                  SizedBox(
                    width: double.infinity,
                    height: 200,
                    child: Card(
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: roomData['images'].length,
                        itemBuilder: (context, index) {
                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: FutureBuilder(
                                builder: (context, snapshot) =>
                                    asyncBuilder(context, snapshot),
                                future: getImage(
                                    widget.roomId, roomData['images'][index])),
                          );
                        },
                      ),
                    ),
                  ),
                  const Text('Description',
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.w500)),
                  Container(
                    padding: const EdgeInsets.all(10),
                    width: double.infinity,
                    decoration: BoxDecoration(
                        border: Border.all(style: BorderStyle.solid)),
                    child: Text(roomData['description'], maxLines: null),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 5),
                    child: Text(
                      'More Details',
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).primaryColor),
                    ),
                  ),
                  Text.rich(TextSpan(children: [
                    const TextSpan(
                        text: 'Location: ',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.w500)),
                    TextSpan(
                        text: "${roomData['location']}",
                        style: TextStyle(
                          fontSize: 20,
                        )),
                  ])),
                  Text.rich(TextSpan(children: [
                    const TextSpan(
                        text: 'Rent: ',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.w500)),
                    TextSpan(
                        text: roomData['rent'],
                        style: TextStyle(
                          fontSize: 20,
                        ))
                  ])),
                  Text.rich(TextSpan(children: [
                    const TextSpan(
                        text: 'No. of Rooms: ',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.w500)),
                    TextSpan(
                        text: "${roomData['noOfRooms']}",
                        style: TextStyle(
                          fontSize: 20,
                        )),
                  ])),
                  Text.rich(TextSpan(children: [
                    const TextSpan(
                        text: 'No. of Occupied Rooms: ',
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.w500)),
                    TextSpan(
                        text: "${roomData['occupiedRooms']}",
                        style: const TextStyle(
                          fontSize: 20,
                        ))
                  ])),
                  Text.rich(TextSpan(children: [
                    const TextSpan(
                        text: "Owner's Contact :",
                        style: TextStyle(
                            fontSize: 20, fontWeight: FontWeight.w500)),
                    TextSpan(
                        text: roomData['ownerContact'],
                        style: const TextStyle(
                          fontSize: 20,
                        ))
                  ]))
                ],
              ),
            ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.white,
        child: Center(
          child: FilledButton(
              onPressed: () async {
                if (roomData['reservations'] != null && isRenting) {
                  await dbref
                      .child(
                          'rooms/${widget.roomId}/reservations/${roomRentDetails.keys.first}/')
                      .update({'state': 'cancelled'});
                  await dbref
                      .child('rooms/${widget.roomId}/')
                      .update({'occupiedRooms': --roomData['occupiedRooms']});
                } else {
                  await dbref
                      .child('rooms/${widget.roomId}/reservations/')
                      .push()
                      .set({
                    'userId': userRef.currentUser!.uid,
                    'state': 'renting'
                  });
                  await dbref
                      .child('rooms/${widget.roomId}/')
                      .update({'occupiedRooms': ++roomData['occupiedRooms']});
                }
              },
              child: roomData['reservations'] != null && isRenting
                  ? const Text('Cancel')
                  : const Text('Rent the Room')),
        ),
      ),
    );
  }

  @override
  void deactivate() {
    super.deactivate();
    rentStream!.cancel();
  }
}
