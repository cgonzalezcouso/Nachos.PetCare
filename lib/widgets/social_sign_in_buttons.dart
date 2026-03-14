import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:nachos_pet_care_flutter/providers/auth_provider.dart';

class SocialSignInButtons extends StatelessWidget {
  const SocialSignInButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        return Column(
          children: [
            Text(
              'o continúa con',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
            ),
            const SizedBox(height: 16),

            // Google
            _SocialButton(
              onPressed: auth.isLoading
                  ? null
                  : () async {
                      final success = await auth.signInWithGoogle();
                      if (success && context.mounted) {
                        context.go('/home');
                      }
                    },
              icon: _GoogleIcon(),
              label: 'Continuar con Google',
            ),
            const SizedBox(height: 12),

            // Microsoft
            _SocialButton(
              onPressed: auth.isLoading
                  ? null
                  : () async {
                      final success = await auth.signInWithMicrosoft();
                      if (success && context.mounted) {
                        context.go('/home');
                      }
                    },
              icon: _MicrosoftIcon(),
              label: 'Continuar con Microsoft',
            ),
          ],
        );
      },
    );
  }
}

class _SocialButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final Widget icon;
  final String label;

  const _SocialButton({
    required this.onPressed,
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: onPressed,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            icon,
            const SizedBox(width: 12),
            Text(label),
          ],
        ),
      ),
    );
  }
}

class _GoogleIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 20,
      height: 20,
      child: CustomPaint(
        painter: _GoogleLogoPainter(),
      ),
    );
  }
}

class _GoogleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;

    // Blue
    paint.color = const Color(0xFF4285F4);
    canvas.drawArc(
      Rect.fromLTWH(0, 0, size.width, size.height),
      -0.5,
      1.5,
      true,
      paint,
    );

    // Green
    paint.color = const Color(0xFF34A853);
    canvas.drawArc(
      Rect.fromLTWH(0, 0, size.width, size.height),
      1.0,
      1.0,
      true,
      paint,
    );

    // Yellow
    paint.color = const Color(0xFFFBBC05);
    canvas.drawArc(
      Rect.fromLTWH(0, 0, size.width, size.height),
      2.0,
      1.0,
      true,
      paint,
    );

    // Red
    paint.color = const Color(0xFFEA4335);
    canvas.drawArc(
      Rect.fromLTWH(0, 0, size.width, size.height),
      3.0,
      1.0,
      true,
      paint,
    );

    // White center
    paint.color = Colors.white;
    canvas.drawCircle(
      Offset(size.width / 2, size.height / 2),
      size.width / 3,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}


class _MicrosoftIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 20,
      height: 20,
      child: CustomPaint(
        painter: _MicrosoftLogoPainter(),
      ),
    );
  }
}

class _MicrosoftLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    final double gap = size.width * 0.05; // 5% gap
    final double sizeBox = (size.width - gap) / 2;

    // Red (Top-Left)
    paint.color = const Color(0xFFF25022);
    canvas.drawRect(Rect.fromLTWH(0, 0, sizeBox, sizeBox), paint);

    // Green (Top-Right)
    paint.color = const Color(0xFF7FBA00);
    canvas.drawRect(Rect.fromLTWH(sizeBox + gap, 0, sizeBox, sizeBox), paint);

    // Blue (Bottom-Left)
    paint.color = const Color(0xFF00A4EF);
    canvas.drawRect(Rect.fromLTWH(0, sizeBox + gap, sizeBox, sizeBox), paint);

    // Yellow (Bottom-Right)
    paint.color = const Color(0xFFFFB900);
    canvas.drawRect(Rect.fromLTWH(sizeBox + gap, sizeBox + gap, sizeBox, sizeBox), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
