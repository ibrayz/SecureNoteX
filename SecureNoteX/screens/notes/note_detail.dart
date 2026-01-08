import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../db/database_helper.dart';
import '../../models/note.dart';

class NoteDetailScreen extends StatefulWidget {
  final Note note;

  const NoteDetailScreen({super.key, required this.note});

  @override
  State<NoteDetailScreen> createState() => _NoteDetailScreenState();
}

class _NoteDetailScreenState extends State<NoteDetailScreen> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  late String _selectedCategory;
  late int _selectedColorIndex;
  bool _isEditing = false;

  final List<String> _categories = [
    'Genel',
    'İş',
    'Kişisel',
    'Fikir',
    'Alışveriş',
    'Önemli',
  ];

  final List<Color> _colors = [
    Colors.red.shade100,
    Colors.blue.shade100,
    Colors.green.shade100,
    Colors.orange.shade100,
    Colors.purple.shade100,
    Colors.pink.shade100,
    Colors.teal.shade100,
    Colors.amber.shade100,
  ];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.note.title);
    _contentController = TextEditingController(text: widget.note.content);
    _selectedCategory = widget.note.category;
    _selectedColorIndex = widget.note.colorIndex;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _updateNote() async {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lütfen başlık girin')),
      );
      return;
    }

    final updatedNote = Note(
      id: widget.note.id,
      title: _titleController.text.trim(),
      content: _contentController.text.trim(),
      category: _selectedCategory,
      colorIndex: _selectedColorIndex,
      createdAt: widget.note.createdAt,
      updatedAt: DateTime.now(),
    );

    await DatabaseHelper.instance.updateNote(updatedNote);

    setState(() {
      _isEditing = false;
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Not güncellendi')),
      );
    }
  }

  Future<void> _deleteNote() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Notu Sil'),
        content: const Text('Bu notu silmek istediğinizden emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Sil'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await DatabaseHelper.instance.deleteNote(widget.note.id!);
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Not silindi')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _colors[_selectedColorIndex % _colors.length];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: color,
        actions: [
          if (_isEditing)
            IconButton(
              icon: const Icon(Icons.check),
              onPressed: _updateNote,
            )
          else ...[
            IconButton(
              icon: const Icon(Icons.edit),
              onPressed: () => setState(() => _isEditing = true),
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: _deleteNote,
            ),
          ],
        ],
      ),
      body: Container(
        color: color.withOpacity(0.3),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (!_isEditing)
                Text(
                  _titleController.text,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                )
              else
                TextField(
                  controller: _titleController,
                  decoration: const InputDecoration(
                    hintText: 'Başlık',
                    border: InputBorder.none,
                  ),
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      _selectedCategory,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  const Spacer(),
                  Text(
                    DateFormat('dd MMM yyyy, HH:mm').format(widget.note.updatedAt),
                    style: TextStyle(color: Colors.grey[700], fontSize: 12),
                  ),
                ],
              ),
              if (_isEditing) ...[
                const SizedBox(height: 16),
                Wrap(
                  spacing: 8,
                  children: _categories.map((category) {
                    final isSelected = category == _selectedCategory;
                    return ChoiceChip(
                      label: Text(category),
                      selected: isSelected,
                      onSelected: (_) {
                        setState(() {
                          _selectedCategory = category;
                        });
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 12,
                  children: List.generate(_colors.length, (index) {
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedColorIndex = index;
                        });
                      },
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: _colors[index],
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: _selectedColorIndex == index
                                ? Colors.black
                                : Colors.transparent,
                            width: 3,
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ],
              const SizedBox(height: 24),
              if (!_isEditing)
                Text(
                  _contentController.text,
                  style: const TextStyle(fontSize: 16, height: 1.5),
                )
              else
                TextField(
                  controller: _contentController,
                  decoration: const InputDecoration(
                    hintText: 'Notunuzu buraya yazın...',
                    border: InputBorder.none,
                  ),
                  maxLines: null,
                  keyboardType: TextInputType.multiline,
                  style: const TextStyle(fontSize: 16, height: 1.5),
                ),
            ],
          ),
        ),
      ),
    );
  }
}