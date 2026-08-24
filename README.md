# Python Installer

A Bash-based Python installation utility for Ubuntu/Linux systems.

The installer provides three ways to install Python:

- **Package** — install Python using APT.
- **Tarball** — build Python from the official source tarball.
- **Auto** — use APT when the requested package is available, otherwise fall back to a tarball installation.

## Features

- Python version validation
- APT/package installation
- Source tarball installation
- Automatic package/tarball selection
- SHA256 checksum verification
- Existing-version detection
- Upgrade handling
- Idempotent behavior
- Build dependency checks
- Installation logging
- Temporary build cleanup
- Optional build-directory preservation
- Automated validation tests

## Project Structure

```text
python-installer/
├── python-installer.sh
├── test-installations.sh
├── README.md
└── installation.md
```

## Requirements

Tested on:

```text
Ubuntu 24.04 LTS
```

For source/tarball installation, the installer checks for:

```text
gcc
make
tar
wget
sha256sum
```

and the required development packages, including:

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

## Quick Start

Make the scripts executable:

```bash
chmod +x python-installer.sh
chmod +x test-installations.sh
```

Check syntax:

```bash
bash -n python-installer.sh
```

Run the test suite:

```bash
./test-installations.sh
```

## Installation Methods

### 1. Package

Use APT when the requested Python version is available:

```bash
./python-installer.sh     --version 3.12     --method package
```

If the requested version is already installed, the installer does not reinstall it.

### 2. Tarball

Use the official Python source tarball:

```bash
./python-installer.sh     --version 3.13.7     --method tarball     --sha256 <SHA256_CHECKSUM>
```

The tarball installation flow is:

```text
Validate
   ↓
Check existing version
   ↓
Check dependencies
   ↓
Download
   ↓
SHA256 verification
   ↓
Extract
   ↓
Configure
   ↓
Build
   ↓
Install
   ↓
Verify
   ↓
Cleanup
```

### 3. Auto

Let the installer choose the installation method:

```bash
./python-installer.sh     --version 3.13.7     --method auto     --sha256 <SHA256_CHECKSUM>
```

The decision is:

```text
             Python version
                   │
                   ▼
          APT package available?
             /           \
           YES            NO
            │              │
            ▼              ▼
           APT          Tarball
```

## SHA256 Verification

Tarball installation requires a SHA256 checksum.

Example:

```bash
./python-installer.sh     --version 3.13.7     --method tarball     --sha256 6c9d80839cfa20024f34d9a6dd31ae2a9cd97ff5e980e969209746037a5153b2
```

Manual verification:

```bash
echo "6c9d80839cfa20024f34d9a6dd31ae2a9cd97ff5e980e969209746037a5153b2  Python-3.13.7.tgz" | sha256sum -c -
```

Expected:

```text
Python-3.13.7.tgz: OK
```

## Upgrade

For a package installation:

```bash
./python-installer.sh     --version 3.12     --method package     --upgrade
```

The `--upgrade` option targets the requested Python package; it does not perform a general system upgrade.

## Idempotency

If the requested Python version is already installed, the installer exits without unnecessary work.

Example:

```text
Version comparison: SAME
Python 3.13.7 is already installed.
Nothing to install.
```

Version comparison can identify:

```text
SAME
UPGRADE
DOWNGRADE
```

Downgrades are not supported.

## Logging

Installer activity is written to:

```text
logs/python-installer.log
```

View the log:

```bash
cat logs/python-installer.log
```

Logs include the target version, method, installation decisions, version comparison, and execution status.

## Cleanup

Tarball builds use a temporary directory:

```text
/tmp/python-build-<version>
```

Successful installations clean the temporary build directory.

For troubleshooting, the build directory can be preserved:

```bash
./python-installer.sh     --version <version>     --method tarball     --sha256 <SHA256_CHECKSUM>     --keep-build
```

## Testing

Run:

```bash
./test-installations.sh
```

The test script validates:

- Shell syntax
- Package installation detection
- Auto method selection
- Existing tarball installation detection
- Invalid version handling
- Invalid method handling
- Help output
- Log creation
- Python runtime verification

Expected result:

```text
========================================
TEST SUMMARY
========================================
PASSED: <number>
FAILED: 0

ALL TESTS PASSED
```

## Common Commands

### Show help

```bash
./python-installer.sh --help
```

### Install Python 3.12 using APT

```bash
./python-installer.sh --version 3.12 --method package
```

### Install Python from source

```bash
./python-installer.sh     --version 3.13.7     --method tarball     --sha256 <SHA256_CHECKSUM>
```

### Automatic installation

```bash
./python-installer.sh     --version 3.13.7     --method auto     --sha256 <SHA256_CHECKSUM>
```

### Verify installed Python

```bash
python3.12 --version
```

For the source installation:

```bash
/usr/local/bin/python3.13 --version
```

## Troubleshooting

### APT package unavailable

Use:

```bash
--method auto
```

or explicitly:

```bash
--method tarball
```

For tarball installation, provide the expected SHA256 checksum.

### SHA256 verification failed

Do not continue with an unverified source archive. Check the tarball and expected checksum.

### Missing dependencies

The installer reports missing build dependencies and provides an APT command for installation.

### Python already installed

This is expected behavior. The installer avoids unnecessary reinstallation.

## Security

- Use a trusted Python source URL.
- Always verify SHA256 checksums for source archives.
- Do not commit passwords, API keys, SSH private keys, or other secrets.
- Avoid committing large source archives, logs, and temporary build files unless explicitly required.
- Review scripts before running commands that use `sudo`.

## Detailed Documentation

For the complete installation, dependency, verification, logging, cleanup, troubleshooting, and security documentation, see:

[`installation.md`](installation.md)

## Final Checklist

- [ ] `python-installer.sh` is executable
- [ ] `test-installations.sh` is executable
- [ ] Syntax check passes
- [ ] Package method tested
- [ ] Auto method tested
- [ ] Tarball checksum tested
- [ ] Invalid input handling tested
- [ ] Logging verified
- [ ] Runtime verification completed
- [ ] No secrets or unnecessary build artifacts are committed
