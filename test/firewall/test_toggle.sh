#!/usr/bin/env bash

set -e

source dev-container-features-test-lib

# Check that the firewall toggle script is installed
check "firewall script exists" test -f /usr/local/bin/firewall
check "firewall script is executable" test -x /usr/local/bin/firewall

# Firewall is already initialized by postStartCommand, verify it's active
check "firewall DROP policy is set" bash -c 'sudo iptables -L OUTPUT | grep -q "policy DROP"'

# Verify blocked traffic
check "example.com is blocked" bash -c '! curl --connect-timeout 5 -sf https://example.com'

# Disable firewall
check "firewall off succeeds" sudo firewall off

# Verify firewall is disabled
check "firewall ACCEPT policy is set" bash -c 'sudo iptables -L OUTPUT | grep -q "policy ACCEPT"'

# Verify traffic is now allowed
check "example.com is reachable" curl --connect-timeout 10 -sf https://example.com

# Re-enable firewall
check "firewall on succeeds" sudo firewall on

# Verify firewall is re-enabled
check "firewall DROP policy restored" bash -c 'sudo iptables -L OUTPUT | grep -q "policy DROP"'

# Verify blocked traffic again
check "example.com is blocked again" bash -c '! curl --connect-timeout 5 -sf https://example.com'

reportResults
