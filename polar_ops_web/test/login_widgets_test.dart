import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:polar_ops_web/screens/auth/widgets/mission_control_header.dart';
import 'package:polar_ops_web/screens/auth/widgets/judge_demo_section.dart';
import 'package:polar_ops_web/screens/auth/widgets/snowfall_particles.dart';

void main() {
  testWidgets('MissionControlHeader displays SIH 2026 and POLAR-OPS',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: MissionControlHeader(),
        ),
      ),
    );

    expect(find.textContaining('SIH 2026'), findsOneWidget);
    expect(find.textContaining('MoES • NCPOR'), findsOneWidget);
    expect(find.textContaining('Integrated Polar Expedition'), findsOneWidget);
    expect(
      find.byWidgetPredicate(
        (w) => w is RichText && w.text.toPlainText().contains('POLAR-OPS'),
      ),
      findsOneWidget,
    );
  });

  testWidgets('JudgeDemoSection displays credentials and fill callback',
      (WidgetTester tester) async {
    String filledEmail = '';
    String filledPassword = '';

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: JudgeDemoSection(
            onFillCredentials: (email, pass) {
              filledEmail = email;
              filledPassword = pass;
            },
          ),
        ),
      ),
    );

    expect(find.text('JUDGE DEMO ACCESS'), findsOneWidget);
    expect(find.text(JudgeDemoSection.demoEmail), findsOneWidget);

    final fillBtn = find.text('1-Click Fill Demo Credentials');
    expect(fillBtn, findsOneWidget);

    await tester.tap(fillBtn);
    await tester.pump();

    expect(filledEmail, JudgeDemoSection.demoEmail);
    expect(filledPassword, JudgeDemoSection.demoPassword);
  });

  testWidgets('SnowfallParticles renders smoothly',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: SnowfallParticles(numberOfSnowflakes: 10),
        ),
      ),
    );

    expect(find.byType(SnowfallParticles), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.byType(SnowfallParticles), findsOneWidget);
  });
}
