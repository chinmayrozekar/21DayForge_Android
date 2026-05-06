import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../models/challenge.dart';
import '../providers/challenge_provider.dart';

class NewChallengeView extends ConsumerStatefulWidget {
  final Challenge? challenge;

  const NewChallengeView({super.key, this.challenge});

  @override
  ConsumerState<NewChallengeView> createState() => _NewChallengeViewState();
}

class _NewChallengeViewState extends ConsumerState<NewChallengeView> {
  late final TextEditingController _titleController;
  late final TextEditingController _goalController;
  late DateTime _startDate;
  final _formKey = GlobalKey<FormState>();

  bool get isEditing => widget.challenge != null;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.challenge?.title ?? '');
    _goalController = TextEditingController(text: widget.challenge?.goal ?? '');
    _startDate = widget.challenge?.startDate ?? DateTime.now();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _goalController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final title = _titleController.text.trim();
    final goal = _goalController.text.trim();

    if (isEditing) {
      widget.challenge!.title = title;
      widget.challenge!.goal = goal;
      await ref.read(challengesProvider.notifier).updateChallenge(widget.challenge!);
    } else {
      final challenge = Challenge(
        id: const Uuid().v4(),
        title: title,
        goal: goal,
        startDate: _startDate,
      );
      await ref.read(challengesProvider.notifier).addChallenge(challenge);
    }

    if (mounted) {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  Text(
                    isEditing ? 'Edit Challenge' : 'New Challenge',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  hintText: 'e.g. Morning Run',
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _goalController,
                decoration: const InputDecoration(
                  hintText: 'e.g. Run 2 miles every morning',
                  labelText: 'Goal (optional)',
                  border: OutlineInputBorder(),
                ),
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Start Date'),
                subtitle: Text('${_startDate.month}/${_startDate.day}/${_startDate.year}'),
                trailing: const Icon(Icons.calendar_today),
                onTap: _selectDate,
              ),
              const SizedBox(height: 16),
              if (!isEditing)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            "You'll track this challenge for 21 consecutive days.",
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: _save,
                child: Text(isEditing ? 'Save' : 'Start'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime.now().subtract(const Duration(days: 30)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date != null) {
      setState(() {
        _startDate = date;
      });
    }
  }
}