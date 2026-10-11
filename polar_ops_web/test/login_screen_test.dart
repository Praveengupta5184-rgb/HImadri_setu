import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:polar_ops_web/screens/auth/login_screen.dart';
import 'package:polar_ops_web/screens/auth/widgets/mission_control_header.dart';
import 'package:polar_ops_web/screens/auth/widgets/judge_demo_section.dart';

void main() {
  testWidgets('MissionControlHeader renders SIH 2026 and POLAR-OPS branding',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: MissionControlHeader(),
        ),
      ),
    );

    expect(find.textContaining('SIH 2026'), findsOneWidget);
    expect(find.textContaining('POLAR'), findsOneWidget);
    expect(find.textContaining('MoES • NCPOR'), findsOneWidget);
  });

  testWidgets('JudgeDemoSection displays demo credentials and fills on tap',
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

    final fillBtn = find.text('Fill Demo Credentials');
    expect(fillBtn, findsOneWidget);

    await tester.tap(fillBtn);
    await tester.pump();

    expect(filledEmail, JudgeDemoSection.demoEmail);
    expect(filledPassword, JudgeDemoSection.demoPassword);
  });

  testWidgets('LoginScreen builds with email and passcode fields',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: LoginScreen(),
      ),
    );

    // Initial frame
    await tester.pump();

    expect(find.text('Mission Command Access'), findsOneWidget);
    expect(find.text('Sign In to Mission Control'), findsOneWidget);
    expect(find.text('JUDGE DEMO ACCESS'), findsOneWidget);
  });
}
