import 'package:algoquest/domain/entities/structure_state.dart';
import 'package:algoquest/presentation/theme/app_assets.dart';
import 'package:flutter/material.dart';

class LinkedListSlotsChallengeBody extends StatelessWidget {
  final StructureState structure;
  final void Function({required String slotId, required int value})
  onValueDropped;

  const LinkedListSlotsChallengeBody({
    super.key,
    required this.structure,
    required this.onValueDropped,
  });

  @override
  Widget build(BuildContext context) {
    final slots = structure.slots.values.toList(growable: false)
      ..sort((a, b) => (a.index ?? 0).compareTo(b.index ?? 0));

    return ListView(
      padding: EdgeInsets.zero,
      children: [
        _LinkedListPanel(
          slots: slots,
          nodes: structure.nodes,
          onValueDropped: onValueDropped,
        ),
        const SizedBox(height: 20),
        _InventoryPanel(values: structure.inventory),
      ],
    );
  }
}

class _LinkedListPanel extends StatelessWidget {
  final List<SlotState> slots;
  final Map<String, NodeState> nodes;
  final void Function({required String slotId, required int value})
  onValueDropped;

  const _LinkedListPanel({
    required this.slots,
    required this.nodes,
    required this.onValueDropped,
  });

  @override
  Widget build(BuildContext context) {
    return _ChallengePanel(
      title: 'Tu lista',
      imageIconAssetPath: AppAssets.chain,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            for (var index = 0; index < slots.length; index++) ...[
              _LinkedListSlot(
                slot: slots[index],
                value: _valueForSlot(slots[index]),
                onValueDropped: onValueDropped,
              ),
              if (index != slots.length - 1) const _ArrowConnector(),
            ],
          ],
        ),
      ),
    );
  }

  int? _valueForSlot(SlotState slot) {
    final filledNodeId = slot.filledNodeId;

    if (filledNodeId == null) {
      return null;
    }

    return nodes[filledNodeId]?.value;
  }
}

class _InventoryPanel extends StatelessWidget {
  final List<int> values;

  const _InventoryPanel({required this.values});

  @override
  Widget build(BuildContext context) {
    return _ChallengePanel(
      title: 'Inventario',
      imageIconAssetPath: AppAssets.backpack,
      child: Wrap(
        spacing: 20,
        runSpacing: 14,
        children: [
          for (final value in values) _InventoryValueChip(value: value),
        ],
      ),
    );
  }
}

class _LinkedListSlot extends StatelessWidget {
  final SlotState slot;
  final int? value;
  final void Function({required String slotId, required int value})
  onValueDropped;

  const _LinkedListSlot({
    required this.slot,
    required this.value,
    required this.onValueDropped,
  });

  @override
  Widget build(BuildContext context) {
    return DragTarget<int>(
      onWillAcceptWithDetails: (_) => value == null,
      onAcceptWithDetails: (details) {
        onValueDropped(slotId: slot.id, value: details.data);
      },
      builder: (context, candidateData, rejectedData) {
        final isHovering = candidateData.isNotEmpty;
        final hasValue = value != null;

        return AnimatedContainer(
          duration: const Duration(milliseconds: 140),
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: hasValue ? Colors.white : const Color(0xFFF2ECFF),
            borderRadius: BorderRadius.circular(11),
            border: Border.all(
              color: isHovering
                  ? const Color(0xFF6B3DEB)
                  : const Color(0xFFB895FF),
              width: isHovering ? 2 : 1.4,
            ),
            boxShadow: isHovering
                ? [
                    BoxShadow(
                      color: const Color(0xFF6B3DEB).withValues(alpha: 0.18),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          alignment: Alignment.center,
          child: hasValue
              ? Text(
                  value.toString(),
                  style: const TextStyle(
                    color: Color(0xFF101235),
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                  ),
                )
              : const _EmptySlotDot(),
        );
      },
    );
  }
}

class _InventoryValueChip extends StatelessWidget {
  final int value;

  const _InventoryValueChip({required this.value});

  @override
  Widget build(BuildContext context) {
    return Draggable<int>(
      data: value,
      feedback: Material(
        color: Colors.transparent,
        child: Transform.scale(
          scale: 1.08,
          child: _ValueChip(value: value, elevated: true),
        ),
      ),
      childWhenDragging: Opacity(
        opacity: 0.35,
        child: _ValueChip(value: value),
      ),
      child: _ValueChip(value: value),
    );
  }
}

class _ValueChip extends StatelessWidget {
  final int value;
  final bool elevated;

  const _ValueChip({required this.value, this.elevated = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 46,
      height: 42,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFB895FF), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: const Color(
              0xFF6B3DEB,
            ).withValues(alpha: elevated ? 0.24 : 0.08),
            blurRadius: elevated ? 16 : 8,
            offset: Offset(0, elevated ? 8 : 3),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: Text(
        value.toString(),
        style: const TextStyle(
          color: Color(0xFF101235),
          fontSize: 17,
          fontWeight: FontWeight.w900,
        ),
      ),
    );
  }
}

class _ArrowConnector extends StatelessWidget {
  const _ArrowConnector();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 4),
      child: Icon(
        Icons.arrow_forward_rounded,
        color: Color(0xFF8B62F2),
        size: 18,
      ),
    );
  }
}

class _EmptySlotDot extends StatelessWidget {
  const _EmptySlotDot();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 22,
      height: 22,
      decoration: BoxDecoration(
        color: Color(0xB3DCD2F8),
        shape: BoxShape.circle,
      ),
    );
  }
}

class _ChallengePanel extends StatelessWidget {
  final String title;
  final String? imageIconAssetPath;
  final Widget child;

  const _ChallengePanel({
    required this.title,
    required this.child,
    this.imageIconAssetPath,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFEAE3FF), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.035),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _PanelTitle(title: title, imageIconAssetPath: imageIconAssetPath),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _PanelTitle extends StatelessWidget {
  final String title;
  final String? imageIconAssetPath;

  const _PanelTitle({required this.title, this.imageIconAssetPath});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (imageIconAssetPath != null)
          SizedBox(
            width: 18,
            height: 18,
            child: Transform.scale(
              scale: 4.5,
              child: Image.asset(imageIconAssetPath!, fit: BoxFit.contain),
            ),
          ),
        const SizedBox(width: 17),
        Transform.translate(
          offset: Offset(0, -4),
          child: Text(
            title,
            style: const TextStyle(
              color: Color(0xFF6B3DEB),
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ],
    );
  }
}
