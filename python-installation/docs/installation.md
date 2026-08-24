
# Python Installer

A Bash-based Python installation utility for Ubuntu/Linux systems.

The installer supports three installation methods:

- **Package** — install Python using APT.
- **Tarball** — build and install Python from the official Python source tarball.
- **Auto** — use APT when the requested package is available; otherwise fall back to tarball installation.

## Features

- Python version validation
- APT/package installation
- Source tarball installation
- Automatic package/tarball selection
- SHA256 checksum verification
- Existing-version detection
- Upgrade detection
- Idempotent installation behavior
- Build dependency checking
- Installation logging
- Temporary build-directory cleanup
- Optional build-directory preservation
- Automated test script

## Project Structure

```text
python-installer/
├── python-installer.sh
├── test-installations.sh
└── installation.md
```

Development backups (`python-installer-v1.sh` ... `python-installer-v8.sh`) should normally remain outside the final repository.

## Requirements

Tested environment:

```text
Ubuntu 24.04 LTS
```

### Tarball build requirements

Commands:

```text
gcc
make
tar
wget
sha256sum
```

Development packages checked by the installer:

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

## Make Scripts Executable

```bash
chmod +x python-installer.sh
chmod +x test-installations.sh
```

## Usage

```bash
./python-installer.sh --version <version> --method <package|tarball|auto>
```

| Option | Description |
|---|---|
| `--version` | Python version to install |
| `--method` | `package`, `tarball`, or `auto` |
| `--sha256` | SHA256 checksum for tarball installation |
| `--upgrade` | Request package upgrade |
| `--keep-build` | Preserve temporary build directory |
| `--help` | Display usage information |

## Package Installation

```bash
./python-installer.sh --version 3.12 --method package
```

If the requested version is already installed, no reinstall is performed.

Example:

```text
Package python3.12 is available in APT.
python3.12 is already installed.
Installed version: 3.12.3
Nothing to install.
```

## Package Upgrade

```bash
./python-installer.sh     --version 3.12     --method package     --upgrade
```

The installer updates APT metadata and requests an upgrade of the target Python package. It does not perform a general system upgrade.

## Tarball Installation

```bash
./python-installer.sh     --version 3.13.7     --method tarball     --sha256 <SHA256_CHECKSUM>
```

The source URL follows:

```text
https://www.python.org/ftp/python/<version>/Python-<version>.tgz
```

The installation flow is:

```text
Validate version
       ↓
Check existing installation
       ↓
Validate SHA256
       ↓
Check build dependencies
       ↓
Download source
       ↓
Verify SHA256
       ↓
Extract source
       ↓
Configure
       ↓
Build
       ↓
Install
       ↓
Verify Python
       ↓
Clean temporary build directory
```

## SHA256 Verification

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

The installer does not build a tarball if checksum verification fails.

## Automatic Installation

```bash
./python-installer.sh --version 3.12 --method auto
```

Decision flow:

```text
Requested Python version
          │
          ▼
Is APT package available?
       /       \
     YES        NO
      │          │
      ▼          ▼
     APT      Tarball
```

For tarball fallback, provide the checksum:

```bash
./python-installer.sh     --version 3.13.7     --method auto     --sha256 <SHA256_CHECKSUM>
```

## Existing Installation and Idempotency

The installer compares the requested version with the installed version.

Possible results:

```text
SAME
UPGRADE
DOWNGRADE
```

For a matching version:

```text
Version comparison: SAME
Python 3.13.7 is already installed.
Nothing to install.
```

A downgrade is not supported.

If a newer target is requested without `--upgrade`, the installer stops rather than silently replacing the existing installation.

## Dependency Checking

Before a new tarball build, the installer checks required commands and development libraries.

If dependencies are missing, it reports them and provides an APT command to install them. It does not silently install build dependencies.

## Logging

Logs are written to:

```text
logs/python-installer.log
```

View them with:

```bash
cat logs/python-installer.log
```

The log records target version, method, upgrade/build options, package selection, version comparison, and installation status.

