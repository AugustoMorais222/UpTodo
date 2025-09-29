import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'category_page.dart';

class SubTask {
  String title;
  bool isDone;
  SubTask({required this.title, this.isDone = false});

  Map<String, dynamic> toJson() => {'title': title, 'isDone': isDone};

  factory SubTask.fromJson(Map<String, dynamic> json) =>
      SubTask(title: json['title'], isDone: json['isDone'] ?? false);
}

class Task {
  String title;
  bool isDone;
  DateTime? dueDate;
  String priority;
  List<SubTask> subTasks;
  Category? category;

  Task({
    required this.title,
    this.isDone = false,
    this.dueDate,
    this.priority = 'Média',
    this.subTasks = const [],
    this.category,
  });

  Map<String, dynamic> toJson() => {
    'title': title,
    'isDone': isDone,
    'dueDate': dueDate?.toIso8601String(),
    'priority': priority,
    'subTasks': subTasks.map((s) => s.toJson()).toList(),
    'category': category == null
        ? null
        : {
            'name': category!.name,
            'color': category!.color.value,
            'icon': category!.icon.codePoint,
          },
  };

  factory Task.fromJson(Map<String, dynamic> json) => Task(
    title: json['title'],
    isDone: json['isDone'] ?? false,
    dueDate: json['dueDate'] != null ? DateTime.parse(json['dueDate']) : null,
    priority: json['priority'] ?? 'Média',
    subTasks:
        (json['subTasks'] as List?)?.map((s) => SubTask.fromJson(s)).toList() ??
        [],
    category: json['category'] == null
        ? null
        : Category(
            name: json['category']['name'],
            color: Color(json['category']['color']),
            icon: IconData(
              json['category']['icon'],
              fontFamily: 'MaterialIcons',
            ),
          ),
  );
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Task> tasks = [];

