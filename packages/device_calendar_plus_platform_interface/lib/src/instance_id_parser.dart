/// Represents the parsed components of an instance ID.
///
/// An instance ID uniquely identifies a specific occurrence of an event:
/// - For non-recurring events: just the event ID
/// - For recurring events: event ID + timestamp of the specific occurrence
class ParsedInstanceId {
  /// The event ID (identifies the event series for recurring events).
  final String eventId;

  /// The timestamp in milliseconds since epoch for recurring event instances.
  /// Null for non-recurring events or when referring to the master event.
  final int? timestamp;

  const ParsedInstanceId({
    required this.eventId,
    this.timestamp,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ParsedInstanceId &&
          runtimeType == other.runtimeType &&
          eventId == other.eventId &&
          timestamp == other.timestamp;

  @override
  int get hashCode => eventId.hashCode ^ timestamp.hashCode;

  @override
  String toString() =>
      'ParsedInstanceId(eventId: $eventId, timestamp: $timestamp)';
}

/// Utility for parsing instance IDs.
///
/// Instance ID format:
/// - Non-recurring events: `"eventId"`
/// - Recurring events: `"eventId@timestamp"`
///
/// Note: Event IDs may contain `@` characters (e.g., Google Calendar IDs
/// like `abc123@google.com`), so parsing must split from the END of the
/// string, not the beginning.
class InstanceIdParser {
  /// Parses an instance ID into its components.
  ///
  /// The instance ID format is:
  /// - `"eventId"` for non-recurring events
  /// - `"eventId@timestamp"` for recurring events (timestamp in milliseconds)
  ///
  /// Since event IDs can contain `@` characters (e.g., Google Calendar IDs
  /// like `abc123@google.com`), this method splits from the END of the string,
  /// checking if the part after the last `@` is a valid numeric timestamp.
  ///
  /// Examples:
  /// - `"12345"` → eventId: `"12345"`, timestamp: null
  /// - `"12345@1766235600000"` → eventId: `"12345"`, timestamp: 1766235600000
  /// - `"abc@google.com"` → eventId: `"abc@google.com"`, timestamp: null
  /// - `"abc@google.com@1766235600000"` → eventId: `"abc@google.com"`, timestamp: 1766235600000
  static ParsedInstanceId parse(String instanceId) {
    // Find the last "@" in the string
    final lastAtIndex = instanceId.lastIndexOf('@');

    if (lastAtIndex == -1) {
      // No "@" found - the entire string is the eventId
      return ParsedInstanceId(eventId: instanceId);
    }

    // Check if the part after the last "@" is a valid timestamp (all digits)
    final afterAt = instanceId.substring(lastAtIndex + 1);
    final timestamp = int.tryParse(afterAt);

    if (timestamp != null) {
      // Valid timestamp found - split here
      final eventId = instanceId.substring(0, lastAtIndex);
      return ParsedInstanceId(eventId: eventId, timestamp: timestamp);
    } else {
      // The part after "@" is not a timestamp (e.g., "@google.com")
      // The entire string is the eventId
      return ParsedInstanceId(eventId: instanceId);
    }
  }
}
