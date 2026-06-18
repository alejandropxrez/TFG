import 'package:flutter/material.dart';

class ChallengeSelectOption {
  final String id;
  final String label;

  const ChallengeSelectOption({required this.id, required this.label});
}

class ChallengeSelectBox extends StatefulWidget {
  final String? selectedOptionId;
  final List<ChallengeSelectOption> options;
  final ValueChanged<String> onChanged;
  final String placeholder;
  final double height;
  final double? width;

  const ChallengeSelectBox({
    super.key,
    required this.selectedOptionId,
    required this.options,
    required this.onChanged,
    this.placeholder = 'Select an option',
    this.height = 50,
    this.width,
  });

  @override
  State<ChallengeSelectBox> createState() => _ChallengeSelectBoxState();
}

class _ChallengeSelectBoxState extends State<ChallengeSelectBox> {
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;

  static const _purple = Color(0xFF6B3DEB);
  static const _darkText = Color(0xFF101235);
  static const _placeholderText = Color(0xFF56536C);
  static const _surface = Colors.white;

  bool get _isOpen => _overlayEntry != null;

  ChallengeSelectOption? get _selectedOption {
    for (final option in widget.options) {
      if (option.id == widget.selectedOptionId) {
        return option;
      }
    }

    return null;
  }

  @override
  void dispose() {
    _removeOverlay();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selectedOption = _selectedOption;

    return CompositedTransformTarget(
      link: _layerLink,
      child: SizedBox(
        width: widget.width,
        height: widget.height,
        child: Material(
          color: _surface,
          borderRadius: BorderRadius.circular(10),
          child: InkWell(
            onTap: _toggleOverlay,
            borderRadius: BorderRadius.circular(10),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              decoration: BoxDecoration(
                color: _surface,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: _purple, width: 1.6),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      selectedOption?.label ?? widget.placeholder,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: selectedOption == null
                            ? _placeholderText
                            : _darkText,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  AnimatedRotation(
                    turns: _isOpen ? 0.5 : 0,
                    duration: const Duration(milliseconds: 160),
                    child: const Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: _darkText,
                      size: 30,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _toggleOverlay() {
    if (_isOpen) {
      _removeOverlay();
      return;
    }

    _showOverlay();
  }

  void _showOverlay() {
    final renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null || !renderBox.hasSize) return;

    final size = renderBox.size;

    _overlayEntry = OverlayEntry(
      builder: (context) {
        return Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                behavior: HitTestBehavior.translucent,
                onTap: _removeOverlay,
                child: const SizedBox.expand(),
              ),
            ),
            CompositedTransformFollower(
              link: _layerLink,
              showWhenUnlinked: false,
              offset: Offset(0, size.height + 8),
              child: Material(
                color: Colors.transparent,
                child: _SelectMenu(
                  width: size.width,
                  options: widget.options,
                  selectedOptionId: widget.selectedOptionId,
                  onSelected: (optionId) {
                    widget.onChanged(optionId);
                    _removeOverlay();
                  },
                ),
              ),
            ),
          ],
        );
      },
    );

    Overlay.of(context).insert(_overlayEntry!);
    setState(() {});
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;

    if (mounted) {
      setState(() {});
    }
  }
}

class _SelectMenu extends StatelessWidget {
  final double width;
  final List<ChallengeSelectOption> options;
  final String? selectedOptionId;
  final ValueChanged<String> onSelected;

  const _SelectMenu({
    required this.width,
    required this.options,
    required this.selectedOptionId,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      constraints: const BoxConstraints(maxHeight: 230),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE7E1F5), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.16),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      clipBehavior: Clip.antiAlias,
      child: SingleChildScrollView(
        padding: EdgeInsets.zero,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final option in options)
              _SelectMenuItem(
                option: option,
                selected: option.id == selectedOptionId,
                onTap: () => onSelected(option.id),
              ),
          ],
        ),
      ),
    );
  }
}

class _SelectMenuItem extends StatelessWidget {
  final ChallengeSelectOption option;
  final bool selected;
  final VoidCallback onTap;

  const _SelectMenuItem({
    required this.option,
    required this.selected,
    required this.onTap,
  });

  static const _purple = Color(0xFF6B3DEB);
  static const _darkText = Color(0xFF101235);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? _purple : Colors.white,
      child: InkWell(
        onTap: onTap,
        child: SizedBox(
          height: 48,
          width: double.infinity,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                option.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: selected ? Colors.white : _darkText,
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
