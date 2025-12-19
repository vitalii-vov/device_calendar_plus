import 'package:device_calendar_plus_platform_interface/device_calendar_plus_platform_interface.dart';

/// Android-specific options for creating a calendar.
///
/// Use this class to specify the account name for the calendar on Android.
/// The calendar will be created under the local account type with the
/// specified account name.
///
/// Example:
/// ```dart
/// await plugin.createCalendar(
///   name: 'My Calendar',
///   platformOptions: CreateCalendarOptionsAndroid(accountName: 'MyApp'),
/// );
/// ```
class CreateCalendarOptionsAndroid extends CreateCalendarPlatformOptions {
  /// The account name for the local calendar.
  ///
  /// Calendars with the same account name will be grouped together
  /// in the device's calendar app.
  /// Defaults to "local" if not specified via platform options.
  final String accountName;

  /// Creates Android-specific calendar creation options.
  ///
  /// [accountName] is the account name for the local calendar.
  const CreateCalendarOptionsAndroid({
    required this.accountName,
  });
}
