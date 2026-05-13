import 'package:flutter/material.dart';

class ActivityScreen extends StatefulWidget {
  @override
  _ActivityScreenState createState() => _ActivityScreenState();
}

class _ActivityScreenState extends State<ActivityScreen> {

  // Track joined status
  List<bool> joined = [false, false, false];

  // Participants count
  List<int> participants = [5, 8, 3];

  // Join function
  void joinActivity(int index) {
    setState(() {
      joined[index] = true;
      participants[index]++; // increase count
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Joined successfully!")),
    );
  }

  @override
  Widget build(BuildContext context) {

    List<String> activities = [
      "Beach Cleanup",
      "Tree Planting",
      "Recycling Campaign"
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text("Activities"),
        backgroundColor: Colors.green,
      ),

      body: Padding(
        padding: EdgeInsets.all(10),
        child: ListView.builder(
          itemCount: activities.length,
          itemBuilder: (context, index) {
            return Card(
              elevation: 4,
              margin: EdgeInsets.symmetric(vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),

              child: ListTile(
                contentPadding: EdgeInsets.all(12),

                // Activity name
                title: Text(
                  activities[index],
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),

                // Participants count
                subtitle: Text(
                  "Participants: ${participants[index]}",
                ),

                // ✅ JOIN BUTTON (THIS IS WHAT YOU WERE LOOKING FOR)
                trailing: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        joined[index] ? Colors.grey : Colors.green,
                    padding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                  ),

                  onPressed:
                      joined[index] ? null : () => joinActivity(index),

                  child: Text(
                    joined[index] ? "Joined ✅" : "Join",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
