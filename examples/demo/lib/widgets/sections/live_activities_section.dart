import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../theme.dart';
import '../../viewmodels/app_viewmodel.dart';
import '../action_button.dart';
import '../section_card.dart';

class LiveActivitiesSection extends StatefulWidget {
  final VoidCallback? onInfoTap;

  const LiveActivitiesSection({super.key, this.onInfoTap});

  @override
  State<LiveActivitiesSection> createState() => _LiveActivitiesSectionState();
}

class _LiveActivitiesSectionState extends State<LiveActivitiesSection> {
  late TextEditingController _activityIdController;
  late TextEditingController _orderNumberController;

  @override
  void initState() {
    super.initState();
    final vm = context.read<AppViewModel>();
    _activityIdController = TextEditingController(text: vm.activityId);
    _orderNumberController = TextEditingController(text: vm.orderNumber);
  }

  @override
  void dispose() {
    _activityIdController.dispose();
    _orderNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<AppViewModel>();
    final activityEmpty = _activityIdController.text.isEmpty;

    return SectionCard(
      title: 'Live Activities',
      onInfoTap: widget.onInfoTap,
      child: Column(
        children: [
          Card(
            margin: EdgeInsets.zero,
            child: Padding(
              padding: AppSpacing.cardPadding,
              child: Column(
                children: [
                  TextField(
                    controller: _activityIdController,
                    decoration: const InputDecoration(labelText: 'Activity ID'),
                    onChanged: (value) {
                      vm.setActivityId(value);
                      setState(() {});
                    },
                  ),
                  AppSpacing.gapBox,
                  TextField(
                    controller: _orderNumberController,
                    decoration: const InputDecoration(labelText: 'Order #'),
                    onChanged: (value) => vm.setOrderNumber(value),
                  ),
                ],
              ),
            ),
          ),
          AppSpacing.gapBox,
          PrimaryButton(
            label: 'START LIVE ACTIVITY',
            onPressed: activityEmpty ? null : () => vm.startLiveActivity(),
          ),
          AppSpacing.gapBox,
          PrimaryButton(
            label: 'UPDATE → ${vm.nextStatusLabel}',
            onPressed: activityEmpty || vm.isLaUpdating || !vm.hasApiKey
                ? null
                : () => vm.updateLiveActivity(),
          ),
          AppSpacing.gapBox,
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: activityEmpty ? null : () => vm.exitLiveActivity(),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.osPrimary,
                side: const BorderSide(color: AppColors.osPrimary),
              ),
              child: const Text('STOP UPDATING LIVE ACTIVITY'),
            ),
          ),
          AppSpacing.gapBox,
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: activityEmpty || !vm.hasApiKey
                  ? null
                  : () => vm.endLiveActivity(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('END LIVE ACTIVITY'),
            ),
          ),
        ],
      ),
    );
  }
}
