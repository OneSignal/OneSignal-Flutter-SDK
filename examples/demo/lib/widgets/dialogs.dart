import 'dart:convert';

import 'package:flutter/material.dart';

import '../services/tooltip_helper.dart';

// Single input dialog (login, email, sms)
class SingleInputDialog extends StatefulWidget {
  final String title;
  final String fieldLabel;
  final String confirmLabel;
  final TextInputType keyboardType;

  const SingleInputDialog({
    super.key,
    required this.title,
    required this.fieldLabel,
    this.confirmLabel = 'Add',
    this.keyboardType = TextInputType.text,
  });

  @override
  State<SingleInputDialog> createState() => _SingleInputDialogState();
}

class _SingleInputDialogState extends State<SingleInputDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16),
      title: Text(widget.title),
      content: SizedBox(
        width: double.maxFinite,
        child: Semantics(
          label: '${widget.fieldLabel}_input',
          child: TextField(
            controller: _controller,
            decoration: InputDecoration(labelText: widget.fieldLabel),
            keyboardType: widget.keyboardType,
            onChanged: (_) => setState(() {}),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: _controller.text.isEmpty
              ? null
              : () => Navigator.pop(context, _controller.text),
          child: Text(widget.confirmLabel),
        ),
      ],
    );
  }
}

// Key-value pair input dialog (single pair)
class PairInputDialog extends StatefulWidget {
  final String title;
  final String keyLabel;
  final String valueLabel;

  const PairInputDialog({
    super.key,
    required this.title,
    this.keyLabel = 'Key',
    this.valueLabel = 'Value',
  });

  @override
  State<PairInputDialog> createState() => _PairInputDialogState();
}

class _PairInputDialogState extends State<PairInputDialog> {
  final _keyController = TextEditingController();
  final _valueController = TextEditingController();

  @override
  void dispose() {
    _keyController.dispose();
    _valueController.dispose();
    super.dispose();
  }

  bool get _isValid =>
      _keyController.text.isNotEmpty && _valueController.text.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16),
      title: Text(widget.title),
      content: SizedBox(
        width: double.maxFinite,
        child: Row(
          children: [
            Expanded(
              child: Semantics(
                label: '${widget.keyLabel}_input',
                child: TextField(
                  controller: _keyController,
                  decoration: InputDecoration(labelText: widget.keyLabel),
                  onChanged: (_) => setState(() {}),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Semantics(
                label: '${widget.valueLabel}_input',
                child: TextField(
                  controller: _valueController,
                  decoration: InputDecoration(labelText: widget.valueLabel),
                  onChanged: (_) => setState(() {}),
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: _isValid
              ? () => Navigator.pop(
                    context,
                    MapEntry(_keyController.text, _valueController.text),
                  )
              : null,
          child: const Text('Add'),
        ),
      ],
    );
  }
}

// Multi-pair input dialog (dynamic rows)
class MultiPairInputDialog extends StatefulWidget {
  final String title;
  final String keyLabel;
  final String valueLabel;

  const MultiPairInputDialog({
    super.key,
    required this.title,
    this.keyLabel = 'Key',
    this.valueLabel = 'Value',
  });

  @override
  State<MultiPairInputDialog> createState() => _MultiPairInputDialogState();
}

class _MultiPairInputDialogState extends State<MultiPairInputDialog> {
  final List<TextEditingController> _keyControllers = [];
  final List<TextEditingController> _valueControllers = [];

  @override
  void initState() {
    super.initState();
    _addRow();
  }

  @override
  void dispose() {
    for (final c in _keyControllers) {
      c.dispose();
    }
    for (final c in _valueControllers) {
      c.dispose();
    }
    super.dispose();
  }

  void _addRow() {
    final keyC = TextEditingController();
    final valC = TextEditingController();
    keyC.addListener(() => setState(() {}));
    valC.addListener(() => setState(() {}));
    _keyControllers.add(keyC);
    _valueControllers.add(valC);
    setState(() {});
  }

  void _removeRow(int index) {
    _keyControllers[index].dispose();
    _valueControllers[index].dispose();
    _keyControllers.removeAt(index);
    _valueControllers.removeAt(index);
    setState(() {});
  }

  bool get _allValid {
    for (var i = 0; i < _keyControllers.length; i++) {
      if (_keyControllers[i].text.isEmpty ||
          _valueControllers[i].text.isEmpty) {
        return false;
      }
    }
    return _keyControllers.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16),
      title: Text(widget.title),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (var i = 0; i < _keyControllers.length; i++) ...[
                if (i > 0) const Divider(),
                Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _keyControllers[i],
                      decoration: InputDecoration(
                        labelText: widget.keyLabel,
                        isDense: true,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _valueControllers[i],
                      decoration: InputDecoration(
                        labelText: widget.valueLabel,
                        isDense: true,
                      ),
                    ),
                  ),
                  if (_keyControllers.length > 1)
                    IconButton(
                      icon: const Icon(Icons.close, size: 20),
                      onPressed: () => _removeRow(i),
                    ),
                ],
              ),
            ],
              TextButton.icon(
                onPressed: _addRow,
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Add Row'),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: _allValid
              ? () {
                  final pairs = <String, String>{};
                  for (var i = 0; i < _keyControllers.length; i++) {
                    pairs[_keyControllers[i].text] =
                        _valueControllers[i].text;
                  }
                  Navigator.pop(context, pairs);
                }
              : null,
          child: const Text('Add All'),
        ),
      ],
    );
  }
}

