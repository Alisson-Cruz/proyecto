import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart';

void main() {
  runApp(MyApp());
}

class Task {
  String title;
  bool isDone;
  DateTime? dateTime;
  String description;

  Task(
      {required this.title,
      this.isDone = false,
      this.dateTime,
      this.description = ''});
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: TaskScreen(),
    );
  }
}

class TaskScreen extends StatefulWidget {
  @override
  _TaskScreenState createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> {
  List<Task> tasks = [];
  late SpeechToText _speech;
  bool _isListening = false;

  @override
  void initState() {
    super.initState();
    _speech = SpeechToText();
    _speech.initialize(
        onStatus: (status) {
          if (status == SpeechToText.notifyErrorMethod) {
            print('Error de inicialización');
          }
        },
        onError: (error) => print('Error: $error'));
  }

  void addTask(String newTaskTitle) {
    setState(() {
      tasks.add(Task(title: newTaskTitle));
    });
  }

  void toggleTask(int index) {
    setState(() {
      tasks[index].isDone = !tasks[index].isDone;
    });
  }

  void deleteTask(int index) {
    setState(() {
      tasks.removeAt(index);
    });
  }

  void viewTaskDetails(Task task) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TaskDetailsScreen(task: task),
      ),
    );
  }

  void editTaskDetails(int index, Task editedTask) {
    setState(() {
      tasks[index] = editedTask;
    });
  }

  void startListening() {
    _speech.listen(
      onResult: (result) {
        if (result.finalResult) {
          setState(() {
            addTask(result.recognizedWords);
          });
        }
      },
    );
    setState(() {
      _isListening = true;
    });
  }

  void stopListening() {
    _speech.stop();
    setState(() {
      _isListening = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Tareas'),
        backgroundColor: Colors.green,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          TaskInput(onAddTask: addTask),
          TaskList(
            tasks: tasks,
            onToggle: toggleTask,
            onDelete: deleteTask,
            onViewDetails: viewTaskDetails,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _isListening ? stopListening : startListening,
        tooltip: 'Agregar tarea por voz',
        child: Icon(
          _isListening ? Icons.stop : Icons.mic,
        ),
      ),
    );
  }
}

class TaskList extends StatelessWidget {
  final List<Task> tasks;
  final Function(int) onToggle;
  final Function(int) onDelete;
  final Function(Task) onViewDetails;

  TaskList(
      {required this.tasks,
      required this.onToggle,
      required this.onDelete,
      required this.onViewDetails});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ListView.builder(
        itemCount: tasks.length,
        itemBuilder: (context, index) {
          final task = tasks[index];
          return TaskTile(
            title: task.title,
            isDone: task.isDone,
            onToggle: () {
              onToggle(index);
            },
            onDelete: () {
              onDelete(index);
            },
            onViewDetails: () {
              onViewDetails(task);
            },
          );
        },
      ),
    );
  }
}

class TaskTile extends StatelessWidget {
  final String title;
  final bool isDone;
  final VoidCallback onToggle;
  final VoidCallback onDelete;
  final VoidCallback onViewDetails;

  TaskTile(
      {required this.title,
      required this.isDone,
      required this.onToggle,
      required this.onDelete,
      required this.onViewDetails});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        title,
        style: TextStyle(
          backgroundColor: Colors.lightBlue,
          decoration: isDone ? TextDecoration.lineThrough : null,
        ),
      ),
      onTap: onViewDetails,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: onViewDetails,
          ),
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: onDelete,
          ),
          Checkbox(
            value: isDone,
            onChanged: (newValue) {
              onToggle();
            },
          ),
        ],
      ),
    );
  }
}

class TaskInput extends StatelessWidget {
  final Function(String) onAddTask;

  TaskInput({required this.onAddTask});

  @override
  Widget build(BuildContext context) {
    String newTaskTitle = '';

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: <Widget>[
          Expanded(
            child: TextField(
              onChanged: (value) {
                newTaskTitle = value;
              },
              decoration: const InputDecoration(
                hintText: 'Ingrese una nueva tarea',
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              onAddTask(newTaskTitle);
            },
            child: const Text('Agregar'),
          ),
        ],
      ),
    );
  }
}

class TaskDetailsScreen extends StatefulWidget {
  final Task task;

  TaskDetailsScreen({required this.task});

  @override
  _TaskDetailsScreenState createState() => _TaskDetailsScreenState();
}

class _TaskDetailsScreenState extends State<TaskDetailsScreen> {
  bool _isEditing = false;
  late TextEditingController _dateTimeController;
  late TextEditingController _descriptionController;

  @override
  void initState() {
    super.initState();
    _dateTimeController = TextEditingController(
        text: widget.task.dateTime?.toLocal().toString() ?? '');
    _descriptionController =
        TextEditingController(text: widget.task.description);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Detalles de la Tarea'),
        backgroundColor: Colors.green,
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.check : Icons.edit),
            onPressed: () {
              setState(() {
                _isEditing = !_isEditing;
              });
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tarea: ${widget.task.title}',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            if (_isEditing)
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _dateTimeController,
                      readOnly: true,
                      onTap: () async {
                        DateTime? pickedDateTime = await showDatePicker(
                          context: context,
                          initialDate: widget.task.dateTime ?? DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime(2100),
                        );

                        if (pickedDateTime != null) {
                          TimeOfDay? pickedTime = await showTimePicker(
                            context: context,
                            initialTime: TimeOfDay.now(),
                          );

                          if (pickedTime != null) {
                            pickedDateTime = DateTime(
                              pickedDateTime.year,
                              pickedDateTime.month,
                              pickedDateTime.day,
                              pickedTime.hour,
                              pickedTime.minute,
                            );

                            setState(() {
                              widget.task.dateTime = pickedDateTime;
                              _dateTimeController.text =
                                  pickedDateTime!.toLocal().toString();
                            });
                          }
                        }
                      },
                      decoration: const InputDecoration(
                        hintText: 'Fecha y Hora',
                      ),
                    ),
                  ),
                ],
              )
            else
              Text(
                'Fecha y Hora: ${widget.task.dateTime?.toLocal().toString() ?? 'No seleccionada'}',
              ),
            const SizedBox(height: 10),
            if (_isEditing)
              TextField(
                controller: _descriptionController,
                onChanged: (value) {
                  widget.task.description = value;
                },
                decoration: const InputDecoration(
                  hintText: 'Descripción',
                ),
              )
            else
              Text(
                'Descripción: ${widget.task.description}',
              ),
            const SizedBox(height: 10),
            Text(
              'Estado: ${widget.task.isDone ? 'Completada' : 'Pendiente'}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
