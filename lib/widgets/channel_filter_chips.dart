import 'package:flutter/material.dart';

class ChannelFilterChips extends StatelessWidget {
  final List<String> channels;
  final String selectedChannel;
  final ValueChanged<String> onChannelSelected;

  const ChannelFilterChips({
    super.key,
    required this.channels,
    required this.selectedChannel,
    required this.onChannelSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12.0),
        itemCount: channels.length,
        itemBuilder: (context, index) {
          final channel = channels[index];
          final isSelected = channel == selectedChannel;

          return Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: ChoiceChip(
              label: Text(
                channel,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.grey[300],
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
              selected: isSelected,
              selectedColor: Theme.of(context).colorScheme.primary,
              backgroundColor: const Color(0xFF2C2C2C),
              showCheckmark: false,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: isSelected
                      ? Theme.of(context).colorScheme.primary
                      : Colors.transparent,
                ),
              ),
              onSelected: (selected) {
                if (selected) {
                  onChannelSelected(channel);
                }
              },
            ),
          );
        },
      ),
    );
  }
}
