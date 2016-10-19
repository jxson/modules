// Copyright 2016 The Fuchsia Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:async';

import 'package:services/secure_store.mojom.dart';
import 'package:util/local_storage.dart';

/// The default [SecureStoreWrapper] instance that other packages can use.
final SecureStoreWrapper secureStore =
    new SecureStoreWrapper(new _SecureStoreImpl());

/// A class that wraps [SecureStore] to provide [Future]-based get method.
class SecureStoreWrapper {
  final SecureStore _secureStore;

  /// Creates a new instance of [SecureStoreWrapper] with the given
  /// [SecureStore] instance. The [SecureStore] instance must not be null.
  SecureStoreWrapper(this._secureStore) {
    assert(_secureStore != null);
  }

  /// Gets the value for the given key. The returned string can be null, if the
  /// value is not set for the given key.
  Future<String> get(String key) {
    Completer<String> completer = new Completer<String>();
    _secureStore.get(key, (String value) {
      completer.complete(value);
    });
    return completer.future;
  }

  /// Sets the value for the given key.
  ///
  /// This method returns immediately, and does not wait until the put operation
  /// is finished.
  void put(String key, String value) {
    _secureStore.put(key, value);
  }

  /// Removes the key and its associated value from the secure store. When the
  /// key does not exist in the store, then this is a no-op.
  ///
  /// This method returns immediately, and does not wait until the remove
  /// operation is finished.
  void remove(String key) {
    _secureStore.remove(key);
  }
}

/// A fake [SecureStore] implementation that uses the [LocalStorage] class as
/// the data persistence mechanism. A real [SecureStore] implementation should
/// ideally be obtained from the Mojo layer in the future.
class _SecureStoreImpl implements SecureStore {
  final LocalStorage _localStorage = new LocalStorage('secure_store.json');

  @override
  void get(String key, void callback(String value)) {
    _localStorage.get(key).then((String value) {
      callback(value);
    });
  }

  @override
  void put(String key, String value) {
    _localStorage.put(key, value);
  }

  @override
  void remove(String key) {
    _localStorage.remove(key);
  }
}
