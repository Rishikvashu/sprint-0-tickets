# 🧪 Python Installer Tests

> Test documentation for `python-installer.sh`.

---

## 🧭 Navigation

- [🎯 Test Objective](#-test-objective)
- [📁 Test Structure](#-test-structure)
- [🚀 Running Tests](#-running-tests)
- [📋 Test Matrix](#-test-matrix)
- [🔎 Individual Test Cases](#-individual-test-cases)
- [🔐 SHA256 Validation](#-sha256-validation)
- [🐍 Runtime Verification](#-runtime-verification)
- [📊 Acceptance Criteria](#-acceptance-criteria)
- [🛠️ Troubleshooting](#️-troubleshooting)

---

## 🎯 Test Objective

The test suite verifies that the Python installer behaves correctly for:

- 📦 Package installation
- 🤖 Automatic method selection
- 📦 Existing tarball installations
- 🔐 Input/checksum validation
- ♻️ Idempotent behavior
- 📝 Logging
- 🐍 Runtime verification
- ❌ Invalid input handling

The tests are designed to avoid unnecessary reinstallation of an already-installed Python version.

---

## 📁 Test Structure

```text
tests/
├── 🧪 test-installations.sh
└── 📄 README.md
```

---

## 🚀 Running Tests

From the `python-installation` project root:

### 1️⃣ Make the test script executable

```bash
chmod +x tests/test-installations.sh
```

### 2️⃣ Run the tests

```bash
./tests/test-installations.sh
```

### 3️⃣ Expected result

```text
========================================
TEST SUMMARY
========================================
PASSED: <number>
FAILED: 0

ALL TESTS PASSED
```

> ✅ Exit code `0` indicates a successful test run.

---

## 📋 Test Matrix

| ID | Test | Expected Result |
|---|---|---|
| 🧪 TC-01 | Bash syntax | Valid syntax |
| 📦 TC-02 | Package method | Existing package detected |
| 🤖 TC-03 | Auto method | APT selected when available |
| 📦 TC-04 | Tarball existing version | No unnecessary rebuild |
| ❌ TC-05 | Invalid Python version | Rejected |
| ❌ TC-06 | Invalid method | Rejected |
| ❓ TC-07 | Help option | Usage displayed |
| 📝 TC-08 | Logging | Log exists and contains entries |
| 🐍 TC-09 | Runtime verification | Expected Python version confirmed |

---

# 🔎 Individual Test Cases

## 🧪 TC-01 — Bash Syntax

Command:

```bash
bash -n python-installer.sh
```

Expected:

```text
No output
```

Pass condition:

```text
Exit code = 0
```

---

## 📦 TC-02 — Package Method

Command:

```bash
./python-installer.sh \
    --version 3.12 \
    --method package
```

Expected behavior:

```text
Package python3.12 is available in APT.
python3.12 is already installed.
Installed version: 3.12.3
Nothing to install.
```

### ✅ Pass criteria

- Command succeeds.
- Package is detected.
- Existing Python is not unnecessarily reinstalled.

---

## 🤖 TC-03 — Auto Method

Command:

```bash
./python-installer.sh \
    --version 3.12 \
    --method auto
```

Expected:

```text
APT package found.
Using package manager.
```

### ✅ Pass criteria

- Command succeeds.
- APT package is detected.
- Auto mode selects APT.

---

## 📦 TC-04 — Existing Tarball Installation

Command:

```bash
./python-installer.sh \
    --version 3.13.7 \
    --method tarball \
    --sha256 6c9d80839cfa20024f34d9a6dd31ae2a9cd97ff5e980e969209746037a5153b2
```

Expected:

```text
Existing Python found: 3.13.7
Version comparison: SAME
Python 3.13.7 is already installed.
Nothing to install.
```

### ✅ Pass criteria

- Existing Python is detected.
- Version comparison returns `SAME`.
- No unnecessary build occurs.
- Command exits successfully.

---

## ❌ TC-05 — Invalid Python Version

Command:

```bash
./python-installer.sh \
    --version abc \
    --method package
```

Expected:

```text
ERROR: Invalid Python version
```

### ✅ Pass criteria

- Command exits with a non-zero status.
- Invalid version is rejected.

---

## ❌ TC-06 — Invalid Installation Method

Command:

```bash
./python-installer.sh \
    --version 3.12 \
    --method xyz
```

Expected:

```text
ERROR: Unsupported method 'xyz'.
```

### ✅ Pass criteria

- Command exits with a non-zero status.
- Unsupported method is rejected.

---

## ❓ TC-07 — Help

Command:

```bash
./python-installer.sh --help
```

Expected output includes:

```text
Python Installer
--version
--method
```

### ✅ Pass criteria

The usage/help information is displayed.

---

## 📝 TC-08 — Logging

The installer writes logs to:

```text
logs/python-installer.log
```

Verify:

```bash
cat logs/python-installer.log
```

Expected entries include:

```text
Python installer started
Target version
Method
Python installer finished successfully
```

### ✅ Pass criteria

- Log file exists.
- Installer execution entries are present.

---

## 🐍 TC-09 — Runtime Verification

For Python 3.13.7:

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

### Core modules

```bash
/usr/local/bin/python3.13 -c \
"import bz2, lzma, ctypes, readline; print('Core modules: OK')"
```

---

# 🔐 SHA256 Validation

For the validated Python 3.13.7 source archive:

```bash
echo "6c9d80839cfa20024f34d9a6dd31ae2a9cd97ff5e980e969209746037a5153b2  Python-3.13.7.tgz" | sha256sum -c -
```

Expected:

```text
Python-3.13.7.tgz: OK
```

### 🛑 Invalid checksum

The installer must reject an invalid checksum rather than building an unverified source archive.

Example format:

```text
ERROR: Invalid SHA256 checksum format.
```

or:

```text
ERROR: SHA256 verification failed.
```

---

# 📊 Acceptance Criteria

The Python installation ticket is considered test-complete when:

- [ ] 🧪 Shell syntax passes
- [ ] 📦 Package method passes
- [ ] 🤖 Auto method passes
- [ ] 📦 Existing tarball installation is handled correctly
- [ ] ❌ Invalid Python version is rejected
- [ ] ❌ Invalid installation method is rejected
- [ ] ❓ Help output is available
- [ ] 📝 Logging is verified
- [ ] 🐍 Runtime verification succeeds
- [ ] 🔐 Valid SHA256 is accepted
- [ ] 🛑 Invalid SHA256 is rejected
- [ ] ♻️ Existing installations are not unnecessarily rebuilt

---

# 🛠️ Troubleshooting

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
<summary>📁 Script cannot find python-installer.sh</summary>

Run the test suite from the `python-installation` project root:

```bash
cd python-installation
./tests/test-installations.sh
```

</details>

<details>
<summary>📝 Log test fails</summary>

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
<summary>🐍 Runtime test fails</summary>

Check:

```bash
/usr/local/bin/python3.13 --version
```

and verify that the expected Python binary exists.

</details>

---

## 🧾 Test Evidence

For ticket submission, retain:

```text
🖥️ Test environment
🧪 Test command
📤 Command output
✅ Pass/fail result
📝 Relevant log output
```

This provides traceable evidence that the installer was tested.

---

<p align="center">

**🧪 Tested • Verified • Repeatable**

</p>