// Multi-select remove dialog
class MultiSelectRemoveDialog extends StatefulWidget {
  final String title;
  final List<MapEntry<String, String>> items;

  const MultiSelectRemoveDialog({
    super.key,
    required this.title,
    required this.items,
  });

  @override
  State<MultiSelectRemoveDialog> createState() =>
      _MultiSelectRemoveDialogState();
}

class _MultiSelectRemoveDialogState extends State<MultiSelectRemoveDialog> {
  final Set<String> _selected = {};

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16),
      title: Text(widget.title),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: widget.items.map((item) {
              return CheckboxListTile(
                title: Text(item.key),
                value: _selected.contains(item.key),
                controlAffinity: ListTileControlAffinity.leading,
                onChanged: (checked) {
                  setState(() {
                    if (checked == true) {
                      _selected.add(item.key);
                    } else {
                      _selected.remove(item.key);
                    }
                  });
                },
                contentPadding: EdgeInsets.zero,
              );
            }).toList(),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: _selected.isEmpty
              ? null
              : () => Navigator.pop(context, _selected.toList()),
          child: Text('Remove (${_selected.length})'),
        ),
      ],
    );
  }
}

// Login dialog
class LoginDialog extends StatefulWidget {
  const LoginDialog({super.key});

  @override
  State<LoginDialog> createState() => _LoginDialogState();
}

class _LoginDialogState extends State<LoginDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16),
      title: const Text('Login User'),
      content: SizedBox(
        width: double.maxFinite,
        child: Semantics(
          label: 'external_user_id_input',
          child: TextField(
            controller: _controller,
            decoration: const InputDecoration(labelText: 'External User Id'),
            onChanged: (_) => setState(() {}),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: _controller.text.isEmpty
              ? null
              : () => Navigator.pop(context, _controller.text),
          child: const Text('Login'),
        ),
      ],
    );
  }
}

// Outcome dialog
class OutcomeDialog extends StatefulWidget {
  const OutcomeDialog({super.key});

  @override
  State<OutcomeDialog> createState() => _OutcomeDialogState();
}

enum OutcomeType { normal, unique, withValue }

class _OutcomeDialogState extends State<OutcomeDialog> {
  final _nameController = TextEditingController();
  final _valueController = TextEditingController();
  OutcomeType _type = OutcomeType.normal;

  @override
  void dispose() {
    _nameController.dispose();
    _valueController.dispose();
    super.dispose();
  }

