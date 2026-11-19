import 'package:flutter/material.dart';

import '../services/log_service.dart';
import '../theme.dart';

const _monospace = 'monospace';
const _entryFontSize = 8.0;

class LogView extends StatefulWidget {
  const LogView({super.key});

  @override
  State<LogView> createState() => _LogViewState();
}

class _LogViewState extends State<LogView> {
  final _scrollController = ScrollController();
  bool _collapsed = false;

  @override
  void initState() {
    super.initState();
    LogService.entries.addListener(_onEntriesChanged);
  }

  @override
  void dispose() {
    LogService.entries.removeListener(_onEntriesChanged);
    _scrollController.dispose();
    super.dispose();
  }

  // Keep following new entries only while the reader is already at the end.
  void _onEntriesChanged() {
    final atEnd =
        !_scrollController.hasClients ||
        _scrollController.position.extentAfter < _entryFontSize * 2;
    if (atEnd) _scrollToEnd();
  }

  void _scrollToEnd() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scrollController.hasClients) return;
      _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
    });
  }

  void _toggle() {
    setState(() => _collapsed = !_collapsed);
    if (!_collapsed) _scrollToEnd();
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      identifier: 'log_view',
      container: true,
      child: ColoredBox(
        color: AppColors.osLogBackground,
        child: ValueListenableBuilder<List<LogEntry>>(
          valueListenable: LogService.entries,
          builder:
              (context, logs, _) => Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildHeader(logs.length),
                  if (!_collapsed) _buildBody(logs),
                ],
              ),
        ),
      ),
    );
  }

  Widget _buildHeader(int count) {
    return SizedBox(
      height: 24,
      child: Padding(
        padding: const EdgeInsets.only(left: 16, right: 9),
        child: Row(
          children: [
            Expanded(
              child: Text(
                'LOGS ($count)',
                style: const TextStyle(
                  color: AppColors.osGrey500,
                  fontFamily: _monospace,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            _HeaderButton(
              identifier: 'log_clear_button',
              label: 'Clear logs',
              icon: Icons.delete,
              size: 14,
              onTap: LogService.clear,
            ),
            _HeaderButton(
              identifier: 'log_toggle_button',
              label: _collapsed ? 'Expand logs' : 'Collapse logs',
              icon: _collapsed ? Icons.expand_more : Icons.expand_less,
              size: 18,
              onTap: _toggle,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody(List<LogEntry> logs) {
    const entryStyle = TextStyle(
      color: AppColors.osLogText,
      fontFamily: _monospace,
      fontSize: _entryFontSize,
      height: 1.4,
    );
    const mutedStyle = TextStyle(color: AppColors.osGrey600);

    return SizedBox(
      height: 100,
      child: SingleChildScrollView(
        controller: _scrollController,
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 6),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (logs.isEmpty)
              Text('No logs yet', style: entryStyle.merge(mutedStyle)),
            for (final (index, entry) in logs.indexed)
              Semantics(
                identifier: 'log_entry_$index',
                container: true,
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(text: entry.time, style: mutedStyle),
                      TextSpan(text: ' ${entry.message}'),
                    ],
                  ),
                  style: entryStyle,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _HeaderButton extends StatelessWidget {
  const _HeaderButton({
    required this.identifier,
    required this.label,
    required this.icon,
    required this.size,
    required this.onTap,
  });

  final String identifier;
  final String label;
  final IconData icon;
  final double size;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      identifier: identifier,
      container: true,
      button: true,
      label: label,
      excludeSemantics: true,
      onTap: onTap,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        // The header is only 24 tall, so widen the target instead.
        child: SizedBox(
          width: 32,
          height: double.infinity,
          child: Icon(icon, size: size, color: AppColors.osGrey500),
        ),
      ),
    );
  }
}
