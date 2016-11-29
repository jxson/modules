// Copyright 2016 The Fuchsia Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:math';

import 'package:models/email.dart';
import 'package:models/user.dart';
import 'package:uuid/uuid.dart';

import 'name.dart';
import 'namespace.dart';
import 'sequence.dart';

final Uuid _uuid = new Uuid();

/// The operation was not allowed by the current state of the [Fixtures]
/// instance.
class FixturesError extends StateError {
  /// Create a [FixturesError].
  ///
  ///     FixturesError err = new FixturesError('Something bad happened');
  ///
  FixturesError(String msg) : super(msg);
}

/// Defines generators for objects to be used in UI mocks and tests.
///
/// Generators are, and should be defined as methods of [Fixtures] and return
/// instances of objects that attempt to be random and unique. Uniqueness is
/// only guaranteed up to the set uniqueness [nameThreshold].
///
/// The objects returned from [Fixtures] methods are not Stubs, or Mocks. They
/// are actual instances of their return types.
class Fixtures {
  final Set<String> _names = new Set<String>();
  final Map<String, Sequence> _sequences = new Map<String, Sequence>();
  final Random _rng = new Random();
  static final String _uuidUser =
      _uuid.v5(Uuid.NAMESPACE_URL, namespace('users'));

  /// Uniqueness [nameThreshold].
  ///
  /// Generators like [name] use the [nameThreshold] to limit the total unique
  /// values they produce. When the threshold is reached a [FixturesError]
  /// will be thrown.
  final int nameThreshold;

  /// Create an instance of [Fixtures].
  ///
  ///     Fixtures fixtures = new Fixtures();
  ///
  /// If you need a higher set of unique values from generators (like
  /// [name]) over the default [nameThreshold] it can be optionally set:
  ///
  ///     Fixtures fixtures = new Fixtures(threshold: 5000);
  ///
  Fixtures({this.nameThreshold: 1000});

  /// Retrieve a namespaced [Sequence] value.
  ///
  /// The [int] [Sequence] value returned for the namespace key will be
  /// sequentially increased by one on every call.
  ///
  /// The first time a sequence is called it will return an `int` value of
  ///  `1`.
  ///
  ///     // The sequence value will equal `1`.
  ///     int sequence = fixtures._sequence('email');
  ///
  /// Subsequent calls will return a value that is incremented above the
  /// previously returned value.
  ///
  ///     // The sequence value will equal `2`.
  ///     int sequence = fixtures._sequence('email');
  ///
  int _sequence(String key) {
    _sequences[key] ??= new Sequence();
    return _sequences[key].value;
  }

  /// Generate a name.
  ///
  /// When called without the optional value, a new random [String] name will
  /// be returned with a [String] value like 'Brenda Wade'.
  ///
  ///     String name = fixtures.name();
  ///
  /// [Fixtures] instances track subsequent calls to [name] to guarantee
  /// unique random [Name] values, even against ones that have an explicitly
  /// set value. Additional calls for explicit names will not be counted
  /// against the [nameThreshold] after the first time.
  ///
  /// Track a [String] name with the value 'Jason Campbell'.
  ///
  ///     String jason = fixtures.name('Jason Campbell');
  ///
  /// Generate a random name. The random name will never have the value 'Jason
  /// Campbell'.
  ///
  ///     String name = fixtures.name();
  ///
  /// Throws [FixturesError] if the [nameThreshold] for unique names is met.
  String name([String value]) {
    if (_names.contains(value)) {
      return value;
    }

    if (_names.length == nameThreshold) {
      String message = 'Threshold for Names exceeded, $nameThreshold unique'
          'names have been generated.';
      throw new FixturesError(message);
    }

    if (value != null) {
      _names.add(value);
    } else {
      value = Name.generate();

      while (!_names.add(value)) {
        value = Name.generate();
      }
    }

    return value;
  }

  /// Generate a [User].
  ///
  /// Generate a random [User]:
  ///
  ///     User user = fixtures.user();
  ///
  /// Generate a [User] with a specific name:
  ///
  ///     User user = fixtures.user(name: 'Alice');
  ///
  User user({String name, String email}) {
    name ??= this.name(name);
    email ??= 'user-${_sequence(email)}@example.org';

    String id = _uuid.v5(_uuidUser, email);
    return new User(
      id: id,
      name: name,
      email: email,
      locale: 'en',
    );
  }

  /// Me.
  User me() {
    return user(
      name: 'Aparna Nielsen',
      email: 'aparna@example.org',
    );
  }

  /// Genrate a random [int] no greater than [max].
  int number([int max]) {
    return _rng.nextInt(max);
  }

  /// Create a random [Label].
  Label label({
    String id,
    String name,
    int unread,
    String type,
  }) {
    return new Label(
      id: id ?? 'INBOX',
      name: name ?? 'Inbox',
      unread: unread ?? number(800),
      type: type ?? 'system',
    );
  }

  /// Create a [List] of [Label] objects for use in testing and demos.
  List<Label> labels() {
    return <Label>[
      new Label(
        id: 'INBOX',
        name: 'Inbox',
        unread: number(20),
        type: 'system',
      ),
      new Label(
        id: 'STARRED',
        name: 'Starred',
        unread: number(100),
        type: 'system',
      ),
      new Label(
        id: 'DRAFT',
        name: 'Drafts',
        unread: number(5),
        type: 'system',
      ),
      new Label(
        id: 'TRASH',
        name: 'Trash',
        unread: number(200),
        type: 'system',
      ),
    ];
  }

