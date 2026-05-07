import 'package:flutter/material.dart';

class FeedbackDialog extends StatelessWidget {
  final bool solved;
  final String? theoryRef;
  final VoidCallback? onContinue;

  const FeedbackDialog({
    super.key,
    required this.solved,
    this.theoryRef,
    this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(solved ? '¡Reto superado!' : 'Aún no está correcto'),
      content: Text(
        solved
            ? 'Buen trabajo. Puedes continuar con el siguiente reto.'
            : 'Revisa la estructura e inténtalo de nuevo.'
                  '${theoryRef == null ? '' : '\n\nAyuda: $theoryRef'}',
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            onContinue?.call();
          },
          child: Text(solved ? 'Continuar' : 'Cerrar'),
        ),
      ],
    );
  }
}
