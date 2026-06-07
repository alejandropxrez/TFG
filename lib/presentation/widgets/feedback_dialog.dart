import 'package:flutter/material.dart';

class FeedbackDialog extends StatelessWidget {
  final bool solved;
  final String? theoryRef;
  final VoidCallback? onContinue;

  const FeedbackDialog({
    super.key,
    required this.solved,
    required this.theoryRef,
    this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(solved ? '¡Correcto!' : 'Inténtalo de nuevo'),
      content: Text(
        solved
            ? 'Has superado el reto.'
            : theoryRef ?? 'La solución todavía no es correcta.',
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();

            if (onContinue != null) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                onContinue!();
              });
            }
          },
          child: Text(solved ? 'Continuar' : 'Cerrar'),
        ),
      ],
    );
  }
}
