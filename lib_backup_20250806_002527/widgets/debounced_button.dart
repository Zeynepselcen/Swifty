import 'package:flutter/material.dart';

class DebouncedButton extends StatefulWidget {
  final Widget child;
  final Future<void> Function() onPressed;
  final Duration debounceDuration;

  const DebouncedButton({
    required this.child,
    required this.onPressed,
    this.debounceDuration = const Duration(milliseconds: 800),
    Key? key,
  }) : super(key: key);

  @override
  State<DebouncedButton> createState() => _DebouncedButtonState();
}

class _DebouncedButtonState extends State<DebouncedButton> {
  bool _isProcessing = false;

  Future<void> _handleTap() async {
    if (_isProcessing) return;
    setState(() => _isProcessing = true);
    try {
      await widget.onPressed();
    } finally {
      await Future.delayed(widget.debounceDuration);
      if (mounted) setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleTap,
      child: AbsorbPointer(
        absorbing: _isProcessing,
        child: widget.child,
      ),
    );
  }
} 