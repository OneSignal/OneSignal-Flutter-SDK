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
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 100),
          curve: Curves.easeOut,
        );
      }
    });
  }

  Color _levelColor(LogLevel level) {
    switch (level) {
      case LogLevel.debug:
        return AppColors.osLogDebug;
      case LogLevel.info:
        return AppColors.osLogInfo;
      case LogLevel.warn:
        return AppColors.osLogWarn;
      case LogLevel.error:
        return AppColors.osLogError;
    }
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
      label: 'log_view_container',
      child: Card(
        margin: EdgeInsets.zero,
        color: logBackground,
        shape: const RoundedRectangleBorder(),
        child: Column(
          children: [
            Semantics(
              label: 'log_view_header',
              child: InkWell(
                onTap: () => setState(() => _expanded = !_expanded),
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
                        label: 'log_view_count',
                        child: Text(
                          '(${logs.length})',
                          style: textTheme.labelSmall?.copyWith(
                            color: AppColors.osGrey500,
                          ),
                        ),
                      ),
                      const Spacer(),
                      if (logs.isNotEmpty)
                        Semantics(
                          label: 'log_view_clear_button',
                          child: GestureDetector(
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
                        size: 20,
                        color: AppColors.osGrey500,
                      ),
                    ],
                  ),
                ),
              ),
            ),
            if (_expanded)
              Semantics(
                label: 'log_view_list',
                child: SizedBox(
                  height: 100,
                  child: logs.isEmpty
                      ? Semantics(
                          label: 'log_view_empty',
                          child: Center(
                            child: Text(
                              'No logs yet',
                              style: textTheme.bodyMedium?.copyWith(
                                color: AppColors.osGrey500,
                              ),
                            ),
                          ),
                        )
                      : ListView.builder(
                          controller: _scrollController,
                          itemCount: logs.length,
                          padding: const EdgeInsets.symmetric(horizontal: 12),
                          itemBuilder: (context, index) {
                            final entry = logs[index];
                            return Semantics(
                              label: 'log_entry_$index',
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 1,
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Semantics(
                                      label: 'log_entry_${index}_timestamp',
                                      child: Text(
                                        entry.formattedTime,
                                        style: logEntryStyle?.copyWith(
                                          color: AppColors.osLogTimestamp,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Semantics(
                                      label: 'log_entry_${index}_level',
                                      child: Text(
                                        entry.levelLabel,
                                        style: logEntryStyle?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: _levelColor(entry.level),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Semantics(
                                        label: 'log_entry_${index}_message',
                                        child: Text(
                                          '${entry.tag}: ${entry.message}',
                                          style: logEntryStyle?.copyWith(
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
