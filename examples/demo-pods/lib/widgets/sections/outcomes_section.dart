import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../theme.dart';
import '../../viewmodels/app_viewmodel.dart';
import '../action_button.dart';
import '../dialogs.dart';
import '../section_card.dart';

class OutcomesSection extends StatelessWidget {
  final VoidCallback? onInfoTap;

  const OutcomesSection({super.key, this.onInfoTap});

  @override
  Widget build(BuildContext context) {
    final vm = context.read<AppViewModel>();

    return SectionCard(
      title: 'Outcomes',
      sectionKey: 'outcomes',
      onInfoTap: onInfoTap,
      child: PrimaryButton(
        label: 'SEND OUTCOME',
        semanticsLabel: 'send_outcome_button',
        onPressed: () async {
          final result = await showDialog<Map<String, dynamic>>(
            context: context,
            builder: (_) => const OutcomeDialog(),
          );
          if (result != null) {
            final type = result['type'] as OutcomeType;
            final name = result['name'] as String;
            String snackbarMessage;
            switch (type) {
              case OutcomeType.normal:
                vm.sendOutcome(name);
                snackbarMessage = 'Outcome sent: $name';
              case OutcomeType.unique:
                vm.sendUniqueOutcome(name);
                snackbarMessage = 'Unique outcome sent: $name';
              case OutcomeType.withValue:
                final value = result['value'] as double;
                vm.sendOutcomeWithValue(name, value);
                snackbarMessage = 'Outcome sent: $name = $value';
            }
            if (context.mounted) {
              context.showSnackBar(snackbarMessage);
            }
          }
        },
      ),
    );
  }
}
