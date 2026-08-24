# 📘 Python Installation Guide

> Detailed operational documentation for `python-installer.sh`.

---

## 🧭 Navigation

- [🎯 Purpose](#-purpose)
- [⚙️ Requirements](#️-requirements)
- [📋 Command Reference](#-command-reference)
- [📦 Package Installation](#-package-installation)
- [📦 Tarball Installation](#-tarball-installation)
- [🤖 Automatic Installation](#-automatic-installation)
- [🔐 SHA256 Verification](#-sha256-verification)
- [🔄 Upgrade](#-upgrade)
- [♻️ Version Comparison](#️-version-comparison)
- [🔧 Dependencies](#-dependencies)
- [📝 Logging](#-logging)
- [🧹 Cleanup](#-cleanup)
- [🧪 Verification](#-verification)
- [🛠️ Troubleshooting](#️-troubleshooting)
- [🔒 Security](#-security)

---

## 🎯 Purpose

`python-installer.sh` provides a controlled way to install Python on Ubuntu/Linux systems.

It supports:

```text
📦 APT package
📦 Source tarball
🤖 Automatic selection
```

The installer validates inputs before performing installation operations.

---

## ⚙️ Requirements

### 🖥️ Operating System

Tested environment:

```text
Ubuntu 24.04 LTS
```

### 🔨 Required Commands

Tarball installation checks:

```text
gcc
make
tar
wget
sha256sum
```

### 📚 Required Development Packages

```text
build-essential
libssl-dev
zlib1g-dev
libbz2-dev
libreadline-dev
libsqlite3-dev
libffi-dev
liblzma-dev
tk-dev
uuid-dev
```

---

## 📋 Command Reference

### Basic syntax

```bash
./python-installer.sh \
    --version <version> \
    --method <package|tarball|auto>
```

### Options

| Option | Required | Purpose |
|---|:---:|---|
| `--version` | ✅ | Target Python version |
| `--method` | ✅ | Installation method |
| `--sha256` | Tarball | Expected SHA256 checksum |
| `--upgrade` | ❌ | Request package upgrade |
| `--keep-build` | ❌ | Preserve successful build directory |
| `--help` | ❌ | Display usage information |

---

## 📦 Package Installation

Use:

```bash
./python-installer.sh \
    --version 3.12 \
    --method package
```

The installer checks whether:

```text
python3.12
```

is available through APT.

If already installed:

```text
python3.12 is already installed.
Installed version: 3.12.3
Nothing to install.
```

### 🔄 Package upgrade

```bash
./python-installer.sh \
    --version 3.12 \
    --method package \
    --upgrade
```

The script performs an APT update and targets the requested Python package for upgrade.

> ℹ️ This is not a general `apt upgrade`.

---

## 📦 Tarball Installation

Use:

```bash
./python-installer.sh \
    --version 3.13.7 \
    --method tarball \
    --sha256 <SHA256_CHECKSUM>
```

The source archive follows:

```text
https://www.python.org/ftp/python/<version>/Python-<version>.tgz
```

### 🔄 Build pipeline

```text
1️⃣ Validate version
       ↓
2️⃣ Check existing Python
       ↓
3️⃣ Validate SHA256 argument
       ↓
4️⃣ Check build dependencies
       ↓
5️⃣ Create temporary build directory
       ↓
6️⃣ Download source archive
       ↓
7️⃣ Verify SHA256
       ↓
8️⃣ Extract source
       ↓
9️⃣ Configure
       ↓
🔟 Build with nproc CPU cores
       ↓
1️⃣1️⃣ Install using altinstall
       ↓
1️⃣2️⃣ Verify runtime
       ↓
1️⃣3️⃣ Cleanup
```

---

## 🤖 Automatic Installation

Use:

```bash
./python-installer.sh \
    --version 3.13.7 \
    --method auto \
    --sha256 <SHA256_CHECKSUM>
```

Decision:

```text
              Requested version
                     │
                     ▼
             APT package exists?
                ╱          ╲
              YES           NO
               │             │
               ▼             ▼
            📦 APT       📦 Tarball
```

Example for an APT-supported version:

```text
APT package found.
Using package manager.
```

Example when APT is unavailable:

```text
APT package not available.
Falling back to tarball installation.
```

---

## 🔐 SHA256 Verification

Tarball installation requires a valid 64-character hexadecimal SHA256 value.

Example:

```bash
./python-installer.sh \
    --version 3.13.7 \
    --method tarball \
    --sha256 6c9d80839cfa20024f34d9a6dd31ae2a9cd97ff5e980e969209746037a5153b2
```

Manual check:

```bash
echo "6c9d80839cfa20024f34d9a6dd31ae2a9cd97ff5e980e969209746037a5153b2  Python-3.13.7.tgz" | sha256sum -c -
```

Expected:

```text
Python-3.13.7.tgz: OK
```

### 🛑 Failed checksum

If verification fails:

```text
ERROR: SHA256 verification failed.
```

the source must not be built.

---

## 🔄 Upgrade

Use `--upgrade` with the package method:

```bash
./python-installer.sh \
    --version 3.12 \
    --method package \
    --upgrade
```

The script checks the package through APT and upgrades it only when an upgrade is available.

---

## ♻️ Version Comparison

The installer compares installed and requested versions.

Possible outcomes:

```text
SAME
UPGRADE
DOWNGRADE
```

### SAME

```text
Installed: 3.13.7
Target:    3.13.7
Result:    SAME
```

No installation is performed.

### UPGRADE

```text
Installed: 3.13.7
Target:    3.13.8
Result:    UPGRADE
```

The tarball path requires `--upgrade` before replacing the installed version.

### DOWNGRADE

```text
Installed: 3.13.8
Target:    3.13.7
Result:    DOWNGRADE
```

Downgrades are rejected.

---

## 🔧 Dependencies

Before a tarball build, the installer checks commands and packages.

### Commands

```text
gcc
make
tar
wget
sha256sum
```

### Packages

```text
build-essential
libssl-dev
zlib1g-dev
libbz2-dev
libreadline-dev
libsqlite3-dev
libffi-dev
liblzma-dev
tk-dev
uuid-dev
```

If a dependency is missing, the installer stops and reports the required package.

---

## 📝 Logging

Logs are stored at:

```text
logs/python-installer.log
```

View:

```bash
cat logs/python-installer.log
```

The log records:

```text
🕒 Timestamp
🎯 Target version
📦 Method
🔄 Upgrade setting
🧹 Build retention setting
🔎 Installation decisions
✅ Completion status
```

---

## 🧹 Cleanup

Temporary tarball build directories use:

```text
/tmp/python-build-<version>
```

### Successful installation

The directory is removed automatically.

### Failed installation

The directory is retained for troubleshooting.

### Preserve successful build

Use:

```bash
--keep-build
```

Example:

```bash
./python-installer.sh \
    --version <version> \
    --method tarball \
    --sha256 <SHA256_CHECKSUM> \
    --keep-build
```

---

## 🧪 Verification

### 🐍 Python version

```bash
/usr/local/bin/python3.13 --version
```

Expected:

```text
Python 3.13.7
```

### 🔐 SSL

```bash
/usr/local/bin/python3.13 -c \
"import ssl; print('SSL:', ssl.OPENSSL_VERSION)"
```

### 🗄️ SQLite

```bash
/usr/local/bin/python3.13 -c \
"import sqlite3; print('SQLite:', sqlite3.sqlite_version)"
```

### 🧩 Core modules

```bash
/usr/local/bin/python3.13 -c \
"import bz2, lzma, ctypes, readline; print('Core modules: OK')"
```

---

## 🧪 Automated Test Suite

From the project root:

```bash
./tests/test-installations.sh
```

Test documentation:

👉 [`../tests/README.md`](../tests/README.md)

---

## 🛠️ Troubleshooting

<details>
<summary>📦 APT package not available</summary>

Use:

```bash
--method auto
```

or:

```bash
--method tarball
```

</details>

<details>
<summary>🔐 SHA256 checksum problem</summary>

Check that the supplied checksum contains exactly 64 hexadecimal characters and matches the trusted source checksum.

</details>

<details>
<summary>🔧 Missing build dependency</summary>

Install the packages reported by the installer and rerun the command.

</details>

<details>
<summary>🐍 Python already installed</summary>

If the requested version is already installed, this is expected:

```text
Version comparison: SAME
Nothing to install.
```

</details>

<details>
<summary>🧹 Need build files for debugging</summary>

Use:

```bash
--keep-build
```

to preserve the build directory after a successful installation.

</details>

---

## 🔒 Security

- 🔐 Verify source tarball checksums.
- 🌐 Use trusted Python release sources.
- 🚫 Never commit secrets.
- 🔑 Never commit private SSH keys.
- 🧹 Keep temporary build artifacts outside the repository.
- ⚠️ Review scripts before executing privileged commands.

---

## ✅ Operational Checklist

```text
☐ Validate requested Python version
☐ Select installation method
☐ Check existing installation
☐ Check dependencies when building
☐ Verify SHA256 before build
☐ Verify installed Python
☐ Review logs
☐ Confirm cleanup
☐ Run automated tests
```

---

<p align="center">

**📘 Detailed Installation Guide • Python Installer**

</p>
