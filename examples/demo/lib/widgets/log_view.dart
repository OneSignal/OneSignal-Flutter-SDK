import 'package:flutter/material.dart';

import '../services/log_manager.dart';
import '../theme.dart';

class LogView extends StatefulWidget {
  const LogView({super.key});

  @override
  State<LogView> createState() => _LogViewState();
}

class _LogViewState extends State<LogView> {
  bool _expanded = true;
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    LogManager().addListener(_onLogChanged);
  }

  @override
  void dispose() {
    LogManager().removeListener(_onLogChanged);
    _scrollController.dispose();
    super.dispose();
  }

  void _onLogChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final logs = LogManager().logs;
    final textTheme = Theme.of(context).textTheme;
    final logEntryStyle = textTheme.labelSmall?.copyWith(
      fontFamily: 'monospace',
    );

    const logBackground = AppColors.osLogBackground;

    return Semantics(
      identifier: 'log_view_container',
      container: true,
      child: Card(
        margin: EdgeInsets.zero,
        color: logBackground,
        shape: const RoundedRectangleBorder(),
        child: Column(
          children: [
            InkWell(
              onTap: () => setState(() => _expanded = !_expanded),
              excludeFromSemantics: true,
              borderRadius: BorderRadius.zero,
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    Text(
                      'LOGS',
                      style: textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Semantics(
                      identifier: 'log_view_count',
                      container: true,
                      child: Text(
                        '${logs.length}',
                        style: textTheme.labelSmall?.copyWith(
                          color: AppColors.osGrey500,
                        ),
                      ),
                    ),
                    const Spacer(),
                    if (logs.isNotEmpty)
                      Semantics(
                        identifier: 'log_view_clear_button',
                        container: true,
                        child: GestureDetector(
                          excludeFromSemantics: true,
                          onTap: () => LogManager().clear(),
                          child: const Icon(
                            Icons.delete,
                            size: 18,
                            color: AppColors.osGrey500,
                          ),
                        ),
                      ),
                    const SizedBox(width: 8),
                    Icon(
                      _expanded
                          ? Icons.expand_less
                          : Icons.expand_more,
                      size: 18,
                      color: AppColors.osGrey500,
                    ),
                  ],
                ),
              ),
            ),
            if (_expanded)
              SizedBox(
                height: 100,
                child: logs.isEmpty
                    ? Center(
                        child: Text(
                          'No logs yet',
                          style: textTheme.bodyMedium?.copyWith(
                            color: AppColors.osGrey500,
                          ),
                        ),
                      )
                    : ListView.builder(
                        controller: _scrollController,
                        itemCount: logs.length,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        itemBuilder: (context, index) {
                          final entry = logs[logs.length - 1 - index];
                          return Padding(
                            padding: const EdgeInsets.symmetric(
                              vertical: 1,
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  entry.formattedTime,
                                  style: logEntryStyle?.copyWith(
                                    color: AppColors.osLogTimestamp,
                                  ),
                                ),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Semantics(
                                    identifier: 'log_entry_${index}_message',
                                    container: true,
                                    child: Text(
                                      entry.message,
                                      style: logEntryStyle?.copyWith(
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
          ],
        ),
      ),
    );
  }
}
