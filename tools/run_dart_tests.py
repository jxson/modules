#!/usr/bin/env python
# Copyright 2017 The Fuchsia Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

# NOTE(youngseokyoon): Currently, the dart tests are run using `flutter test`
# from the command line, instead of using any GN build targets. Therefore, this
# script is specific to the modules repo and cannot be used more generically.
# Once dart_test GN target becomes more functional, this script should be more
# generalized and moved to $FUCHSIA_DIR/scripts directory so that other projects
# can run dart tests more easily.

import argparse
import fnmatch
import glob
import multiprocessing
import os
import Queue
import subprocess
import sys
import threading

REPO_ROOT = os.path.dirname(sys.path[0])
FUCHSIA_ROOT = os.path.dirname(os.path.dirname(REPO_ROOT))


class WorkerThread(threading.Thread):
    '''
    A worker thread to run tests from a queue and return exit codes and output on a queue.
    '''

    def __init__(self, package_queue, result_queue, args):
        threading.Thread.__init__(self)
        self.package_queue = package_queue
        self.result_queue = result_queue
        self.args = args

    def run(self):
        while True:
            try:
                package = self.package_queue.get(False)
            except Queue.Empty, e:
                # no more packages
                return
            # Backup '.packages' file if it is a symlink.
            # Otherwise, 'flutter test' may inadvertently overwrite the contents
            # of the original '.packages' file that the symlink points to.
            backup = False
            if os.path.islink(package + '/.packages'):
                os.rename(package + '/.packages', package + '/.packages.bak')
                backup = True
            job = subprocess.Popen(
                [FUCHSIA_ROOT + '/lib/flutter/bin/flutter', 'test'] +
                self.args,
                cwd=package,
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE)
            stdout, stderr = job.communicate()
            output = stdout + stderr
            self.result_queue.put((package, job.returncode, output))
            # Restore the '.packages' symlink if it was backed up before.
            if backup:
                os.rename(package + '/.packages.bak', package + '/.packages')


def main():
    parser = argparse.ArgumentParser('''Run Dart tests in parallel.
Extra flags will be passed to the flutter test command.
''')
    args, extras = parser.parse_known_args()

    # Find all the dart packages.
    dart_packages = []
    for root, dirnames, filenames in os.walk(REPO_ROOT):
        for filename in fnmatch.filter(filenames, '.packages'):
            dart_packages.append(root)
    # Add all the dart package directories.
    target_packages = []
    for dart_package in dart_packages:
        if os.path.basename(dart_package) == 'test':
            continue
        elif os.path.isdir(dart_package + '/test'):
            target_packages.append(dart_package)
        else:
            print "** WARNING: No tests found in '%s'." % os.path.relpath(
                dart_package, REPO_ROOT)

    # Put all the target packages in a queue that workers will work from
    package_queue = Queue.Queue()
    for package in target_packages:
        package_queue.put(package)
    # Make a queue to receive results from workers.
    result_queue = Queue.Queue()
    # Track return codes from the tests.
    test_results = []
    failed_tests = []

    # Create a worker thread for each CPU on the machine.
    num_threads = multiprocessing.cpu_count()
    for i in range(num_threads):
        WorkerThread(package_queue, result_queue, extras).start()

    # Handle results from workers.
    while len(test_results) < len(target_packages):
        package, returncode, output = result_queue.get(True)
        test_results.append(returncode)
        if returncode != 0:
            failed_tests.append(package)
        print '----------------------------------------------------------'
        print "Test results of package '%s'\n" % os.path.relpath(package,
                                                                 REPO_ROOT)
        print output

    if len(failed_tests):
        failed_tests.sort()
        print 'Tests failed in:'
        for package in failed_tests:
            print '  %s' % os.path.relpath(package, REPO_ROOT)
        exit(1)


if __name__ == '__main__':
    sys.exit(main())
