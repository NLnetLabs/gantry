#!/bin/bash
# See: https://docs.travis-ci.com/user/job-lifecycle#complex-build-commands
set -evx
if [ "${TRAVIS_PULL_REQUEST}" = "false" ]; then
  COMPONENTS_TO_TEST="routinator vr-sros:16.0.R6 vr-vmx:18.2R1.9"

  ./gantry --version

  # Don't abort on deployment failure, run whatever tests we can e.g. if one
  # router fails to deploy but others succeed.
  ./gantry deploy --region nyc1 ${COMPONENTS_TO_TEST} || true

  # Dump the deployment status so the subsequent test results can be understood
  # in the context of which components succeeded or failed to deploy.
  ./gantry status

  # Run the tests. On failure dump logs to enable root cause analysis.
  if ! ./gantry --data-dir tests test all; then
    for C in ${COMPONENTS_TO_TEST}; do
        echo "LOGS FOR GANTRY COMPONENT: ${C}: START"
        ./gantry logs $C || true
        echo "LOGS FOR GANTRY COMPONENT: ${C}: END"
    done
    exit 1
  fi
fi