  bool get _isValid {
    if (_nameController.text.isEmpty) return false;
    if (_type == OutcomeType.withValue) {
      return double.tryParse(_valueController.text) != null;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16),
      title: const Text('Send Outcome'),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              RadioGroup<OutcomeType>(
                groupValue: _type,
                onChanged: (v) => setState(() { if (v != null) _type = v; }),
                child: Column(
                  children: [
                    RadioListTile<OutcomeType>(
                      title: const Text('Normal Outcome'),
                      value: OutcomeType.normal,
                      contentPadding: EdgeInsets.zero,
                    ),
                    RadioListTile<OutcomeType>(
                      title: const Text('Unique Outcome'),
                      value: OutcomeType.unique,
                      contentPadding: EdgeInsets.zero,
                    ),
                    RadioListTile<OutcomeType>(
                      title: const Text('Outcome with Value'),
                      value: OutcomeType.withValue,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Outcome Name'),
                onChanged: (_) => setState(() {}),
              ),
              if (_type == OutcomeType.withValue) ...[
                const SizedBox(height: 12),
                TextField(
                  controller: _valueController,
                  decoration: const InputDecoration(labelText: 'Value'),
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  onChanged: (_) => setState(() {}),
                ),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: _isValid
              ? () {
                  Navigator.pop(context, {
                    'type': _type,
                    'name': _nameController.text,
                    'value': _type == OutcomeType.withValue
                        ? double.parse(_valueController.text)
                        : null,
                  });
                }
              : null,
          child: const Text('Send'),
        ),
      ],
    );
  }
}

// Track event dialog
class TrackEventDialog extends StatefulWidget {
  const TrackEventDialog({super.key});

  @override
  State<TrackEventDialog> createState() => _TrackEventDialogState();
}

class _TrackEventDialogState extends State<TrackEventDialog> {
  final _nameController = TextEditingController();
  final _propsController = TextEditingController();
  String? _jsonError;

  @override
  void dispose() {
    _nameController.dispose();
    _propsController.dispose();
    super.dispose();
  }

  bool get _isValid {
    if (_nameController.text.isEmpty) return false;
    if (_propsController.text.isNotEmpty && _jsonError != null) return false;
    return true;
  }

  void _validateJson(String text) {
    setState(() {
      if (text.isEmpty) {
        _jsonError = null;
      } else {
        try {
          jsonDecode(text);
          _jsonError = null;
        } catch (_) {
          _jsonError = 'Invalid JSON format';
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16),
      title: const Text('Track Event'),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Event Name'),
                onChanged: (_) => setState(() {}),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _propsController,
                decoration: InputDecoration(
                  labelText: 'Properties (optional, JSON)',
                  hintText: '{"key": "value"}',
                  errorText: _jsonError,
                ),
                maxLines: 3,
                onChanged: _validateJson,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: _isValid
              ? () {
                  Map<String, dynamic>? props;
                  if (_propsController.text.isNotEmpty) {
                    props = jsonDecode(_propsController.text)
                        as Map<String, dynamic>;
                  }
                  Navigator.pop(context, {
                    'name': _nameController.text,
                    'properties': props,
                  });
                }
              : null,
          child: const Text('Track'),
        ),
      ],
    );
  }
}

// Custom notification dialog
class CustomNotificationDialog extends StatefulWidget {
  const CustomNotificationDialog({super.key});

  @override
  State<CustomNotificationDialog> createState() =>
      _CustomNotificationDialogState();
}

class _CustomNotificationDialogState extends State<CustomNotificationDialog> {
  final _titleController = TextEditingController();
  final _bodyController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _bodyController.dispose();
    super.dispose();
  }

  bool get _isValid =>
      _titleController.text.isNotEmpty && _bodyController.text.isNotEmpty;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16),
      title: const Text('Custom Notification'),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'Title'),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _bodyController,
              decoration: const InputDecoration(labelText: 'Body'),
              onChanged: (_) => setState(() {}),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        TextButton(
          onPressed: _isValid
              ? () => Navigator.pop(context, {
                    'title': _titleController.text,
                    'body': _bodyController.text,
                  })
              : null,
          child: const Text('Send'),
        ),
      ],
    );
  }
}

// Tooltip dialog
class TooltipDialog extends StatelessWidget {
  final TooltipData tooltip;

  const TooltipDialog({super.key, required this.tooltip});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16),
      title: Text(tooltip.title),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(tooltip.description),
              if (tooltip.options != null && tooltip.options!.isNotEmpty) ...[
                const SizedBox(height: 16),
                ...tooltip.options!.map((option) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            option.name,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            option.description,
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    )),
              ],
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('OK'),
        ),
      ],
    );
  }
}
