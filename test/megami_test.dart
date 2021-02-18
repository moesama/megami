import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:megami/megami.dart';

void main() {
  const MethodChannel channel = MethodChannel('megami');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
    expect(await Megami.platformVersion, '42');
  });
}
