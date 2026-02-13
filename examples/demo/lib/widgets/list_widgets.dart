import 'package:flutter/material.dart';

class PairItem extends StatelessWidget {
  final String keyText;
  final String valueText;
  final VoidCallback? onDelete;

  const PairItem({
    super.key,
    required this.keyText,
    required this.valueText,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  keyText,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                ),
                Text(
                  valueText,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          if (onDelete != null)
            GestureDetector(
              onTap: onDelete,
              child: Icon(Icons.close, size: 18, color: Colors.grey[500]),
            ),
        ],
      ),
    );
  }
}

class SingleItem extends StatelessWidget {
  final String text;
  final VoidCallback? onDelete;

  const SingleItem({
    super.key,
    required this.text,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
      child: Row(
        children: [
          Expanded(child: Text(text, style: const TextStyle(fontSize: 14))),
          if (onDelete != null)
            GestureDetector(
              onTap: onDelete,
              child: Icon(Icons.close, size: 18, color: Colors.grey[500]),
            ),
        ],
      ),
    );
  }
}

class EmptyState extends StatelessWidget {
  final String text;

  const EmptyState({super.key, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Center(
        child: Text(
          text,
          style: TextStyle(color: Colors.grey[400], fontSize: 14),
        ),
      ),
    );
  }
}

class PairList extends StatelessWidget {
  final List<MapEntry<String, String>> items;
  final String emptyText;
  final void Function(String key)? onDelete;

  const PairList({
    super.key,
    required this.items,
    required this.emptyText,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) return EmptyState(text: emptyText);

    return Column(
      children: [
        for (var i = 0; i < items.length; i++) ...[
          PairItem(
            key: ValueKey('${items[i].key}_${items[i].value}'),
            keyText: items[i].key,
            valueText: items[i].value,
            onDelete:
                onDelete != null ? () => onDelete!(items[i].key) : null,
          ),
          if (i < items.length - 1) const Divider(height: 1),
        ],
      ],
    );
  }
}

class CollapsibleList extends StatefulWidget {
  final List<String> items;
  final String emptyText;
  final void Function(String item) onDelete;
  final int maxVisible;

  const CollapsibleList({
    super.key,
    required this.items,
    required this.emptyText,
    required this.onDelete,
    this.maxVisible = 5,
  });

  @override
  State<CollapsibleList> createState() => _CollapsibleListState();
}

class _CollapsibleListState extends State<CollapsibleList> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    if (widget.items.isEmpty) return EmptyState(text: widget.emptyText);

    final showAll = _expanded || widget.items.length <= widget.maxVisible;
    final visibleItems =
        showAll ? widget.items : widget.items.take(widget.maxVisible).toList();
    final remaining = widget.items.length - widget.maxVisible;

    return Column(
      children: [
        for (var i = 0; i < visibleItems.length; i++) ...[
          SingleItem(
            key: ValueKey(visibleItems[i]),
            text: visibleItems[i],
            onDelete: () => widget.onDelete(visibleItems[i]),
          ),
          if (i < visibleItems.length - 1) const Divider(height: 1),
        ],
        if (!showAll && remaining > 0)
          GestureDetector(
            onTap: () => setState(() => _expanded = true),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 4),
              child: Text(
                '$remaining more',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