  /// Generate [Attachment] objects.
  Attachment attachment({
    String id,
    AttachmentType type,
    String value,
  }) {
    switch (type) {
      case AttachmentType.youtubeVideo:
        value ??= '0pfUC55a3Jc';
        break;
      case AttachmentType.uspsShipping:
        value ??= '9374889676090175041871';
        break;
      case AttachmentType.orderReceipt:
        value ??= 'order-123';
        break;
    }

    return new Attachment(
      id: id ?? this.id('attachment'),
      value: value ?? 'example-value',
      type: type ?? AttachmentType.youtubeVideo,
    );
  }

  /// Generate a [Message].
  Message message({
    User sender,
    String subject,
    String text,
    bool isRead,
    List<User> to,
    List<User> cc,
    DateTime timestamp,
    List<Attachment> attachments,
  }) {
    sender ??= user();

    if (to == null || to.isEmpty) {
      to = <User>[user()];
    }

    return new Message(
      id: id('message'),
      sender: new Mailbox(
        address: sender.email,
        displayName: sender.name,
      ),
      senderProfileUrl: null,
      recipientList: to?.map((User recipient) => recipient.mailbox)?.toList(),
      ccList: cc?.map((User recipient) => recipient.mailbox)?.toList(),
      subject: subject,
      text: text,
      timestamp: timestamp ?? new DateTime.now(),
      isRead: isRead ?? false,
      attachments: attachments,
    );
  }

  /// Generate a [Thread].
  Thread thread([List<Message> messages]) {
    // TODO(jasoncampbell): randomize the number of messages once content can
    // be generated.
    messages ??= <Message>[
      message(),
    ];

    return new Thread(
      id: id('thread'),
      historyId: id('history'),
      snippet: 'Example snippet',
      messages: messages,
    );
  }

  /// TODO(jasoncampbell): document this.
  List<Thread> threads({
    String labelId: 'INBOX',
  }) {
    List<Thread> results;

    switch (labelId) {
      case 'INBOX':
        results = _inbox();
        break;
      default:
        results = <Thread>[];
    }

    return results;
  }

  List<Thread> _inbox() {
    User me = this.me();
    User dad = user(name: 'Ian Nielsen');
    User store = user(
      name: 'Bedford Mobile Outlet',
      email: 'store@example.org',
    );

    return <Thread>[
      thread(<Message>[
        message(
            sender: store,
            to: <User>[me],
            timestamp: DateTime.parse('2016-11-29T18:14-0600'),
            subject: 'Your order from Bedford Mobile',
            text: 'http://www.aplusmobile.com/yourorder',
            isRead: false,
            attachments: <Attachment>[
              attachment(
                type: AttachmentType.orderReceipt,
              ),
            ]),
        message(
          sender: store,
          to: <User>[me],
          timestamp: DateTime.parse('2016-11-29T19:14-0600'),
          subject: 'Your order from Bedford Mobile Outlet is on its way! ',
          text: '''Hello Aparna Nielsen,

We’re writing to inform you that your order (#S000242323) has recently shipped!

If you would like to track the progress of your package, please visit the USPS website:

https://tools.usps.com/go/TrackConfirmAction?qtc_tLabels1=9341989676090046890941

Thank you very much,
Sam Lefferts
Bedford Mobile Outlet
          ''',
          attachments: <Attachment>[
            attachment(
              value: '9341989676090046890941',
              type: AttachmentType.uspsShipping,
            ),
          ],
        ),
      ]),
      thread(<Message>[
        message(
          sender: me,
          to: <User>[dad],
          timestamp: DateTime.parse('2016-11-28T22:57:00-0600'),
          subject: 'India trip planning',
          text: '''Hey Dad,


Can you send over the doc that has Nani's birthday plans? Just want to make sure I have the dates right!


Love, Aparna
          ''',
        ),
        message(
          sender: dad,
          to: <User>[me],
          timestamp: DateTime.parse('2016-11-29T01:12:00-0600'),
          subject: 're: India trip planning',
          text: '''Hi pumpkin-

I actually haven't started putting a doc together yet. Maybe we can work on it together later this week.

But the dates are still the same - your mother and I will be leaving from EWR on Sunday 5/14 at 7:00am, so we'll be at Vadodara around Tuesday morning.

And we're planning to depart BDQ on 5/31 at 5:00pm.

-Dad
          ''',
        ),
        message(
          sender: me,
          to: <User>[dad],
          timestamp: DateTime.parse('2016-11-29T03:12:00-0600'),
          subject: 'India trip planning',
          text: '''Ahhh ok. My mistake. :)


Yes, I should be free to work on putting one together after this Thursday!

          ''',
        ),
        message(
          sender: dad,
          to: <User>[me],
          timestamp: DateTime.parse('2016-11-29T16:31:00-0600'),
          subject: 're: India trip planning',
          text:
              '''Great, I'll give you a call once I can dig up all my files. Lots of old itineraries lying around that we never quite got around to.


By the way, do you have enough suitcases for your stuff? Your mother and I have a couple extra.

          ''',
        ),
        message(
          sender: me,
          to: <User>[dad],
          timestamp: DateTime.parse('2016-11-29T17:35:00-0600'),
          subject: 're: India trip planning',
          text:
              '''I'll be getting some new luggage delivered, so I should be ready. Do you have my immunization history available by chance? I think it's over in the top drawer of my old dresser.


By the way, I came across this awesome video. Maybe we can do this on a future trip. :)
https://www.youtube.com/watch?v=KbtZfzxX44o


-Aparna
          ''',
          attachments: <Attachment>[
            attachment(
              value: 'KbtZfzxX44o',
              type: AttachmentType.youtubeVideo,
            ),
          ],
        ),
      ]),
    ];
  }

  /// Generates sequenced String ids based on key.
  ///
  ///     // The id value will be 'foo-1'
  ///     String id = fixtures.id('foo');
  ///
  String id(String key) {
    int seq = _sequence(key);
    return '$key-$seq';
  }
}
