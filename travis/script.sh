#!/bin/bash
# See: https://docs.travis-ci.com/user/job-lifecycle#complex-build-commands
set -evx
if [ "${TRAVIS_PULL_REQUEST}" = "false" ]; then
  ./gantry --version
  ./gantry deploy --region nyc1 routinator vr-sros:16.0.R6 vr-vmx:18.2R1.9
  ./gantry status
  ./gantry --data-dir tests test all
fi
