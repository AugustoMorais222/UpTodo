import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

class Category {
  final String name;
  final Color color;
  final IconData icon;

  Category({required this.name, required this.color, required this.icon});
}

class CategoryPage extends StatefulWidget {
  const CategoryPage({super.key});

  @override
  State<CategoryPage> createState() => _CategoryPageState();
}

class _CategoryPageState extends State<CategoryPage> {
  List<Category> categories = [];

  void _addCategory(Category cat) {
    setState(() => categories.add(cat));
  }

  void _editCategory(int index, Category cat) {
    setState(() => categories[index] = cat);
  }

  void _deleteCategory(int index) {
    setState(() => categories.removeAt(index));
  }

  void _showCategoryDialog({Category? cat, int? index}) {
    final nameController = TextEditingController(text: cat?.name ?? '');
    Color color = cat?.color ?? Colors.blue;
    IconData icon = cat?.icon ?? Icons.category;

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(cat == null ? 'Nova Categoria' : 'Editar Categoria'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(hintText: 'Nome da categoria'),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Text('Cor:'),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: () async {
                      Color? picked = await showDialog(
                          context: context,
                          builder: (_) => AlertDialog(
                                content: SingleChildScrollView(
                                  child: BlockPicker(
                                    pickerColor: color,
                                    onColorChanged: (c) => color = c,
                                  ),
                                ),
                              ));
                      if (picked != null) setDialogState(() => color = picked);
                    },
                    child: CircleAvatar(backgroundColor: color),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Text('Ícone:'),
                  const SizedBox(width: 10),
                  DropdownButton<IconData>(
                    value: icon,
                    items: const [
                      DropdownMenuItem(value: Icons.category, child: Icon(Icons.category)),
                      DropdownMenuItem(value: Icons.work, child: Icon(Icons.work)),
                      DropdownMenuItem(value: Icons.school, child: Icon(Icons.school)),
                      DropdownMenuItem(value: Icons.home, child: Icon(Icons.home)),
                    ],
                    onChanged: (val) => setDialogState(() => icon = val!),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
            ElevatedButton(
                onPressed: () {
                  if (nameController.text.trim().isEmpty) return;
                  final newCat = Category(name: nameController.text.trim(), color: color, icon: icon);
                  if (cat == null) {
                    _addCategory(newCat);
                  } else {
                    _editCategory(index!, newCat);
                  }
                  Navigator.pop(context);
                },
                child: const Text('Salvar')),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Categorias')),
      body: categories.isEmpty
          ? const Center(child: Text('Nenhuma categoria criada.'))
          : ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: categories.length,
              itemBuilder: (_, index) {
                final cat = categories[index];
                return Card(
                  color: cat.color.withOpacity(0.2),
                  child: ListTile(
                    leading: Icon(cat.icon, color: cat.color),
                    title: Text(cat.name),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                            icon: const Icon(Icons.edit, color: Colors.blue),
                            onPressed: () => _showCategoryDialog(cat: cat, index: index)),
                        IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _deleteCategory(index)),
                      ],
                    ),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCategoryDialog(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
