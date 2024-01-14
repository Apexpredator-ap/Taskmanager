import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive/hive.dart';

class HomePage extends StatefulWidget {
  final String name;
  final String username;

  HomePage({required this.name, required this.username});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Map<String, dynamic>> task = [];
  final my_box = Hive.box('todo_box');

  void initState() {
    readTask_refreshUi();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        toolbarHeight: 70,
        title: Text("MY TASK"),
        centerTitle: true,
        flexibleSpace: Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(30),
                  bottomRight: Radius.circular(30)),
              gradient: LinearGradient(
                  colors: [Colors.deepPurpleAccent, Colors.pink],
                  begin: Alignment.bottomCenter,
                  end: Alignment.topCenter)),
        ),
        systemOverlayStyle: SystemUiOverlayStyle.light,
      ),
      body: task.isEmpty
          ? Center(
              child: Container(
                child: Image.network(
                  "https://cdn.pixabay.com/photo/2021/09/20/22/15/add-6641966_1280.png",
                  height: 300,
                ),
              ),
            )
          : GridView.builder(
              itemCount: task.length,
              gridDelegate:
                  SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
              itemBuilder: (context, index) {
                return Card(
                  color: Colors.primaries[index % Colors.primaries.length],
                  elevation: 5,
                  margin: EdgeInsets.all(16),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                      side: BorderSide(color: Colors.white)),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(
                          task[index]['taskname'],
                          style: GoogleFonts.aBeeZee(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.yellow),
                        ),
                      ),
                      SizedBox(
                        height: 10,
                      ),
                      Text(task[index]['taskdesc'],
                          style: GoogleFonts.montserrat(
                              fontSize: 20, color: Colors.white)),
                      Expanded(
                          child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                              onPressed: () => showAlertbox(task[index]['id']),
                              child: Icon(
                                Icons.edit,
                                color: Colors.white,
                              )),
                          SizedBox(width: 30),
                          ElevatedButton(
                              onPressed: () => deletetask(task[index]['id']),
                              child: Icon(
                                Icons.delete,
                                color: Colors.red,
                              )),
                        ],
                      )),
                    ],
                  ),
                );
              }),
      floatingActionButton: FloatingActionButton(
        onPressed: () => showAlertbox(null),
        child: Icon(Icons.add),
        backgroundColor: Colors.yellow[600],
      ),
      drawer: Drawer(
        child: Container(
          decoration: BoxDecoration(color: Colors.black87),
          child: ListView(
            children: [
              ListTile(
                title: Text(
                  'Name: ${widget.name}',
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  'Username: ${widget.username}',
                  style: TextStyle(color: Colors.white, fontSize: 10),
                ),
              ),
              SizedBox(
                height: 30,
              ),
              Divider(),
              ListTile(
                leading: Icon(
                  Icons.settings,
                  color: Colors.white,
                ),
                title: Text(
                  'Settings',
                  style: TextStyle(color: Colors.white),
                ),
                trailing: Icon(
                  Icons.arrow_forward_ios_outlined,
                  color: Colors.white,
                  size: 10,
                ),
              ),
              ListTile(
                leading: Icon(
                  Icons.dangerous_rounded,
                  color: Colors.white,
                ),
                title: Text(
                  'Exit',
                  style: TextStyle(color: Colors.white),
                ),
                trailing: Icon(
                  Icons.arrow_forward_ios_outlined,
                  color: Colors.white,
                  size: 10,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  final title_cntrl = TextEditingController();
  final descr_cntrl = TextEditingController();

  void showAlertbox(int? key) {
    //key -> task[index]['id']

    if (key != null) {
      final existimg_task = task.firstWhere((element) => element['id'] == key);
      title_cntrl.text = existimg_task['taskname'];
      descr_cntrl.text = existimg_task['taskdesc'];
    }
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            backgroundColor: Colors.black87,
            content: Card(
              color: Colors.black87,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    decoration: InputDecoration(
                        fillColor: Colors.grey,
                        filled: true,
                        border: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.white)),
                        hintText: "Title",
                        hintStyle: TextStyle(color: Colors.white),
                        labelText: 'Title',
                        labelStyle: TextStyle(color: Colors.white),
                        focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.yellow))),
                    controller: title_cntrl,
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  TextField(
                    decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.grey,
                        border: OutlineInputBorder(),
                        hintText: "Content",
                        hintStyle: TextStyle(color: Colors.white),
                        labelText: 'Content',
                        labelStyle: TextStyle(color: Colors.white),
                        focusedBorder: OutlineInputBorder(
                            borderSide: BorderSide(color: Colors.yellow))),
                    controller: descr_cntrl,
                    maxLines: 5,
                  )
                ],
              ),
            ),
            actions: [
              TextButton(
                  onPressed: () {
                    if (title_cntrl.text != "" && descr_cntrl.text != "") {
                      createTask({
                        'tname': title_cntrl.text.trim(),
                        'tcontent': descr_cntrl.text.trim()
                      });
                    }
                    title_cntrl.text = "";
                    descr_cntrl.text = "";
                    Navigator.pop(context);
                  },
                  child: Text(
                    'Create Task',
                    style: TextStyle(color: Colors.yellow[700]),
                  )),
              TextButton(
                  onPressed: () {
                    updatetask(key, {
                      'tname': title_cntrl.text.trim(),
                      'tcontent': descr_cntrl.text.trim()
                    });
                  },
                  child: Text(
                    'Update Task',
                    style: TextStyle(color: Colors.yellow[700]),
                  )),
              TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text(
                    'Cancel',
                    style: TextStyle(color: Colors.yellow[700]),
                  )),
            ],
          );
        });
  }

  Future<void> createTask(Map<String, dynamic> mytask) async {
    await my_box.add(mytask);
    readTask_refreshUi();
    Get.snackbar(
        snackPosition: SnackPosition.BOTTOM,
        "Succesfully created",
        '',
        colorText: Colors.amber);
    title_cntrl.clear();
    descr_cntrl.clear();
  }

  void readTask_refreshUi() {
    final task_from_hive = my_box.keys.map((key) {
      final value = my_box.get(key);
      return {
        'id': key,
        'taskname': value['tname'],
        'taskdesc': value['tcontent']
      };
    }).toList();

    setState(() {
      task = task_from_hive.reversed.toList();
    });
  }

  Future<void> updatetask(int? key, Map<String, dynamic> updatedtask) async {
    await my_box.put(key, updatedtask);
    readTask_refreshUi();
    Navigator.pop(context);
    Get.snackbar(
        snackPosition: SnackPosition.BOTTOM,
        "Succesfully Edited",
        '',
        colorText: Colors.blue);
  }

  Future<void> deletetask(int key) async {
    await my_box.delete(key);
    readTask_refreshUi();
    Get.snackbar(
        snackPosition: SnackPosition.BOTTOM,
        "Succesfully Deleted",
        '',
        colorText: Colors.blue);
  }
}
