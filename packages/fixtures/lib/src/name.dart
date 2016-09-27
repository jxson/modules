// Copyright 2016 The Fuchsia Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:uuid/uuid.dart';

class Name {
  static String baseurl = 'name.fuchsia.community';

  static String generate() {
    // TODO: pull from a random list.
    return '';
  }

  // Generate a v5 (namespace-name-sha1-based) id
  // uuid.v5(Uuid.NAMESPACE_URL, 'www.google.com'); // -> 'c74a196f-f19d-5ea9-bffd-a2742432fc9c'
  static Set<Uuid> _generated = new Set<Uuid>();
  // TODO generate this from a list of random names.
  static String _generate() => 'foo';

  // Note: base uuid on string buffer from generated name.
  static Uuid uuid(String value) {
    return uuid.v5(Uuid.NAMESPACE_URL, baseurl);
  }

  String _value;

  Uuid get uuid => _uuid;
  Uuid get id => _uuid;

  // get value => _value;
  // get uri => _uri;

  factory Name() {
    value = _generate();
    Uuid uuid = uuid(value);

    // if (_cache.containsKey(name)) {
    //   return _cache[name];
    // } else {
    //   final symbol = new Symbol._internal(name);
    //   _cache[name] = symbol;
    //   return symbol;
    // }

    while (!_generated.contains(uuid)) {
      value =
    }

    // Uri encoded = Uri.encodeFull(name);
    // String uuid;

    // uuid.v5(Uuid.NAMESPACE_URL, ''); // ->
    // 'c74a196f-f19d-5ea9-bffd-a2742432fc9c'

    // while uuid exisits for baseurl + urlencoded(_value);

    // _uuid = uuid.v5(Uuid.NAMESPACE_URL, uri)

  }

  String toString() {
    return _value;
  }


  String _uri() {
    return '${baseurl}/${uuid}';
  }
}