  final List<Category> categories = [
    Category(name: 'Trabalho', color: Colors.blue, icon: Icons.work),
    Category(name: 'Estudos', color: Colors.green, icon: Icons.school),
    Category(name: 'Casa', color: Colors.orange, icon: Icons.home),
    Category(name: 'Pessoal', color: Colors.purple, icon: Icons.person),
  ];

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = prefs.getString('tasks');
    if (jsonString != null) {
      final List decoded = jsonDecode(jsonString);
      setState(() {
        tasks = decoded.map((t) => Task.fromJson(t)).toList();
      });
    }
  }

  Future<void> _saveTasks() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(tasks.map((t) => t.toJson()).toList());
    await prefs.setString('tasks', jsonString);
  }

  void _addTask(Task task) {
    setState(() => tasks.add(task));
    _saveTasks();
  }

  void _editTask(int index, Task updatedTask) {
    setState(() => tasks[index] = updatedTask);
    _saveTasks();
  }

  void _deleteTask(int index) {
    setState(() => tasks.removeAt(index));
    _saveTasks();
  }

  void _toggleTaskDone(int index) {
    setState(() => tasks[index].isDone = !tasks[index].isDone);
    _saveTasks();
  }

  void _showTaskDialog({Task? task, int? index}) {
    Category? selectedCategory = task?.category;
    final titleController = TextEditingController(text: task?.title ?? '');
    DateTime? selectedDate = task?.dueDate;
    String priority = task?.priority ?? 'Média';
    List<SubTask> subTasks = List.from(task?.subTasks ?? []);

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(
                task == null ? Icons.add_task : Icons.edit,
                color: Colors.blue,
              ),
              const SizedBox(width: 8),
              Text(task == null ? 'Nova Tarefa' : 'Editar Tarefa'),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: titleController,
                  decoration: InputDecoration(
                    labelText: 'Título da tarefa',
                    prefixIcon: const Icon(Icons.title),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<Category>(
                  value: selectedCategory,
                  decoration: InputDecoration(
                    labelText: 'Categoria',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  items: categories
                      .map(
                        (c) => DropdownMenuItem(
                          value: c,
                          child: Row(
                            children: [
                              Icon(c.icon, color: c.color, size: 18),
                              const SizedBox(width: 6),
                              Text(c.name),
                            ],
                          ),
                        ),
                      )
                      .toList(),
                  onChanged: (cat) =>
                      setDialogState(() => selectedCategory = cat),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        selectedDate == null
                            ? 'Sem data'
                            : '${selectedDate?.day}/${selectedDate?.month}/${selectedDate?.year}',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                    TextButton.icon(
                      icon: const Icon(Icons.calendar_today),
                      label: const Text('Selecionar Data'),
                      onPressed: () async {
                        DateTime? picked = await showDatePicker(
                          context: context,
                          initialDate: selectedDate ?? DateTime.now(),
                          firstDate: DateTime.now(),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null) {
                          setDialogState(() => selectedDate = picked);
                        }
                      },
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: priority,
                  decoration: InputDecoration(
                    labelText: 'Prioridade',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  items: ['Baixa', 'Média', 'Alta']
                      .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                      .toList(),
                  onChanged: (val) => setDialogState(() => priority = val!),
                ),
                const SizedBox(height: 16),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Subtarefas:',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      ...subTasks.asMap().entries.map((entry) {
                        int i = entry.key;
                        SubTask sub = entry.value;
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 4),
                          child: ListTile(
                            dense: true,
                            title: Text(sub.title),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () =>
                                  setDialogState(() => subTasks.removeAt(i)),
                            ),
                          ),
                        );
                      }).toList(),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton.icon(
                          icon: const Icon(Icons.add),
                          label: const Text('Adicionar Subtarefa'),
                          onPressed: () {
                            final subController = TextEditingController();
                            showDialog(
                              context: context,
                              builder: (_) => AlertDialog(
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                title: const Text('Nova Subtarefa'),
                                content: TextField(
                                  controller: subController,
                                  decoration: const InputDecoration(
                                    hintText: 'Título da subtarefa',
                                  ),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('Cancelar'),
                                  ),
                                  ElevatedButton(
                                    onPressed: () {
                                      if (subController.text
                                          .trim()
                                          .isNotEmpty) {
                                        setDialogState(
                                          () => subTasks.add(
                                            SubTask(
                                              title: subController.text.trim(),
                                            ),
                                          ),
                                        );
                                      }
                                      Navigator.pop(context);
                                    },
                                    child: const Text('Adicionar'),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              icon: const Icon(Icons.save),
              label: const Text(
                'Salvar',
                style: TextStyle(color: Colors.white),
              ),
              onPressed: () {
                final newTask = Task(
                  title: titleController.text.trim(),
                  dueDate: selectedDate,
                  priority: priority,
                  subTasks: subTasks,
                  category: selectedCategory,
                );
                if (task == null) {
                  _addTask(newTask);
                } else {
                  _editTask(index!, newTask);
                }
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          'Minhas Tarefas',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.category_outlined),
            tooltip: 'Gerenciar Categorias',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CategoryPage()),
              );
            },
          ),
        ],
      ),
      body: tasks.isEmpty
          ? const Center(child: Text('Nenhuma tarefa adicionada.', style: TextStyle(color: Colors.white),))
          : ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: tasks.length,
              itemBuilder: (_, index) {
                final task = tasks[index];
                return Card(
                  color: task.isDone ? Colors.green[50] : Colors.white,
                  child: ListTile(
                    leading: Checkbox(
                      value: task.isDone,
                      onChanged: (_) => _toggleTaskDone(index),
                    ),
                    title: Text(
                      task.title,
                      style: TextStyle(
                        decoration: task.isDone
                            ? TextDecoration.lineThrough
                            : null,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (task.dueDate != null)
                          Text(
                            'Data: ${task.dueDate!.day}/${task.dueDate!.month}/${task.dueDate!.year}',
                          ),
                        Text('Prioridade: ${task.priority}'),
                        if (task.subTasks.isNotEmpty)
                          ...task.subTasks
                              .map(
                                (s) => Text(
                                  '- ${s.title} ${s.isDone ? "(Concluído)" : ""}',
                                ),
                              )
                              .toList(),
                        if (task.category != null)
                          Row(
                            children: [
                              Icon(
                                task.category!.icon,
                                color: task.category!.color,
                                size: 16,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                task.category!.name,
                                style: TextStyle(color: task.category!.color),
                              ),
                            ],
                          ),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
                          onPressed: () =>
                              _showTaskDialog(task: task, index: index),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteTask(index),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showTaskDialog(),
        icon: const Icon(Icons.add),
        backgroundColor: Colors.blue,
        label: const Text('Nova Tarefa'),
      ),
    );
  }
}
