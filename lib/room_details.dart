import 'utilities/util.dart';
import 'utilities/server_util.dart';
import 'package:flutter/material.dart';

class RoomDetails extends StatefulWidget {
  const RoomDetails({super.key, required this.roomData, required this.roomId});
  final Map roomData;
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Room Details')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 10),
              child: Text(widget.roomData['title'],
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
                Text(widget.roomData['ownerName'],
                    style: const TextStyle(fontSize: 20))
              ],
            ),
            SizedBox(
              width: double.infinity,
              height: 200,
              child: Card(
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: widget.roomData['images'].length,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: FutureBuilder(
                          builder: (context, snapshot) =>
                              asyncBuilder(context, snapshot),
                          future: getImage(
                              widget.roomId, widget.roomData['images'][index])),
                    );
                  },
                ),
              ),
            ),
            const Text('Description',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500)),
            Container(
              padding: const EdgeInsets.all(10),
              width: double.infinity,
              decoration:
                  BoxDecoration(border: Border.all(style: BorderStyle.solid)),
              child: Text(widget.roomData['description'], maxLines: null),
            ),
            SizedBox(
              height: 20,
            ),
            Text.rich(TextSpan(children: [
              const TextSpan(
                  text: 'Rent: ',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500)),
              TextSpan(
                  text: widget.roomData['rent'],
                  style: TextStyle(
                    fontSize: 20,
                  ))
            ])),
            Text.rich(TextSpan(children: [
              const TextSpan(
                  text: "Owner's Contact :",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500)),
              TextSpan(
                  text: widget.roomData['ownerContact'],
                  style: TextStyle(
                    fontSize: 20,
                  ))
            ]))
          ],
        ),
      ),
    );
  }
}
