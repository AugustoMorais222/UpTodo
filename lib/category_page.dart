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
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: [
              Icon(icon, color: color),
              const SizedBox(width: 8),
              Text(cat == null ? 'Nova Categoria' : 'Editar Categoria'),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'Nome da categoria',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Text('Cor:', style: TextStyle(fontWeight: FontWeight.w500)),
                    const SizedBox(width: 10),
                    GestureDetector(
                      onTap: () async {
                        Color tempColor = color;
                        await showDialog(
                          context: context,
                          builder: (_) => AlertDialog(
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                            title: const Text('Escolha uma cor'),
                            content: BlockPicker(
                              pickerColor: color,
                              onColorChanged: (c) => tempColor = c,
                            ),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text('Cancelar'),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  setDialogState(() => color = tempColor);
                                  Navigator.pop(context);
                                },
                                child: const Text('Selecionar'),
                              ),
                            ],
                          ),
                        );
                      },
                      child: CircleAvatar(
                        backgroundColor: color,
                        radius: 16,
                        child: const Icon(Icons.color_lens, color: Colors.white, size: 18),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Text('Ícone:', style: TextStyle(fontWeight: FontWeight.w500)),
                    const SizedBox(width: 10),
                    DropdownButton<IconData>(
                      value: icon,
                      borderRadius: BorderRadius.circular(8),
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
          ),
          actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton.icon(
              icon: const Icon(Icons.save),
              label: const Text('Salvar', style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                backgroundColor: Colors.blue,
              ),
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
        title: const Text('Categorias',style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
      ),
      body: categories.isEmpty
          ? const Center(child: Text('Nenhuma categoria criada.', style: TextStyle(color: Colors.white),))
          : ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: categories.length,
              itemBuilder: (_, index) {
                final cat = categories[index];
                return Card(
                  color: cat.color.withOpacity(0.5),
                  child: ListTile(
                    leading: Icon(cat.icon, color: cat.color),
                    title: Text(cat.name, style: TextStyle(color: Colors.white),),
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
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add),
      ),
    );
  }
}
