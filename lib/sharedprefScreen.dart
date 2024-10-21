import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Sharedprefscreen extends StatefulWidget {
  const Sharedprefscreen({super.key});

  @override
  State<Sharedprefscreen> createState() => _SharedprefscreenState();
}

class _SharedprefscreenState extends State<Sharedprefscreen> {
  int? id;
  String? name;
  bool? active;

  @override
  void initState() {
    super.initState();
    loaddata(); // Load data when the screen is initialized
  }

  Future<void> savedata() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    await sp.setString("name", "Harsh");
    await sp.setInt("eid", 7);
    await sp.setBool("active", true);
  }

  Future<void> removedata() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    await sp.remove("name");
    await sp.remove("eid");
    await sp.remove("active");
  }

  Future<void> loaddata() async {
    SharedPreferences sp = await SharedPreferences.getInstance();
    setState(() {
      id = sp.getInt("eid");
      name = sp.getString("name");
      active = sp.getBool("active");
    });
    print('Loaded Data -> ID: $id, Name: $name, Active: $active');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Shared Preferences Example')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Id: ${id ?? 'No ID'}"),
            Text("Name: ${name ?? 'No Name'}"),
            Text("Active: ${active != null ? active.toString() : 'No Status'}"),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                await savedata(); // Save data
                await loaddata(); // Reload the data
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Saved data")),
                );
              },
              child: Text('Save Username'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                await removedata(); // Remove data
                await loaddata(); // Reload the data
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text("Removed data")),
                );
              },
              child: Text('Remove data'),
            ),
          ],
        ),
      ),
    );
  }
}