## Build Directory and Cleanup

Tarball builds use:

```text
/tmp/python-build-<version>
```

Successful installations clean this directory automatically.

If installation fails, the build directory is preserved for debugging.

To preserve it after a successful installation:

```bash
./python-installer.sh     --version <version>     --method tarball     --sha256 <SHA256_CHECKSUM>     --keep-build
```

## Testing

Run the automated test suite:

```bash
chmod +x test-installations.sh
./test-installations.sh
```

The test script covers:

- Shell syntax
- Package installation detection
- Automatic APT selection
- Existing tarball installation detection
- Invalid Python versions
- Invalid methods
- Help output
- Log creation
- Python 3.13.7 runtime verification

Expected result:

```text
========================================
TEST SUMMARY
========================================
PASSED: <number>
FAILED: 0

ALL TESTS PASSED
```

## Manual Verification

Python 3.12:

```bash
python3.12 --version
```

Python 3.13:

```bash
/usr/local/bin/python3.13 --version
```

Example:

```text
Python 3.13.7
```

SSL:

```bash
/usr/local/bin/python3.13 -c "import ssl; print('SSL:', ssl.OPENSSL_VERSION)"
```

SQLite:

```bash
/usr/local/bin/python3.13 -c "import sqlite3; print('SQLite:', sqlite3.sqlite_version)"
```

Core modules:

```bash
/usr/local/bin/python3.13 -c "import bz2, lzma, ctypes, readline; print('Core modules: OK')"
```

## Troubleshooting

### APT package unavailable

Use:

```bash
--method tarball
```

or:

```bash
--method auto
```

For tarball installation, provide a valid SHA256 checksum.

### Invalid or failed checksum

For:

```text
ERROR: Invalid SHA256 checksum format.
```

provide a 64-character hexadecimal SHA256 checksum.

For:

```text
ERROR: SHA256 verification failed.
```

verify the source archive and expected checksum before continuing.

### Missing build dependency

Install the packages listed by the installer, then rerun the command.

### Permission problems

APT installation requires `sudo`. Source installation into `/usr/local` also requires elevated privileges during installation.

### Python already installed

If the target version is already installed:

```text
Version comparison: SAME
Nothing to install.
```

This is expected idempotent behavior.

## Example Workflow

```bash
cd ~/python-installer
```

Syntax check:

```bash
bash -n python-installer.sh
```

Run tests:

```bash
./test-installations.sh
```

APT installation:

```bash
./python-installer.sh     --version 3.12     --method package
```

Tarball installation:

```bash
./python-installer.sh     --version 3.13.7     --method tarball     --sha256 <SHA256_CHECKSUM>
```

Automatic installation:

```bash
./python-installer.sh     --version 3.13.7     --method auto     --sha256 <SHA256_CHECKSUM>
```

Review logs:

```bash
cat logs/python-installer.log
```

## Security Notes

- Use a trusted Python source URL.
- Always verify SHA256 for source tarballs.
- Do not disable checksum verification.
- Never commit private keys, passwords, tokens, or other secrets.
- Avoid committing large source archives, logs, or temporary build directories unless explicitly required.
- Review scripts before executing commands with `sudo`.

## Final Verification Checklist

- [ ] `python-installer.sh` is executable
- [ ] `test-installations.sh` is executable
- [ ] `bash -n python-installer.sh` passes
- [ ] Package method works
- [ ] Auto method works
- [ ] Tarball method detects existing installations
- [ ] SHA256 verification works
- [ ] Invalid versions are rejected
- [ ] Invalid methods are rejected
- [ ] Logs are generated
- [ ] Existing installations are not unnecessarily rebuilt
- [ ] Python runtime verification succeeds

## Final Repository

The final repository should primarily contain:

```text
python-installer/
├── python-installer.sh
├── test-installations.sh
└── installation.md
```

Development backups, downloaded source archives, extracted source trees, logs, and temporary build files should normally remain outside the final repository unless explicitly required by the ticket.
