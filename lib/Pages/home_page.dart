import 'package:app/Data/database.dart';
import 'package:app/Utils/dialog_box1.dart';
import 'package:flutter/material.dart';
import 'package:app/Utils/todo_tile.dart';
import 'package:hive_flutter/hive_flutter.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Text Controller
  final _controller = TextEditingController();

  final _mybox = Hive.box('mybox');

  ToDoDataBase db = ToDoDataBase();

  @override
  void initState() {
    super.initState();

    if (_mybox.get("TODOLIST") == null) {
      db.createInitialData(); // Initializes an empty list instead of adding a task
    } else {
      db.loadData(); // Loads tasks from the database
    }
  }
  // Checkbox toggle function (Immutable update)
  void checkBoxChanged(bool? value, int index) {
    setState(() {
      db.toDoList = List.from(db.toDoList); // Clone the list to trigger UI updates
      db.toDoList[index] = [db.toDoList[index][0], value ?? false]; // Immutable update
    });
    db.updateDataBase();
  }

  // Save new task
  void saveNewTask() {
    setState(() {
      db.toDoList.add([_controller.text, false]);
      _controller.clear();
    });
    Navigator.of(context).pop();
    db.updateDataBase();
  }

  // Create new task dialog
  void createNewTask() {
    showDialog(
      context: context,
      builder: (context) {
        return DialogBox(
          controller: _controller,
          onSaved: saveNewTask,
          onCancel: () => Navigator.of(context).pop(),
        );
      },
    );
  }

  //delete task
  void deleteTask(int index) {
    setState(() {
      db.toDoList.removeAt(index);
    });
    db.updateDataBase();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue,
      drawer: Drawer(
      ),
      appBar: AppBar(
        toolbarHeight: 70,
        centerTitle: true,
        title: Transform.translate(
          offset: Offset(-2, 0),  // Adjust manually (-20 works in most cases)
          child: Text(
            'ToDo List',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)
          ),
        ),
        // title: const Center(
        //   child: Text(
        //     "TO DO",
        //     style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        //   ),
        // ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: createNewTask,
        child: const Icon(Icons.add),
      ),
      body: ListView.builder(
        itemCount: db.toDoList.length,
        itemBuilder: (context, index) {
          return ToDoTile(
            taskName: db.toDoList[index][0],
            taskCompleted:db.toDoList[index][1],
            onChanged: (value) => checkBoxChanged(value, index),
            deleteFunction: (context) => deleteTask(index),
          );
        },
      ),
    );
  }
}
