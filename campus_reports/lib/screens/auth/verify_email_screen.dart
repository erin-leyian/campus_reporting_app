import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/auth_provider.dart';

class VerifyEmailScreen extends StatelessWidget {
  const VerifyEmailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.mark_email_unread_outlined, size: 64),
            const SizedBox(height: 16),
            Text(
              'Verify your email',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'We sent a link to ${auth.user?.email}. Open it, then tap the button below.',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton(
              onPressed: () async {
                await context.read<AuthProvider>().checkVerified();
                if (context.mounted &&
                    !context.read<AuthProvider>().isVerified) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Not verified yet. Check your inbox.'),
                    ),
                  );
                }
              },
              child: const Text("I've verified my email"),
            ),
            TextButton(
              onPressed: () =>
                  context.read<AuthProvider>().resendVerification(),
              child: const Text('Resend email'),
            ),
            TextButton(
              onPressed: () => context.read<AuthProvider>().logout(),
              child: const Text('Use a different account'),
            ),
          ],
        ),
      ),
    );
  }
}
