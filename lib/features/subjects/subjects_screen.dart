import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/shared_providers.dart';
import '../../core/theme/app_colors.dart';
import '../../data/models/subject.dart';

const List<String> _palette = [
  '#F4652C', // primary orange
  '#3FB89A', // teal
  '#5B8DEF', // blue
  '#B980F0', // purple
  '#F2B84B', // amber
  '#E8637A', // rose
];

class SubjectsScreen extends ConsumerWidget {
  const SubjectsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subjectsAsync = ref.watch(subjectsProvider);

    return Scaffold(
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async => ref.invalidate(subjectsProvider),
          child: CustomScrollView(
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                sliver: SliverToBoxAdapter(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Subjects',
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(fontWeight: FontWeight.w700)),
                      IconButton.filled(
                        onPressed: () => _showAddSubjectDialog(context, ref),
                        icon: const Icon(Icons.add),
                        style: IconButton.styleFrom(backgroundColor: AppColors.ctaDark),
                      ),
                    ],
                  ),
                ),
              ),
              subjectsAsync.when(
                loading: () => const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                ),
                error: (e, st) => const SliverFillRemaining(
                  child: Center(child: Text('Couldn\'t load subjects.')),
                ),
                data: (subjects) {
                  if (subjects.isEmpty) {
                    return SliverFillRemaining(
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(32),
                          child: Text(
                            'No subjects yet. Tap + to add one — subjects group your tasks and study sessions.',
                            textAlign: TextAlign.center,
                            style: TextStyle(color: AppColors.textSecondary),
                          ),
                        ),
                      ),
                    );
                  }
                  return SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
                    sliver: SliverGrid(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 14,
                        mainAxisSpacing: 14,
                        childAspectRatio: 1.15,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, i) => _SubjectCard(subject: subjects[i]),
                        childCount: subjects.length,
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddSubjectDialog(BuildContext context, WidgetRef ref) {
    showDialog<void>(
      context: context,
      builder: (_) => const _AddSubjectDialog(),
    );
  }
}

class _SubjectCard extends StatelessWidget {
  const _SubjectCard({required this.subject});

  final Subject subject;

  Color get _color {
    final hex = subject.color;
    if (hex == null || hex.isEmpty) return AppColors.primary;
    final cleaned = hex.replaceFirst('#', '');
    return Color(int.parse('FF$cleaned', radix: 16));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(color: _color, shape: BoxShape.circle),
            child: const Icon(Icons.menu_book_rounded, color: Colors.white, size: 20),
          ),
          const Spacer(),
          Text(
            subject.name,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
          ),
        ],
      ),
    );
  }
}

class _AddSubjectDialog extends ConsumerStatefulWidget {
  const _AddSubjectDialog();

  @override
  ConsumerState<_AddSubjectDialog> createState() => _AddSubjectDialogState();
}

class _AddSubjectDialogState extends ConsumerState<_AddSubjectDialog> {
  final _controller = TextEditingController();
  String _color = _palette.first;
  bool _saving = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _controller.text.trim();
    if (name.isEmpty) return;
    setState(() => _saving = true);
    try {
      await ref.read(subjectsRepositoryProvider).create(name: name, color: _color);
      ref.invalidate(subjectsProvider);
      if (mounted) Navigator.of(context).pop();
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.background,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      title: const Text('New subject'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _controller,
            autofocus: true,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(hintText: 'e.g. Mathematics'),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              for (final hex in _palette)
                GestureDetector(
                  onTap: () => setState(() => _color = hex),
                  child: Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: Color(int.parse('FF${hex.replaceFirst('#', '')}', radix: 16)),
                      shape: BoxShape.circle,
                      border: _color == hex
                          ? Border.all(color: AppColors.textPrimary, width: 2)
                          : null,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
        FilledButton(
          onPressed: _saving ? null : _save,
          style: FilledButton.styleFrom(backgroundColor: AppColors.ctaDark),
          child: const Text('Add'),
        ),
      ],
    );
  }
}
