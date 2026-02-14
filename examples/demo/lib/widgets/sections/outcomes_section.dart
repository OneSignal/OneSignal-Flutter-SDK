import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
      title: 'Outcome Events',
      onInfoTap: onInfoTap,
      child: PrimaryButton(
        label: 'SEND OUTCOME',
        onPressed: () async {
          final result = await showDialog<Map<String, dynamic>>(
            context: context,
            builder: (_) => const OutcomeDialog(),
          );
          if (result != null) {
            final type = result['type'] as OutcomeType;
            final name = result['name'] as String;
            switch (type) {
              case OutcomeType.normal:
                vm.sendOutcome(name);
              case OutcomeType.unique:
                vm.sendUniqueOutcome(name);
              case OutcomeType.withValue:
                vm.sendOutcomeWithValue(name, result['value'] as double);
            }
          }
        },
      ),
    );
  }
}
