import 'package:device_calendar_plus_platform_interface/device_calendar_plus_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('InstanceIdParser', () {
    group('parse', () {
      test('parses simple event ID without timestamp', () {
        final result = InstanceIdParser.parse('12345');

        expect(result.eventId, equals('12345'));
        expect(result.timestamp, isNull);
      });

      test('parses event ID with timestamp', () {
        final result = InstanceIdParser.parse('12345@1766235600000');

        expect(result.eventId, equals('12345'));
        expect(result.timestamp, equals(1766235600000));
      });

      test('parses Google Calendar ID without timestamp', () {
        // Google Calendar IDs contain @ in the email-like format
        final result = InstanceIdParser.parse('abc123@google.com');

        expect(result.eventId, equals('abc123@google.com'));
        expect(result.timestamp, isNull);
      });

      test('parses Google Calendar ID with timestamp', () {
        // This is the key case that was broken before the fix
        final result =
            InstanceIdParser.parse('abc123@google.com@1766235600000');

        expect(result.eventId, equals('abc123@google.com'));
        expect(result.timestamp, equals(1766235600000));
      });

      test('parses complex event ID with multiple @ and timestamp', () {
        // Even more complex case with UUID-style ID
        final result = InstanceIdParser.parse(
            '81173548-7358-423E-BB81-142A80A6D3EF:s4a38k5bmmiru68741vd92494k@google.com@1766235600000');

        expect(
          result.eventId,
          equals(
              '81173548-7358-423E-BB81-142A80A6D3EF:s4a38k5bmmiru68741vd92494k@google.com'),
        );
        expect(result.timestamp, equals(1766235600000));
      });

      test('parses complex event ID with multiple @ but no timestamp', () {
        final result = InstanceIdParser.parse(
            '81173548-7358-423E-BB81-142A80A6D3EF:s4a38k5bmmiru68741vd92494k@google.com');

        expect(
          result.eventId,
          equals(
              '81173548-7358-423E-BB81-142A80A6D3EF:s4a38k5bmmiru68741vd92494k@google.com'),
        );
        expect(result.timestamp, isNull);
      });

      test('handles event ID ending with @ followed by non-numeric text', () {
        // Edge case: @ followed by something that looks like part of the ID
        final result = InstanceIdParser.parse('event@domain.org');

        expect(result.eventId, equals('event@domain.org'));
        expect(result.timestamp, isNull);
      });

      test('handles empty string', () {
        final result = InstanceIdParser.parse('');

        expect(result.eventId, equals(''));
        expect(result.timestamp, isNull);
      });

      test('handles string with only @', () {
        final result = InstanceIdParser.parse('@');

        expect(result.eventId, equals('@'));
        expect(result.timestamp, isNull);
      });

      test('handles timestamp at the very start after @', () {
        // Edge case: just @timestamp
        final result = InstanceIdParser.parse('@1766235600000');

        expect(result.eventId, equals(''));
        expect(result.timestamp, equals(1766235600000));
      });

      test('handles negative numbers after @ as valid timestamp', () {
        // Negative numbers are technically valid integers, so they parse as timestamps
        // (though pre-1970 dates are rare in practice)
        final result = InstanceIdParser.parse('event@-12345');

        expect(result.eventId, equals('event'));
        expect(result.timestamp, equals(-12345));
      });

      test('handles decimal numbers after @ as non-timestamp', () {
        // Decimals are not valid timestamps
        final result = InstanceIdParser.parse('event@123.456');

        expect(result.eventId, equals('event@123.456'));
        expect(result.timestamp, isNull);
      });

      test('parses very large timestamp correctly', () {
        // Year 3000+ timestamp
        final result = InstanceIdParser.parse('event@32503680000000');

        expect(result.eventId, equals('event'));
        expect(result.timestamp, equals(32503680000000));
      });

      test('parses zero timestamp', () {
        // Unix epoch
        final result = InstanceIdParser.parse('event@0');

        expect(result.eventId, equals('event'));
        expect(result.timestamp, equals(0));
      });
    });

    group('ParsedInstanceId', () {
      test('equality works correctly', () {
        final a = ParsedInstanceId(eventId: 'abc', timestamp: 123);
        final b = ParsedInstanceId(eventId: 'abc', timestamp: 123);
        final c = ParsedInstanceId(eventId: 'abc', timestamp: 456);
        final d = ParsedInstanceId(eventId: 'xyz', timestamp: 123);
        final e = ParsedInstanceId(eventId: 'abc');

        expect(a, equals(b));
        expect(a, isNot(equals(c)));
        expect(a, isNot(equals(d)));
        expect(a, isNot(equals(e)));
      });

      test('toString includes all fields', () {
        final parsed = ParsedInstanceId(eventId: 'test', timestamp: 12345);

        expect(
          parsed.toString(),
          equals('ParsedInstanceId(eventId: test, timestamp: 12345)'),
        );
      });

      test('toString handles null timestamp', () {
        final parsed = ParsedInstanceId(eventId: 'test');

        expect(
          parsed.toString(),
          equals('ParsedInstanceId(eventId: test, timestamp: null)'),
        );
      });
    });
  });
}
