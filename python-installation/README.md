# 🐍 Python Installation

> **Automated Python installation utility for Ubuntu/Linux**
>
> Supports **APT**, **source tarball**, and **automatic method selection** with validation, SHA256 verification, logging, cleanup, and automated tests.

---

## 🧭 Navigation

- [✨ Features](#-features)
- [🏗️ Project Structure](#️-project-structure)
- [⚙️ Requirements](#️-requirements)
- [🚀 Quick Start](#-quick-start)
- [📦 Installation Methods](#-installation-methods)
- [🔐 SHA256 Verification](#-sha256-verification)
- [🔄 Upgrade](#-upgrade)
- [♻️ Idempotency](#️-idempotency)
- [📝 Logging](#-logging)
- [🧹 Cleanup](#-cleanup)
- [🧪 Testing](#-testing)
- [🛠️ Troubleshooting](#️-troubleshooting)
- [🔒 Security](#-security)
- [📚 Documentation](#-documentation)

---

## ✨ Features

| Feature | Status |
|---|:---:|
| 🐍 Python version validation | ✅ |
| 📦 APT/package installation | ✅ |
| 📦 Source tarball installation | ✅ |
| 🤖 Automatic package/tarball selection | ✅ |
| 🔐 SHA256 checksum verification | ✅ |
| ♻️ Existing-version detection | ✅ |
| 🔄 Upgrade handling | ✅ |
| 🛡️ Idempotent behavior | ✅ |
| 🔧 Build dependency checking | ✅ |
| 📝 Installation logging | ✅ |
| 🧹 Temporary build cleanup | ✅ |
| 🐞 Optional build-directory preservation | ✅ |
| 🧪 Automated tests | ✅ |

---

## 🏗️ Project Structure

```text
python-installation/
│
├── 📄 README.md
├── 🐍 python-installer.sh
│
├── 📁 docs/
│   └── 📄 installation.md
│
└── 📁 tests/
    ├── 🧪 test-installations.sh
    └── 📄 README.md
```

> 💡 **Scope:** Documentation inside this project is intentionally limited to the Python installation project. No repository-level README is required for this structure.

---

## ⚙️ Requirements

### 🖥️ Tested Environment

```text
Ubuntu 24.04 LTS
```

### 🔨 Tarball Build Tools

The installer checks for:

```text
gcc
make
tar
wget
sha256sum
```

### 📚 Development Packages

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

## 🚀 Quick Start

### 1️⃣ Make scripts executable

```bash
chmod +x python-installer.sh
chmod +x tests/test-installations.sh
```

### 2️⃣ Validate shell syntax

```bash
bash -n python-installer.sh
```

> ✅ No output means the Bash syntax check passed.

### 3️⃣ Run the test suite

```bash
./tests/test-installations.sh
```

### 4️⃣ Install Python with APT

```bash
./python-installer.sh \
    --version 3.12 \
    --method package
```

### 5️⃣ Install Python from source

```bash
./python-installer.sh \
    --version 3.13.7 \
    --method tarball \
    --sha256 <SHA256_CHECKSUM>
```

---

## 📦 Installation Methods

### 📦 Method 1 — Package

Use APT when the requested Python version is available.

```bash
./python-installer.sh \
    --version 3.12 \
    --method package
```

The installer detects an existing installation and avoids unnecessary reinstallation.

```text
Package python3.12 is available in APT.
python3.12 is already installed.
Installed version: 3.12.3
Nothing to install.
```

---

### 📦 Method 2 — Tarball

Use the official Python source tarball when a package is unavailable or a source installation is required.

```bash
./python-installer.sh \
    --version 3.13.7 \
    --method tarball \
    --sha256 <SHA256_CHECKSUM>
```

#### 🔄 Installation flow

```text
          📝 Validate
              │
              ▼
      🔎 Existing version?
              │
              ▼
       🔐 Validate SHA256
              │
              ▼
       🔧 Check dependencies
              │
              ▼
          ⬇️ Download
              │
              ▼
       🔐 Verify checksum
              │
              ▼
          📦 Extract
              │
              ▼
        ⚙️ Configure
              │
              ▼
          🔨 Build
              │
              ▼
          📥 Install
              │
              ▼
          ✅ Verify
              │
              ▼
          🧹 Cleanup
```

---

### 🤖 Method 3 — Auto

The `auto` method chooses the installation mechanism:

```bash
./python-installer.sh \
    --version 3.13.7 \
    --method auto \
    --sha256 <SHA256_CHECKSUM>
```

Decision logic:

```text
             🐍 Requested version
                     │
                     ▼
           📦 APT package available?
                ╱             ╲
              YES              NO
               │                │
               ▼                ▼
            📦 APT          📦 Tarball
```

---

## 🔐 SHA256 Verification

Tarball installation requires a SHA256 checksum.

Example:

```bash
./python-installer.sh \
    --version 3.13.7 \
    --method tarball \
    --sha256 6c9d80839cfa20024f34d9a6dd31ae2a9cd97ff5e980e969209746037a5153b2
```

Manual verification:

```bash
echo "6c9d80839cfa20024f34d9a6dd31ae2a9cd97ff5e980e969209746037a5153b2  Python-3.13.7.tgz" | sha256sum -c -
```

Expected:

```text
Python-3.13.7.tgz: OK
```

> 🛑 A failed checksum must stop the tarball installation.

---

## 🔄 Upgrade

For an APT-managed Python version:

```bash
./python-installer.sh \
    --version 3.12 \
    --method package \
    --upgrade
```

The `--upgrade` option targets the requested Python package. It does **not** perform a general system upgrade.

---

## ♻️ Idempotency

The installer compares the requested version with the installed version.

Possible states:

```text
SAME
UPGRADE
DOWNGRADE
```

For an already-installed target:

```text
Version comparison: SAME
Python 3.13.7 is already installed.
Nothing to install.
```

> 🛡️ This prevents unnecessary rebuilding or reinstalling.

Downgrades are not supported.

---

## 📝 Logging

Installer activity is recorded in:

```text
logs/python-installer.log
```

View logs:

```bash
cat logs/python-installer.log
```

Typical entries include:

```text
Target version
Installation method
Upgrade option
Build retention option
Package selection
Version comparison
Installation status
```

---

## 🧹 Cleanup

Tarball builds use:

```text
/tmp/python-build-<version>
```

Successful installations automatically remove the temporary build directory.

For troubleshooting, preserve it with:

```bash
./python-installer.sh \
    --version <version> \
    --method tarball \
    --sha256 <SHA256_CHECKSUM> \
    --keep-build
```

---

## 🧪 Testing

Run the project test suite:

```bash
./tests/test-installations.sh
```

The suite validates:

- 🔎 Shell syntax
- 📦 Package method
- 🤖 Auto method
- 📦 Existing tarball installation
- ❌ Invalid Python versions
- ❌ Invalid methods
- ❓ Help output
- 📝 Logging
- 🐍 Python runtime verification

Expected result:

```text
========================================
TEST SUMMARY
========================================
PASSED: <number>
FAILED: 0

ALL TESTS PASSED
```

👉 See [`tests/README.md`](tests/README.md) for the complete test documentation.

---

## 🛠️ Troubleshooting

<details>
<summary>📦 APT package is unavailable</summary>

Use:

```bash
--method auto
```

or explicitly:

```bash
--method tarball
```

Tarball installation requires a valid SHA256 checksum.

</details>

<details>
<summary>🔐 SHA256 verification failed</summary>

Verify the downloaded archive and the expected checksum before continuing.

Do not bypass checksum validation.

</details>

<details>
<summary>🔧 Build dependency is missing</summary>

The installer reports missing dependencies and provides an APT command that can be used to install them.

</details>

<details>
<summary>♻️ Python is already installed</summary>

This is expected behavior:

```text
Version comparison: SAME
Nothing to install.
```

The installer avoids unnecessary work.

</details>

---

## 🔒 Security

- 🔐 Always verify SHA256 checksums for source archives.
- 🌐 Use a trusted Python source URL.
- 🚫 Never commit passwords, tokens, API keys, or private SSH keys.
- 📦 Avoid committing large source archives and temporary build files.
- 📝 Review scripts before running commands that use `sudo`.

---

## 📚 Documentation

| Document | Purpose |
|---|---|
| 📄 [`README.md`](README.md) | Project overview and quick start |
| 📘 [`docs/installation.md`](docs/installation.md) | Detailed installation and operational documentation |
| 🧪 [`tests/README.md`](tests/README.md) | Test cases, commands, expected results, and acceptance criteria |

---

## ✅ Final Checklist

- [ ] 🐍 `python-installer.sh` is executable
- [ ] 🧪 `test-installations.sh` is executable
- [ ] 🔎 Syntax check passes
- [ ] 📦 Package method tested
- [ ] 🤖 Auto method tested
- [ ] 📦 Tarball behavior tested
- [ ] 🔐 SHA256 verification tested
- [ ] ❌ Invalid input handling tested
- [ ] 📝 Logging verified
- [ ] 🐍 Runtime verification completed
- [ ] 🚫 No secrets committed
- [ ] 🧹 Unnecessary build artifacts excluded

---

<p align="center">

**🐍 Python Installation • Automated • Validated • Secure**

</p>
