# Test Documentation

This directory contains the test documentation and test assets for the Python Installer project.

## Test Structure

```text
tests/
├── README.md
└── test-installations.sh
```

> Keep the test script and its documentation together inside the `tests/` directory.

---

## Test Objective

The purpose of the test suite is to verify that `python-installer.sh` behaves correctly for supported installation methods, validation, idempotency, logging, and runtime verification.

The tests are designed to validate the installer without unnecessarily reinstalling an already-installed Python version.

---

## Test Script

Run the test script from the project root:

```bash
./tests/test-installations.sh
```

If the script is not executable:

```bash
chmod +x tests/test-installations.sh
```

Then:

```bash
./tests/test-installations.sh
```

---

## Test Cases

| ID | Test Case | Expected Result |
|---|---|---|
| TC-01 | Shell syntax validation | Script syntax is valid |
| TC-02 | Package method | Existing/available Python package is detected correctly |
| TC-03 | Auto method with APT | APT is selected when package is available |
| TC-04 | Tarball method with existing installation | Existing target version is detected and no unnecessary rebuild occurs |
| TC-05 | Invalid Python version | Invalid version is rejected |
| TC-06 | Invalid installation method | Unsupported method is rejected |
| TC-07 | Help option | Usage information is displayed |
| TC-08 | Logging | Installer log exists and contains execution entries |
| TC-09 | Python runtime verification | Installed Python version is verified |

---

## TC-01: Shell Syntax

Command:

```bash
bash -n python-installer.sh
```

Expected:

```text
No output
```

A zero exit status means the Bash syntax is valid.

---

## TC-02: Package Method

Command:

```bash
./python-installer.sh     --version 3.12     --method package
```

Expected behavior:

```text
Package python3.12 is available in APT.
python3.12 is already installed.
Installed version: 3.12.3
Nothing to install.
```

The test verifies that the package method detects an existing installation and avoids unnecessary reinstallation.

---

## TC-03: Auto Method

Command:

```bash
./python-installer.sh     --version 3.12     --method auto
```

Expected behavior:

```text
APT package found.
Using package manager.
```

The test verifies that `auto` selects APT when the requested package is available.

---

## TC-04: Tarball Existing Installation

Command:

```bash
./python-installer.sh     --version 3.13.7     --method tarball     --sha256 6c9d80839cfa20024f34d9a6dd31ae2a9cd97ff5e980e969209746037a5153b2
```

Expected behavior:

```text
Existing Python found: 3.13.7
Version comparison: SAME
Python 3.13.7 is already installed.
Nothing to install.
```

This test verifies idempotent behavior for an already-installed tarball version.

---

## TC-05: Invalid Python Version

Command:

```bash
./python-installer.sh     --version abc     --method package
```

Expected behavior:

```text
ERROR: Invalid Python version
```

The command must return a non-zero exit status.

---

## TC-06: Invalid Installation Method

Command:

```bash
./python-installer.sh     --version 3.12     --method xyz
```

Expected behavior:

```text
ERROR: Unsupported method 'xyz'.
```

The command must return a non-zero exit status.

---

## TC-07: Help

Command:

```bash
./python-installer.sh --help
```

Expected output should contain the installer usage information, including:

```text
Python Installer
--version
--method
```

---

## TC-08: Logging

The installer writes execution logs to:

```text
logs/python-installer.log
```

Verify:

```bash
cat logs/python-installer.log
```

The log should contain entries such as:

```text
Python installer started
Target version
Method
Python installer finished successfully
```

---

## TC-09: Runtime Verification

For the source-installed Python version:

```bash
/usr/local/bin/python3.13 --version
```

Expected:

```text
Python 3.13.7
```

Additional verification:

### SSL

```bash
/usr/local/bin/python3.13 -c "import ssl; print('SSL:', ssl.OPENSSL_VERSION)"
```

### SQLite

```bash
/usr/local/bin/python3.13 -c "import sqlite3; print('SQLite:', sqlite3.sqlite_version)"
```

### Core Modules

```bash
/usr/local/bin/python3.13 -c "import bz2, lzma, ctypes, readline; print('Core modules: OK')"
```

---

## SHA256 Verification

The Python 3.13.7 source archive used during validation was checked with:

```bash
echo "6c9d80839cfa20024f34d9a6dd31ae2a9cd97ff5e980e969209746037a5153b2  Python-3.13.7.tgz" | sha256sum -c -
```

Expected:

```text
Python-3.13.7.tgz: OK
```

The installer must reject a tarball when its SHA256 checksum does not match the supplied checksum.

---

## Test Execution Result

A successful test run should finish with:

```text
========================================
TEST SUMMARY
========================================
PASSED: <number>
FAILED: 0

ALL TESTS PASSED
```

### Acceptance Criteria

The test suite is considered successful when:

- [ ] All syntax checks pass
- [ ] Package method behaves correctly
- [ ] Auto method selects APT when available
- [ ] Tarball method handles an existing installation correctly
- [ ] Invalid versions are rejected
- [ ] Invalid methods are rejected
- [ ] Help output is available
- [ ] Logs are generated
- [ ] Installed Python runtime is verified
- [ ] SHA256 verification succeeds for a valid archive
- [ ] SHA256 mismatch is rejected

---

## Test Environment

The validation environment used for this project is:

```text
OS: Ubuntu 24.04 LTS
Python system version: 3.12.3
Source-installed Python: 3.13.7
```

---

## Related Documentation

Detailed installation documentation is available at:

```text
docs/installation.md
```

The main project overview is available at:

```text
README.md
```
