// Copyright 2016 The Fuchsia Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

/// [TimeUtil] is a utility class that provides human-readable formating for
/// [DateTime] objects.
class TimeUtil {
  /// Return true if two given [DateTime] objects are within the same day
  ///
  /// Ex: isSameDay(DateTime.parse(1969-07-20 20:18:00), DateTime.parse(1969-07-20 21:18:00)) => True
  ///    isSameDay(DateTime.parse(1969-07-20 20:18:00), DateTime.parse(1969-07-21 21:18:00)) => False
  static bool isSameDay(DateTime time1, DateTime time2) {
    return time1.year == time2.year &&
        time1.month == time2.month &&
        time1.day == time2.day;
  }
}
