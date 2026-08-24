
#!/bin/bash

set -u

SCRIPT="./python-installer.sh"

PASS=0
FAIL=0


print_test() {
    echo
    echo "========================================"
    echo "TEST: $1"
    echo "========================================"
}


pass() {
    echo "PASS: $1"
    PASS=$((PASS + 1))
}


fail() {
    echo "FAIL: $1"
    FAIL=$((FAIL + 1))
}


# ---------------------------------------------------------
# Check installer exists
# ---------------------------------------------------------

if [[ ! -f "$SCRIPT" ]]; then
    echo "ERROR: $SCRIPT not found."
    exit 1
fi


if [[ ! -x "$SCRIPT" ]]; then
    echo "ERROR: $SCRIPT is not executable."
    echo "Run: chmod +x $SCRIPT"
    exit 1
fi


# ---------------------------------------------------------
# Test 1: Syntax
# ---------------------------------------------------------

print_test "Shell syntax"

if bash -n "$SCRIPT"; then
    pass "Shell syntax is valid."
else
    fail "Shell syntax check failed."
fi


# ---------------------------------------------------------
# Test 2: Package / existing Python
# ---------------------------------------------------------

print_test "Package method - Python 3.12"

output=$("$SCRIPT" --version 3.12 --method package 2>&1)
status=$?

echo "$output"

if [[ $status -eq 0 ]] &&
   echo "$output" | grep -q "python3.12 is already installed"; then

    pass "Package method detected installed Python 3.12."

else

    fail "Package method test failed."

fi


# ---------------------------------------------------------
# Test 3: Auto method
# ---------------------------------------------------------

print_test "Auto method - Python 3.12"

output=$("$SCRIPT" --version 3.12 --method auto 2>&1)
status=$?

echo "$output"

if [[ $status -eq 0 ]] &&
   echo "$output" | grep -q "APT package found"; then

    pass "Auto method selected APT."

else

    fail "Auto method test failed."

fi


# ---------------------------------------------------------
# Test 4: Tarball existing installation
# ---------------------------------------------------------

print_test "Tarball method - existing Python 3.13.7"

SHA256="6c9d80839cfa20024f34d9a6dd31ae2a9cd97ff5e980e969209746037a5153b2"

output=$(
    "$SCRIPT" \
        --version 3.13.7 \
        --method tarball \
        --sha256 "$SHA256" \
        2>&1
)

status=$?

echo "$output"

if [[ $status -eq 0 ]] &&
   echo "$output" | grep -q "Version comparison: SAME" &&
   echo "$output" | grep -q "Nothing to install"; then

    pass "Tarball method correctly detected existing Python 3.13.7."

else

    fail "Tarball existing-installation test failed."

fi


# ---------------------------------------------------------
# Test 5: Invalid Python version
# ---------------------------------------------------------

print_test "Invalid Python version"

output=$(
    "$SCRIPT" \
        --version abc \
        --method package \
        2>&1
)

status=$?

echo "$output"

if [[ $status -ne 0 ]] &&
   echo "$output" | grep -q "Invalid Python version"; then

    pass "Invalid Python version was rejected."

else

    fail "Invalid Python version test failed."

fi


# ---------------------------------------------------------
# Test 6: Invalid method
# ---------------------------------------------------------

print_test "Invalid installation method"

output=$(
    "$SCRIPT" \
        --version 3.12 \
        --method xyz \
        2>&1
)

status=$?

echo "$output"

if [[ $status -ne 0 ]] &&
   echo "$output" | grep -q "Unsupported method"; then

    pass "Invalid installation method was rejected."

else

    fail "Invalid method test failed."

fi


# ---------------------------------------------------------
# Test 7: Help
# ---------------------------------------------------------

print_test "Help option"

output=$("$SCRIPT" --help 2>&1)
status=$?

echo "$output"

# Current installer uses exit 1 for usage/help.
# Therefore we only verify that help text is displayed.

if echo "$output" | grep -q "Python Installer" &&
   echo "$output" | grep -q -- "--version" &&
   echo "$output" | grep -q -- "--method"; then

    pass "Help information is displayed."

else

    fail "Help test failed."

fi


# ---------------------------------------------------------
# Test 8: Log file
# ---------------------------------------------------------

print_test "Log file"

LOG_FILE="$HOME/python-installer/logs/python-installer.log"

if [[ -f "$LOG_FILE" ]]; then

    if grep -q "Python installer started" "$LOG_FILE"; then

        pass "Log file exists and contains installer entries."

    else

        fail "Log file exists but expected entries were not found."

    fi

else

    fail "Log file was not created."

fi


# ---------------------------------------------------------
# Test 9: Installed Python 3.13.7
# ---------------------------------------------------------

print_test "Python 3.13.7 runtime"

if [[ -x /usr/local/bin/python3.13 ]]; then

    version=$(/usr/local/bin/python3.13 --version 2>&1)

    echo "$version"

    if [[ "$version" == "Python 3.13.7" ]]; then

        pass "Python 3.13.7 runtime verified."

    else

        fail "Unexpected Python 3.13 version: $version"

    fi

else

    fail "/usr/local/bin/python3.13 not found."

fi


# ---------------------------------------------------------
# Final summary
# ---------------------------------------------------------

echo
echo "========================================"
echo "TEST SUMMARY"
echo "========================================"

echo "PASSED: $PASS"
echo "FAILED: $FAIL"

echo

if [[ "$FAIL" -eq 0 ]]; then

    echo "ALL TESTS PASSED"
    exit 0

else

    echo "SOME TESTS FAILED"
    exit 1

fi
