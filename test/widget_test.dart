import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:runx/main.dart';
import 'package:runx/core/theme/theme_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    try {
      await Supabase.initialize(
        url: 'https://placeholder.supabase.co',
        anonKey: 'placeholder',
      );
    } catch (e) {
      // Ignore if already initialized
    }
  });

  testWidgets('RunX home screen test', (
    WidgetTester tester,
  ) async {

    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => ThemeProvider(),
        child: RunXApp(supabaseInit: Future.value()),
      ),
    );

    // Initial splash screen
    expect(find.text('RunX'), findsOneWidget);
    
    // Pump some time for splash screen timer
    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
  });
}