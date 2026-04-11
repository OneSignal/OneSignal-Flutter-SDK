import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../theme.dart';
import '../../viewmodels/app_viewmodel.dart';
import '../app_text_field.dart';
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
      sectionKey: 'live_activities',
      onInfoTap: widget.onInfoTap,
      child: Column(
        children: [
          Card(
            margin: EdgeInsets.zero,
            child: Padding(
              padding: AppSpacing.cardPadding,
              child: Column(
                children: [
                  _InputRow(
                    label: 'Activity ID',
                    controller: _activityIdController,
                    onChanged: (value) {
                      vm.setActivityId(value);
                      setState(() {});
                    },
                  ),
                  const SizedBox(height: 4),
                  _InputRow(
                    label: 'Order #',
                    controller: _orderNumberController,
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
              onPressed: activityEmpty || !vm.hasApiKey
                  ? null
                  : () => vm.endLiveActivity(),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.osPrimary,
                side: const BorderSide(color: AppColors.osPrimary),
              ),
              child: const Text('END LIVE ACTIVITY'),
            ),
          ),
        ],
      ),
    );
  }
}

class _InputRow extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const _InputRow({
    required this.label,
    required this.controller,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.osGrey600,
            ),
          ),
        ),
        Expanded(
          child: AppTextField(
            controller: controller,
            textAlign: TextAlign.right,
            style: const TextStyle(fontSize: 14, color: Color(0xFF212121)),
            decoration: const InputDecoration(
              border: InputBorder.none,
              enabledBorder: InputBorder.none,
              focusedBorder: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(vertical: 4),
              isDense: true,
            ),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}
