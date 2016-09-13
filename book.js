// Copyright 2016 The Fuchsia Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

var exec = require('child_process').execSync;
var command = 'git rev-parse --short HEAD';

module.exports = {
  "root": "./doc",
  "gitbook": "3.1.1",
  "plugins": [ "theme-official@2.1.1" ],
  "variables": {
    "version": version()
  }
}

function version() {
  var buffer = exec(command);
  return buffer.toString();
}
