import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/shared_providers.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/subject.dart';
import '../home/providers/home_providers.dart';

/// Opens the "Add task" bottom sheet. Invalidates [todayTasksProvider] on a
/// successful save so the Home screen's Today list picks it up immediately.
Future<void> showAddTaskSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const _AddTaskSheet(),
  );
}

class _AddTaskSheet extends ConsumerStatefulWidget {
  const _AddTaskSheet();

  @override
  ConsumerState<_AddTaskSheet> createState() => _AddTaskSheetState();
}

class _AddTaskSheetState extends ConsumerState<_AddTaskSheet> {
  final _titleController = TextEditingController();
  String? _subjectId;
  DateTime? _dueDate = DateTime.now();
  String _priority = 'normal';
  bool _saving = false;
  String? _error;

  @override
  void dispose() {
    _titleController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final title = _titleController.text.trim();
    if (title.isEmpty) {
      setState(() => _error = 'Give the task a title.');
      return;
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await ref.read(tasksRepositoryProvider).create(
            title: title,
            subjectId: _subjectId,
            dueDate: _dueDate,
            priority: _priority,
          );
      ref.invalidate(todayTasksProvider);
      if (mounted) Navigator.of(context).pop();
    } catch (e) {
      if (mounted) setState(() => _error = 'Could not save — try again.');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _dueDate ?? now,
      firstDate: now.subtract(const Duration(days: 1)),
      lastDate: now.add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _dueDate = picked);
  }

  @override
  Widget build(BuildContext context) {
    final subjectsAsync = ref.watch(subjectsProvider);
    final viewInsets = MediaQuery.of(context).viewInsets;

    return Padding(
      padding: EdgeInsets.only(bottom: viewInsets.bottom),
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.divider,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text('New task',
                style: Theme.of(context)
                    .textTheme
                    .titleLarge
                    ?.copyWith(fontWeight: FontWeight.w700)),
            const SizedBox(height: 18),
            TextField(
              controller: _titleController,
              autofocus: true,
              textCapitalization: TextCapitalization.sentences,
              decoration: const InputDecoration(hintText: 'What do you need to do?'),
            ),
            const SizedBox(height: 14),
            subjectsAsync.when(
              loading: () => const SizedBox.shrink(),
              error: (e, st) => const SizedBox.shrink(),
              data: (subjects) => _SubjectPicker(
                subjects: subjects,
                selectedId: _subjectId,
                onChanged: (id) => setState(() => _subjectId = id),
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _pickDate,
                    icon: const Icon(Icons.calendar_today, size: 18),
                    label: Text(_dueDate == null
                        ? 'No date'
                        : '${_dueDate!.year}-${_dueDate!.month.toString().padLeft(2, '0')}-${_dueDate!.day.toString().padLeft(2, '0')}'),
                    style: OutlinedButton.styleFrom(minimumSize: const Size.fromHeight(48)),
                  ),
                ),
                const SizedBox(width: 10),
                TextButton(
                  onPressed: () => setState(() => _dueDate = null),
                  child: const Text('Someday'),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                for (final p in const ['low', 'normal', 'high']) ...[
                  Expanded(child: _PriorityChip(
                    label: p,
                    selected: _priority == p,
                    onTap: () => setState(() => _priority = p),
                  )),
                  if (p != 'high') const SizedBox(width: 10),
                ],
              ],
            ),
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(_error!, style: const TextStyle(color: AppColors.error)),
            ],
            const SizedBox(height: 22),
            ElevatedButton(
              onPressed: _saving ? null : _save,
              child: _saving
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : const Text('Save task'),
            ),
          ],
        ),
      ),
    );
  }
}

class _SubjectPicker extends StatelessWidget {
  const _SubjectPicker({required this.subjects, required this.selectedId, required this.onChanged});

  final List<Subject> subjects;
  final String? selectedId;
  final ValueChanged<String?> onChanged;

  @override
  Widget build(BuildContext context) {
    if (subjects.isEmpty) return const SizedBox.shrink();
    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _SubjectChip(label: 'No subject', selected: selectedId == null, onTap: () => onChanged(null)),
          const SizedBox(width: 8),
          for (final s in subjects) ...[
            _SubjectChip(label: s.name, selected: selectedId == s.id, onTap: () => onChanged(s.id)),
            const SizedBox(width: 8),
          ],
        ],
      ),
    );
  }
}

class _SubjectChip extends StatelessWidget {
  const _SubjectChip({required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
        decoration: BoxDecoration(
          color: selected ? AppColors.ctaDark : AppColors.surface,
          borderRadius: BorderRadius.circular(20),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            color: selected ? AppColors.onCtaDark : AppColors.textPrimary,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}

class _PriorityChip extends StatelessWidget {
  const _PriorityChip({required this.label, required this.selected, required this.onTap});

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          label[0].toUpperCase() + label.substring(1),
          style: TextStyle(
            color: selected ? Colors.white : AppColors.textPrimary,
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}
