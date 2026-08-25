# Python | Linux | Testing Documentation

---

# Author Table

| **Author** | **Created On** | **Version** | **Last Updated By** | **Last Edited On** | **L0 Reviewer** | **L1 Reviewer** | **L2 Reviewer** |
| ---------- | -------------- | ----------- | ------------------- | ----------------- | --------------- | --------------- | --------------- |
| Vashishtha Prakash | 25-08-2026 | 1.0 | Vashishtha Prakash | 25-08-2026 | — | — | — |

---

# Table of Contents

1. [Introduction](#1-introduction)
2. [What is Python Installer Testing](#2-what-is-python-installer-testing)
3. [Why Testing is Required](#3-why-testing-is-required)
4. [Testing Workflow](#4-testing-workflow)
   - [4.1 Workflow Diagram](#41-workflow-diagram)
5. [Testing Approaches](#5-testing-approaches)
6. [Test Comparison](#6-test-comparison)
7. [Advantages and Disadvantages](#7-advantages-and-disadvantages)
8. [Best Practices](#8-best-practices)
9. [Recommendation / Conclusion](#9-recommendation--conclusion)
10. [Proof of Concept (POC)](#10-proof-of-concept-poc)
11. [Test Environment](#11-test-environment)
12. [Test Prerequisites](#12-test-prerequisites)
13. [How to Run the Test Suite](#13-how-to-run-the-test-suite)
14. [Test Case Matrix](#14-test-case-matrix)
15. [Detailed Test Cases](#15-detailed-test-cases)
16. [SHA256 Verification](#16-sha256-verification)
17. [Runtime Verification](#17-runtime-verification)
18. [Logging Verification](#18-logging-verification)
19. [Test Evidence](#19-test-evidence)
20. [Acceptance Criteria](#20-acceptance-criteria)
21. [Troubleshooting](#21-troubleshooting)
22. [Contact Information](#22-contact-information)
23. [References](#23-references)

---

# 1. Introduction

This document describes the testing strategy for the **SCRUM-11 Python Installation via Bash Script** task.

The objective of the test suite is to verify that the Python installer behaves correctly for valid installation scenarios and rejects invalid inputs safely.

The implementation being tested is:

```text
python-installer.sh
```

The automated test script is:

```text
tests/test-installations.sh
```

The test suite validates:

- 🧪 Bash syntax
- 📦 Package-manager behavior
- 🤖 Automatic installation-method selection
- 📦 Existing Python installation detection
- ♻️ Idempotent behavior
- ❌ Invalid input handling
- ❓ Help output
- 📝 Logging
- 🐍 Runtime verification
- 🔐 Source archive integrity verification

---

# 2. What is Python Installer Testing

Python installer testing is the process of validating the behavior of the Bash-based Python installation utility against expected functional behavior.

The testing model is:

```text
🧪 Test Input
     │
     ▼
python-installer.sh
     │
     ▼
Actual Behavior
     │
 ┌───┴────┐
 ▼        ▼
Output   Exit Status
 └───┬────┘
     ▼
Expected Behavior
     │
 ┌───┴────┐
 ▼        ▼
✅ PASS  ❌ FAIL
```

The test suite is implemented in Bash because the system under test is also a Bash/Linux utility.

---

# 3. Why Testing is Required

The SCRUM-11 requirement specifies support for:

```text
Installation
Multiple Python versions
Upgrades
Tarball
Package Manager
```

Testing is required to verify that the implementation behaves according to these requirements.

The test strategy is derived from the installer's functional areas:

| **Implementation Area** | **Testing Objective** |
| ----------------------- | --------------------- |
| `validate_version()` | Reject invalid Python versions |
| `validate_method()` | Reject unsupported methods |
| `install_from_package()` | Verify package behavior |
| `install_from_tarball()` | Verify source-installation behavior |
| `install_auto()` | Verify automatic method selection |
| `compare_versions()` | Verify version comparison |
| Logging functions | Verify execution traceability |
| Runtime verification | Verify installed Python |

The relationship is:

```text
Requirement
     ↓
Implementation
     ↓
Expected Behavior
     ↓
Test Case
     ↓
Evidence
```

---

# 4. Testing Workflow

```text
┌──────────────────────────────┐
│      Start Test Suite        │
└──────────────┬───────────────┘
               │
               ▼
┌──────────────────────────────┐
│ Locate Installer             │
└──────────────┬───────────────┘
               │
               ▼
┌──────────────────────────────┐
│ Validate Test Environment    │
└──────────────┬───────────────┘
               │
               ▼
┌──────────────────────────────┐
│ Execute Test Case            │
└──────────────┬───────────────┘
               │
               ▼
┌──────────────────────────────┐
│ Capture Output + Exit Status │
└──────────────┬───────────────┘
               │
               ▼
┌──────────────────────────────┐
│ Compare Expected Behavior    │
└──────────────┬───────────────┘
               │
          ┌────┴────┐
          ▼         ▼
        PASS       FAIL
          │         │
          └────┬────┘
               ▼
┌──────────────────────────────┐
│ Generate Test Summary        │
└──────────────────────────────┘
```

## 4.1 Workflow Diagram

<details>
<summary>🔽 Click to Expand Python Installer Testing Workflow</summary>

```text
┌────────────────────────────────────────────────────────────┐
│              test-installations.sh                         │
├────────────────────────────────────────────────────────────┤
│                                                            │
│  1. Locate python-installer.sh                             │
│  2. Validate executable availability                       │
│  3. Execute defined test cases                             │
│  4. Capture output and exit status                         │
│  5. Compare expected behavior                              │
│  6. Count PASS / FAIL                                      │
│  7. Generate final test summary                            │
│                                                            │
└────────────────────────────┬───────────────────────────────┘
                             │
                             ▼
                  ┌───────────────────────┐
                  │     Test Categories   │
                  └──────────┬────────────┘
                             │
          ┌──────────────────┼──────────────────┐
          ▼                  ▼                  ▼
      🟢 Positive        🔴 Negative       🔎 Validation
        Tests               Tests              Tests
          │                  │                  │
          ▼                  ▼                  ▼
       Package         Invalid Version       Syntax
       Auto            Invalid Method        Help
       Existing        Invalid Input         Logs
       Installation                          Runtime
```

</details>

---

# 5. Testing Approaches

| **Approach** | **Description** |
| ------------ | --------------- |
| 🧩 Shell Syntax Testing | Uses `bash -n` to verify Bash syntax. |
| 🧪 Functional Testing | Executes the installer with valid inputs and checks behavior. |
| 🔴 Negative Testing | Verifies invalid input is rejected correctly. |
| ♻️ Idempotency Testing | Verifies existing Python versions are not unnecessarily reinstalled. |
| 🤖 Decision Testing | Verifies automatic selection of APT or tarball. |
| 📝 Log Validation | Verifies execution history is recorded. |
| 🐍 Runtime Testing | Verifies the installed Python executable works. |
| 🔐 Integrity Testing | Verifies SHA256 integrity of source archives. |

---

# 6. Test Comparison

| **Test Type** | **Main Purpose** | **Speed** | **Best Use Case** |
| ------------- | ---------------- | --------- | ----------------- |
| 🧩 Syntax | Detect Bash syntax errors | ⚡ Very Fast | Every code change |
| 🧪 Functional | Validate installer behavior | ⚡ Fast | Regression testing |
| 🔴 Negative | Validate error handling | ⚡ Fast | Invalid input |
| ♻️ Idempotency | Validate repeatability | ⚡ Fast | Repeated execution |
| 🤖 Decision | Validate installation selection | ⚡ Fast | Auto method |
| 📝 Logging | Validate traceability | ⚡ Very Fast | Troubleshooting |
| 🐍 Runtime | Validate installed Python | ⚡ Fast | Post-install verification |
| 🔐 Integrity | Validate source archive | ⚡ Fast | Tarball installation |

---

# 7. Advantages and Disadvantages

| **Advantages** | **Disadvantages** |
| -------------- | ----------------- |
| 🧪 Tests are repeatable | 🛠️ Full source builds take longer |
| ♻️ Existing installations can be tested safely | 🌐 Download-based tests require network access |
| 🔴 Positive and negative cases are covered | 🖥️ Some behavior depends on the environment |
| 📝 Logs provide evidence | 🔐 Installation operations may require `sudo` |
| 🤖 Decision paths can be validated independently | 📦 APT availability can differ between systems |

---

# 8. Best Practices

| **Best Practice** | **Description** |
| ----------------- | --------------- |
| 🧪 Test positive and negative cases | Verify success and failure scenarios. |
| ♻️ Keep tests idempotent | Avoid unnecessary installation or rebuild operations. |
| 🔎 Check exit status | Exit code should be part of validation. |
| 📤 Validate important output | Confirm the expected installer path was selected. |
| 📝 Preserve evidence | Keep useful command output and logs. |
| 🔐 Verify checksums | Validate source archives before build operations. |
| 🔄 Run regression tests after changes | Re-run the suite after meaningful script changes. |
| 📚 Keep documentation aligned | Documentation should reflect the actual implementation and tests. |

---

# 9. Recommendation / Conclusion

The recommended strategy combines:

```text
🧩 Syntax
   +
🧪 Functional
   +
🔴 Negative
   +
♻️ Idempotency
   +
🤖 Decision
   +
🐍 Runtime
   +
📝 Logging
   +
🔐 Integrity
```

This provides coverage of the installer's major behaviors without requiring every test run to rebuild Python.

The test suite should be executed after meaningful modifications to:

```text
python-installer.sh
```

A successful run should end with:

```text
========================================
TEST SUMMARY
========================================
PASSED: <number>
FAILED: 0

ALL TESTS PASSED
```

---

# 10. Proof of Concept (POC)

The testing POC is implemented through:

```text
tests/test-installations.sh
```

The validated development environment contains:

```text
System Python:
Python 3.12.3

Source-installed Python:
Python 3.13.7
```

This provides a basis for validating package-based and source-installed scenarios.

---

# 11. Test Environment

| **Component** | **Value** |
| -------------- | --------- |
| Operating System | Ubuntu 24.04.4 LTS |
| Platform | WSL2 |
| Architecture | x86_64 |
| System Python | Python 3.12.3 |
| Source-installed Python | Python 3.13.7 |
| Package Manager | APT |
| Compiler | GCC 13.3.0 |

---

# 12. Test Prerequisites

### ✅ Installer exists

```bash
ls -l python-installer.sh
```

### ✅ Test script exists

```bash
ls -l tests/test-installations.sh
```

### ✅ Executable permissions

```bash
chmod +x python-installer.sh
chmod +x tests/test-installations.sh
```

### ✅ Bash available

```bash
bash --version
```

### ✅ Runtime available

```bash
/usr/local/bin/python3.13 --version
```

Expected:

```text
Python 3.13.7
```

---

# 13. How to Run the Test Suite

From the `python-installation` project root:

```bash
./tests/test-installations.sh
```

If required:

```bash
chmod +x tests/test-installations.sh
```

Then:

```bash
./tests/test-installations.sh
```

Expected final output:

```text
========================================
TEST SUMMARY
========================================
PASSED: <number>
FAILED: 0

ALL TESTS PASSED
```

> ℹ️ The automated suite is designed to avoid repeatedly rebuilding Python versions that are already installed.

---

# 14. Test Case Matrix

| **Test ID** | **Test Scenario** | **Expected Result** |
| ----------- | ----------------- | ------------------- |
| TC-01 | Shell syntax | Syntax is valid |
| TC-02 | Package method | Package is detected correctly |
| TC-03 | Package upgrade | Upgrade path executes correctly |
| TC-04 | Auto → APT | APT is selected |
| TC-05 | Auto → Tarball | Tarball fallback is selected |
| TC-06 | Existing Tarball | Existing target version detected |
| TC-07 | Invalid Version | Invalid input rejected |
| TC-08 | Invalid Method | Unsupported method rejected |
| TC-09 | Help | Usage information displayed |
| TC-10 | Logging | Log file contains execution entries |
| TC-11 | Runtime | Expected Python runtime works |
| TC-12 | SHA256 | Valid archive checksum verified |

---

# 15. Detailed Test Cases

## 🧪 TC-01 — Shell Syntax

### Command

```bash
bash -n python-installer.sh
```

### Expected Result

```text
No output
```

### Pass Criteria

```text
Exit code = 0
```

---

## 📦 TC-02 — Package Method

### Command

```bash
./python-installer.sh \
    --version 3.12 \
    --method package
```

### Expected Result

```text
Package python3.12 is available in APT.
python3.12 is already installed.
Installed version: 3.12.3
Nothing to install.
```

### Pass Criteria

- ✅ Package detected.
- ✅ Existing installation detected.
- ✅ No unnecessary reinstall.
- ✅ Exit status successful.

---

## 🔄 TC-03 — Package Upgrade

### Command

```bash
./python-installer.sh \
    --version 3.12 \
    --method package \
    --upgrade
```

### Expected Result

If current:

```text
python3.12 is already the newest version
```

followed by Python verification.

### Pass Criteria

- ✅ `--upgrade` recognized.
- ✅ APT metadata refreshed.
- ✅ Requested Python package targeted.
- ✅ Python version verified.

---

## 🤖 TC-04 — Auto Method → APT

### Command

```bash
./python-installer.sh \
    --version 3.12 \
    --method auto
```

### Expected Result

```text
APT package found.
Using package manager.
```

### Pass Criteria

- ✅ APT package detected.
- ✅ Auto selects APT.
- ✅ Existing installation handled safely.

---

## 🤖 TC-05 — Auto Method → Tarball

### Command

```bash
./python-installer.sh \
    --version 3.13.7 \
    --method auto \
    --sha256 6c9d80839cfa20024f34d9a6dd31ae2a9cd97ff5e980e969209746037a5153b2
```

### Expected Result

```text
Package python3.13.7 is NOT available in APT.
APT package not available.
Falling back to tarball installation.
```

If already installed:

```text
Existing Python found: 3.13.7
Version comparison: SAME
Nothing to install.
```

### Pass Criteria

- ✅ APT absence detected.
- ✅ Tarball fallback selected.
- ✅ Existing version detected.
- ✅ No unnecessary rebuild.

---

## ♻️ TC-06 — Existing Tarball Version

### Command

```bash
./python-installer.sh \
    --version 3.13.7 \
    --method tarball \
    --sha256 6c9d80839cfa20024f34d9a6dd31ae2a9cd97ff5e980e969209746037a5153b2
```

### Expected Result

```text
Existing Python found: 3.13.7
Version comparison: SAME
Python 3.13.7 is already installed.
Nothing to install.
```

### Pass Criteria

- ✅ `SAME` comparison.
- ✅ No unnecessary source rebuild.
- ✅ Successful exit.

---

## ❌ TC-07 — Invalid Python Version

### Command

```bash
./python-installer.sh \
    --version abc \
    --method package
```

### Expected Result

```text
ERROR: Invalid Python version
```

### Pass Criteria

- ❌ Invalid input rejected.
- ❌ Non-zero exit status.

---

## ❌ TC-08 — Invalid Installation Method

### Command

```bash
./python-installer.sh \
    --version 3.12 \
    --method xyz
```

### Expected Result

```text
ERROR: Unsupported method 'xyz'.
```

### Pass Criteria

- ❌ Unsupported method rejected.
- ❌ Non-zero exit status.

---

## ❓ TC-09 — Help

### Command

```bash
./python-installer.sh --help
```

### Expected Result

Output contains:

```text
Python Installer
--version
--method
--upgrade
--help
```

### Pass Criteria

✅ Usage information is displayed.

---

## 📝 TC-10 — Logging

### Log Location

```text
logs/python-installer.log
```

### Verify

```bash
cat logs/python-installer.log
```

Expected entries:

```text
Python installer started
Target version
Method
Python installer finished successfully
```

### Pass Criteria

- ✅ Log file exists.
- ✅ Installer executions recorded.
- ✅ Installation decisions traceable.

---

## 🐍 TC-11 — Runtime Verification

### Python Version

```bash
/usr/local/bin/python3.13 --version
```

Expected:

```text
Python 3.13.7
```

### SSL

```bash
/usr/local/bin/python3.13 -c \
"import ssl; print('SSL:', ssl.OPENSSL_VERSION)"
```

### SQLite

```bash
/usr/local/bin/python3.13 -c \
"import sqlite3; print('SQLite:', sqlite3.sqlite_version)"
```

### Core Modules

```bash
/usr/local/bin/python3.13 -c \
"import bz2, lzma, ctypes, readline; print('Core modules: OK')"
```

### pip

```bash
/usr/local/bin/python3.13 -m pip --version
```

### Pass Criteria

- ✅ Correct Python version.
- ✅ SSL works.
- ✅ SQLite works.
- ✅ Core modules import successfully.
- ✅ pip is available.

---

# 16. SHA256 Verification

The validated Python 3.13.7 source archive was checked using:

```bash
echo "6c9d80839cfa20024f34d9a6dd31ae2a9cd97ff5e980e969209746037a5153b2  Python-3.13.7.tgz" | sha256sum -c -
```

Expected:

```text
Python-3.13.7.tgz: OK
```

### Integrity Flow

```text
📥 Download
    ↓
🔐 SHA256
    ↓
Compare
    ↓
┌─────────────┴─────────────┐
▼                           ▼
MATCH                    MISMATCH
│                           │
▼                           ▼
BUILD                       STOP
```

### Invalid Checksum

The installer validates the SHA256 format before a new tarball build.

Expected invalid format:

```text
ERROR: Invalid SHA256 checksum format.
```

Expected checksum mismatch:

```text
ERROR: SHA256 verification failed.
```

> ⚠️ The current regression script validates the existing tarball installation behavior, while the source archive checksum was independently verified during the POC.

---

# 17. Runtime Verification

The source-installed Python runtime was independently verified.

| **Check** | **Expected / Verified** |
| --------- | ------------------------ |
| Python version | 3.13.7 |
| OpenSSL | OpenSSL 3.0.13 |
| SQLite | 3.45.1 |
| Core modules | OK |
| pip | 25.2 |

This confirms that Python is functional after installation rather than simply present on disk.

---

# 18. Logging Verification

The installer writes operational logs to:

```text
logs/python-installer.log
```

Example log entries:

```text
2026-08-24 10:56:10 [INFO] Python installer started
2026-08-24 10:56:10 [INFO] Target version: 3.12
2026-08-24 10:56:10 [INFO] Method: package
2026-08-24 10:56:10 [INFO] python3.12 is already installed.
2026-08-24 10:56:10 [INFO] Nothing to install.
2026-08-24 10:56:10 [INFO] Python installer finished successfully.
```

The logs provide evidence for:

- 🕒 Timestamp
- 🎯 Target version
- 📦 Method
- 🔄 Upgrade state
- 🔎 Installation decision
- ✅ Final status

---

# 19. Test Evidence

For review/demo purposes, retain:

```text
Test ID:
Environment:
Command:
Expected Result:
Actual Result:
Exit Status:
Result:
```

### Example

```text
Test ID:
TC-02

Environment:
Ubuntu 24.04.4 LTS / WSL2

Command:
./python-installer.sh --version 3.12 --method package

Expected:
Existing package detected without reinstall.

Actual:
python3.12 is already installed.
Installed version: 3.12.3
Nothing to install.

Exit Status:
0

Result:
PASS
```

Useful commands for evidence:

```bash
bash -n python-installer.sh
```

```bash
./tests/test-installations.sh
```

```bash
cat logs/python-installer.log
```

---

# 20. Acceptance Criteria

Testing is considered complete when:

- [ ] 🧪 Bash syntax passes
- [ ] 📦 Package method passes
- [ ] 🔄 Package upgrade path verified
- [ ] 🤖 Auto method selects APT when available
- [ ] 🤖 Auto method falls back to tarball when APT is unavailable
- [ ] ♻️ Existing Python versions detected
- [ ] ❌ Invalid Python versions rejected
- [ ] ❌ Invalid methods rejected
- [ ] ❓ Help output available
- [ ] 📝 Logs generated
- [ ] 🐍 Runtime verified
- [ ] 🔐 Valid SHA256 verified
- [ ] 🛑 Invalid SHA256 handling verified
- [ ] 🚫 No unnecessary rebuild for an already-installed version

---

# 21. Troubleshooting

<details>
<summary>❌ Test script is not executable</summary>

Run:

```bash
chmod +x tests/test-installations.sh
```

Then:

```bash
./tests/test-installations.sh
```

</details>

<details>
<summary>📁 Installer cannot be found</summary>

Run the test suite from the `python-installation` project root:

```bash
cd python-installation
./tests/test-installations.sh
```

</details>

<details>
<summary>📝 Log file is missing</summary>

Check:

```bash
ls -lh logs/
```

Then:

```bash
cat logs/python-installer.log
```

</details>

<details>
<summary>🐍 Runtime verification fails</summary>

Check:

```bash
ls -l /usr/local/bin/python3.13
```

Then:

```bash
/usr/local/bin/python3.13 --version
```

</details>

<details>
<summary>🔐 SHA256 verification fails</summary>

Verify:

1. The tarball is the expected release.
2. The checksum contains exactly 64 hexadecimal characters.
3. The expected checksum comes from a trusted source.

Do not bypass checksum verification.

</details>

---

# 22. Contact Information

| **Name** | **Email** |
| -------- | --------- |
| Vashishtha Prakash | `<email>` |

---

# 23. References

| **Topic** | **Description** |
| --------- | --------------- |
| [Python Documentation](https://docs.python.org/3/) | Official Python documentation. |
| [Python Downloads](https://www.python.org/downloads/) | Official Python release and download information. |
| [GNU Bash Manual](https://www.gnu.org/software/bash/manual/) | Official GNU Bash documentation. |
| [Ubuntu Documentation](https://documentation.ubuntu.com/) | Official Ubuntu documentation. |

---

<p align="center">

**🧪 Python Installer Testing • Validation • Evidence • Repeatability**

</p>
