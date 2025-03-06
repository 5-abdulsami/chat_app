import 'package:flutter/material.dart';

class DateUtil {
  // for formatting time from milliSecondsSinceEpochs String
  static String getFormattedTime(
      {required BuildContext context, required String time}) {
    final DateTime date = DateTime.fromMillisecondsSinceEpoch(int.parse(time));
    return TimeOfDay.fromDateTime(date).format(context);
  }

  // for last seen and sent time
  static String getMessageTime(
      {required BuildContext context, required String time}) {
    final DateTime sent = DateTime.fromMillisecondsSinceEpoch(int.parse(time));
    final DateTime now = DateTime.now();

    final formattedTime = TimeOfDay.fromDateTime(sent).format(context);
    if (now.day == sent.day &&
        now.month == sent.month &&
        now.year == sent.year) {
      return formattedTime;
    }

    return now.year == sent.year
        ? '$formattedTime - ${sent.day} ${_getMonthName(sent.month)}'
        : '$formattedTime - ${sent.day} ${_getMonthName(sent.month)} ${sent.year}';
  }

  static String getLastMessageTime(
      {required BuildContext context,
      required String time,
      bool showYear = false}) {
    final DateTime sentTime =
        DateTime.fromMillisecondsSinceEpoch(int.parse(time));
    final DateTime now = DateTime.now();

    if (now.day == sentTime.day &&
        now.month == sentTime.month &&
        now.year == sentTime.year) {
      return TimeOfDay.fromDateTime(sentTime).format(context);
    }

    return showYear
        ? '${sentTime.day} ${_getMonthName(sentTime.month)} ${sentTime.year}'
        : '${sentTime.day} ${_getMonthName(sentTime.month)}';
  }

  static String getLastActiveTime(
      {required BuildContext context, required String time}) {
    final int i = int.tryParse(time) ?? -1;
    if (i == -1) return 'Last Active not available';
    final DateTime lastActiveTime = DateTime.fromMillisecondsSinceEpoch(i);
    final DateTime now = DateTime.now();

    String formattedTime =
        TimeOfDay.fromDateTime(lastActiveTime).format(context);

    if (now.day == lastActiveTime.day &&
        now.month == lastActiveTime.month &&
        now.year == lastActiveTime.year) {
      return 'Last seen today at $formattedTime';
    }

    if ((now.difference(lastActiveTime).inHours / 24).round() == 1) {
      return 'Last seen yesterday at $formattedTime';
    }

    String month = _getMonthName(lastActiveTime.month);
    return 'Last seen on ${lastActiveTime.day} $month at $formattedTime';
  }

  static String _getMonthName(int month) {
    switch (month) {
      case 1:
        return 'Jan';
      case 2:
        return 'Feb';
      case 3:
        return 'Mar';
      case 4:
        return 'Apr';
      case 5:
        return 'May';
      case 6:
        return 'Jun';
      case 7:
        return 'Jul';
      case 8:
        return 'Aug';
      case 9:
        return 'Sep';
      case 10:
        return 'Oct';
      case 11:
        return 'Nov';
      case 12:
        return 'Dec';
      default:
        return '';
    }
  }
}
