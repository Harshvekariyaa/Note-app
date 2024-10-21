import 'package:flutter/material.dart';
import 'package:testing/db/dbhelper.dart';

class SqliteDb extends StatefulWidget {
  const SqliteDb({super.key});

  @override
  State<SqliteDb> createState() => _SqliteDbState();
}

class _SqliteDbState extends State<SqliteDb> {
  List<Map<String, dynamic>> listdata = [];
  Dbhelper? dbref;
  var titleCon = TextEditingController();
  var subtitleCon = TextEditingController();

  @override
  void initState() {
    super.initState();
    dbref = Dbhelper.instance;
    getNotes();
  }

  void getNotes() async {
    listdata = await dbref!.getNotes();
    setState(() {});
  }

  // Function to delete a note by ID
  void deleteNoteById(int id) async {
    await dbref!.deleteNoteById(id);
    getNotes();
  }

  // Function to update a note by ID
  void updateNoteById(int id) async {
    if (titleCon.text.isNotEmpty && subtitleCon.text.isNotEmpty) {
      await dbref!.updateNoteById(
        id,
        newTitle: titleCon.text,
        newSubtitle: subtitleCon.text,
      );
      getNotes(); // Close the modal after update
    }
  }

  // Function to open the modal for adding or updating a note
  void openNoteModal({int? noteId, String? title, String? subtitle}) {
    titleCon.text = title ?? ''; // If editing, populate the fields
    subtitleCon.text = subtitle ?? '';

    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // This ensures the bottom sheet takes into account the keyboard
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom, // Adjust for keyboard
          ),
          child: SingleChildScrollView(
            child: Container(
              padding: const EdgeInsets.all(16.0), // Add some padding
              child: Column(
                mainAxisSize: MainAxisSize.min, // Adjust the height dynamically
                children: [
                  SizedBox(height: 13),
                  Center(
                    child: Text(
                      noteId == null ? "Add Note" : "Update Note", // Change the title based on action
                      style: TextStyle(fontSize: 25),
                    ),
                  ),
                  SizedBox(height: 30),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    child: TextField(
                      controller: titleCon,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        hintText: "Enter title",
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    child: TextField(
                      controller: subtitleCon,
                      maxLines: 5,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        hintText: "Enter Body",
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    child: Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () async {
                              if (noteId == null) {
                                // Adding a new note
                                if (dbref != null) {
                                  bool check = await dbref!.addNote(
                                    mtitle: titleCon.text,
                                    mSubtitle: subtitleCon.text,
                                  );
                                  if (check) {
                                    getNotes();
                                  }
                                }
                              } else {
                                // Updating an existing note
                                updateNoteById(noteId);
                              }
                              Navigator.pop(context);
                            },
                            child: const Text("Save Note"),
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor: Colors.blue, // Text color
                              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12), // Padding
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30), // Rounded corners
                              ),
                              elevation: 5, // Elevation effect
                            ),
                          ),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: Text("Cancel"),
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.blueAccent,
                              backgroundColor: Colors.white, // Text color
                              padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12), // Padding
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30), // Rounded corners
                              ),
                              elevation: 5, // Elevation effect
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black54,
        title: Text(
          "Notes",
          style: TextStyle(fontSize: 20, color: Colors.white),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.only(top: 10),
        child: listdata.isNotEmpty
            ? ListView.builder(
          itemCount: listdata.length,
          itemBuilder: (_, index) {
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.white,
                    child: Center(
                      child: Text(
                        (index + 1).toString(),
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                  ),
                  title: Text(
                    listdata[index][Dbhelper.COLUMN_TITLE],
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                  subtitle: Text(
                    listdata[index][Dbhelper.COLUMN_SUBTITLE],
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white38),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        onPressed: () {
                          openNoteModal(
                            noteId: listdata[index][Dbhelper.COLUMN_ID],
                            title: listdata[index][Dbhelper.COLUMN_TITLE],
                            subtitle: listdata[index][Dbhelper.COLUMN_SUBTITLE],
                          );
                        },
                        icon: Icon(
                          Icons.edit,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          deleteNoteById(listdata[index][Dbhelper.COLUMN_ID]);
                        },
                        icon: Icon(
                          Icons.delete,
                          color: Colors.red,
                          size: 20,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        )
            : Center(
          child: Text("Data Not Available"),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.black,
        onPressed: () {
          openNoteModal(); // Open modal for adding a new note
        },
        child: Icon(Icons.add,color: Colors.white,),
      ),
    );
  }
}
