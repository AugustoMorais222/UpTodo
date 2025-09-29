import 'package:flutter/material.dart';

import 'category_page.dart';

class SubTask {
  String title;
  bool isDone;
  SubTask({required this.title, this.isDone = false});
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
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Task> tasks = [];

  void _addTask(Task task) {
    setState(() => tasks.add(task));
  }

  void _editTask(int index, Task updatedTask) {
    setState(() => tasks[index] = updatedTask);
  }

  void _deleteTask(int index) {
    setState(() => tasks.removeAt(index));
  }

  void _toggleTaskDone(int index) {
    setState(() => tasks[index].isDone = !tasks[index].isDone);
  }

  void _showTaskDialog({Task? task, int? index}) {
    Category? selectedCategory = task?.category;

    final titleController = TextEditingController(text: task?.title ?? '');
    DateTime? selectedDate = task?.dueDate;
    String priority = task?.priority ?? 'Média';
    List<SubTask> subTasks = task?.subTasks ?? [];

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(task == null ? 'Nova Tarefa' : 'Editar Tarefa'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: titleController,
                  decoration: const InputDecoration(hintText: 'Título da tarefa'),
                ),
                const SizedBox(height: 10),
                DropdownButton<Category>(
                  value: selectedCategory,
                  hint: const Text('Selecione a categoria'),
                  items: categories.map((c) => DropdownMenuItem(
                    value: c,
                    child: Text(c.name),
                  )).toList(),
                  onChanged: (cat) => setDialogState(() => selectedCategory = cat),
                ),
                Row(
                  children: [
                    Text(selectedDate == null
                        ? 'Sem data'
                        : '${selectedDate?.day}/${selectedDate?.month}/${selectedDate?.year}'),
                    const SizedBox(width: 10),
                    TextButton(
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
                      child: const Text('Selecionar Data'),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                DropdownButton<String>(
                  value: priority,
                  items: ['Baixa', 'Média', 'Alta']
                      .map((p) => DropdownMenuItem(value: p, child: Text(p)))
                      .toList(),
                  onChanged: (val) => setDialogState(() => priority = val!),
                ),
                const SizedBox(height: 10),
                Column(
                  children: [
                    const Text('Subtarefas:'),
                    for (int i = 0; i < subTasks.length; i++)
                      ListTile(
                        title: Text(subTasks[i].title),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () =>
                              setDialogState(() => subTasks.removeAt(i)),
                        ),
                      ),
                    TextButton(
                      onPressed: () {
                        final subController = TextEditingController();
                        showDialog(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: const Text('Nova Subtarefa'),
                            content: TextField(
                              controller: subController,
                              decoration:
                                  const InputDecoration(hintText: 'Título da subtarefa'),
                            ),
                            actions: [
                              TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('Cancelar')),
                              ElevatedButton(
                                  onPressed: () {
                                    if (subController.text.trim().isNotEmpty) {
                                      setDialogState(() => subTasks.add(
                                          SubTask(title: subController.text.trim())));
                                    }
                                    Navigator.pop(context);
                                  },
                                  child: const Text('Adicionar')),
                            ],
                          ),
                        );
                      },
                      child: const Text('Adicionar Subtarefa'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
            ElevatedButton(
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
              child: const Text('Salvar'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Minhas Tarefas')),
      body: tasks.isEmpty
          ? const Center(child: Text('Nenhuma tarefa adicionada.'))
          : ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: tasks.length,
              itemBuilder: (_, index) {
                final task = tasks[index];
                return Card(
                  color: task.isDone ? Colors.green[50] : Colors.white,
                  child: ListTile(
                  leading: Checkbox(
                      value: task.isDone, onChanged: (_) => _toggleTaskDone(index)),
                  title: Text(
                    task.title,
                    style: TextStyle(
                        decoration:
                            task.isDone ? TextDecoration.lineThrough : null),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (task.dueDate != null)
                        Text(
                            'Data: ${task.dueDate!.day}/${task.dueDate!.month}/${task.dueDate!.year}'),
                      Text('Prioridade: ${task.priority}'),
                      if (task.subTasks.isNotEmpty)
                        ...task.subTasks
                            .map((s) => Text('- ${s.title} ${s.isDone ? "(Concluído)" : ""}'))
                            .toList(),

                      // <-- Aqui: exibir categoria
                      if (task.category != null)
                        Row(
                          children: [
                            Icon(task.category!.icon,
                                color: task.category!.color, size: 16),
                            const SizedBox(width: 4),
                            Text(task.category!.name,
                                style: TextStyle(color: task.category!.color)),
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
                              _showTaskDialog(task: task, index: index)),
                      IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _deleteTask(index)),
                    ],
                  ),
                ),

                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showTaskDialog(),
        icon: const Icon(Icons.add),
        label: const Text('Nova Tarefa'),
      ),
    );
  }
}
