# Python | Linux | CI CHECK | Installation Documentation

---

# Author Table

| **Author** | **Created On** | **Version** | **Last Updated By** | **Last Edited On** | **L0 Reviewer** | **L1 Reviewer** | **L2 Reviewer** |
| ---------- | -------------- | ----------- | ------------------- | ----------------- | --------------- | --------------- | --------------- |
| Vashishtha Prakash | 25-08-2026 | 1.0 | Vashishtha Prakash | 25-08-2026 | — | — | — |

---

# Table of Contents

1. [Introduction](#1-introduction)
2. [What is Python Installation via Bash Script](#2-what-is-python-installation-via-bash-script)
3. [Why Python Installation via Bash Script is Required](#3-why-python-installation-via-bash-script-is-required)
4. [Python Installation Workflow](#4-python-installation-workflow)
   - [4.1 Workflow Diagram](#41-workflow-diagram)
5. [Different Methods for Python Installation](#5-different-methods-for-python-installation)
6. [Method Comparison](#6-method-comparison)
7. [Advantages and Disadvantages](#7-advantages-and-disadvantages)
8. [Best Practices](#8-best-practices)
9. [Recommendation / Conclusion](#9-recommendation--conclusion)
10. [Proof of Concept (POC)](#10-proof-of-concept-poc)
11. [Contact Information](#11-contact-information)
12. [References](#12-references)

---

# 1. Introduction

The SCRUM-11 task requires a **generic Bash script for Python installation** that supports:

- multiple Python versions
- installation
- upgrades
- tarball-based installation
- package-manager-based installation

The implementation developed for this task is `python-installer.sh`.

The script provides three selectable methods:

```text
package
tarball
auto
```

The implementation also includes validation, version comparison, checksum verification for source archives, dependency checks, logging, cleanup, and test support.

> **Scope note:** The ticket specifically identifies installation, multiple versions, upgrades, tarball, and package-manager support. Additional controls in the implementation are supporting engineering features for those requirements.

---

# 2. What is Python Installation via Bash Script

Python installation via a Bash script means automating the operating-system-level steps required to install a requested Python version instead of performing each step manually.

The script accepts the Python version and installation method as input and then performs the relevant installation flow.

High-level flow:

```text
User
 │
 ▼
Python Version + Installation Method
 │
 ▼
Input Validation
 │
 ▼
Installation Decision
 │
 ├───────────────┬────────────────┐
 ▼               ▼                ▼
Package        Tarball           Auto
 │               │                │
 ▼               ▼                ▼
APT          Source Build     APT Check
                                   │
                             ┌─────┴─────┐
                             ▼           ▼
                            APT       Tarball
```

Bash is used because the installation workflow directly interacts with Linux tools such as `apt`, `wget`, `sha256sum`, `make`, `gcc`, `tar`, and `sudo`.

---

# 3. Why Python Installation via Bash Script is Required

The ticket requires a **generic** installation utility rather than a one-off installation command.

A script-based approach provides a repeatable workflow for different Python versions and installation sources.

| **Ticket Requirement** | **Implementation** |
| ---------------------- | ------------------ |
| Generic Bash script | `python-installer.sh` |
| Installation | Package and tarball methods |
| Multiple Python versions | `--version` input and version-specific installation |
| Upgrades | `--upgrade` and version comparison |
| Tarball | Download, checksum validation, configure, build, and install |
| Package manager | APT |
| Automatic method selection | `--method auto` |

The implementation also avoids unnecessary reinstallation when the requested version is already present.

---

# 4. Python Installation Workflow

The installer follows a decision-driven workflow based on the requested version and method.

```text
                    ┌────────────────────────┐
                    │        User Input      │
                    │ Version + Method       │
                    └────────────┬───────────┘
                                 │
                                 ▼
                    ┌────────────────────────┐
                    │   Validate Parameters   │
                    └────────────┬───────────┘
                                 │
                                 ▼
                    ┌────────────────────────┐
                    │   Select Installation   │
                    │        Method           │
                    └────────────┬───────────┘
                                 │
             ┌───────────────────┼───────────────────┐
             │                   │                   │
             ▼                   ▼                   ▼
        📦 Package          📦 Tarball           🤖 Auto
             │                   │                   │
             ▼                   ▼                   ▼
            APT             Existing?          Check APT
             │                   │              /       \
             │                   │            YES       NO
             │                   │             │         │
             │                   │             ▼         ▼
             │                   │            APT     Tarball
             │                   │
             │                   ▼
             │              SHA256 Check
             │                   │
             │                   ▼
             │              Dependencies
             │                   │
             │                   ▼
             │                 Build
             │                   │
             └───────────────────┼─────────────────────┘
                                 ▼
                    ┌────────────────────────┐
                    │ Verify Installation    │
                    └────────────┬───────────┘
                                 │
                                 ▼
                    ┌────────────────────────┐
                    │ Logging + Cleanup      │
                    └────────────────────────┘
```

## 4.1 Workflow Diagram

<details>
<summary>🔽 Click to Expand Python Installation Workflow</summary>

```text
┌──────────────────────────────────────────────────────────────┐
│                  python-installer.sh                         │
├──────────────────────────────────────────────────────────────┤
│                                                              │
│  --version <version>                                         │
│  --method <package|tarball|auto>                             │
│  --sha256 <checksum>                                         │
│  --upgrade                                                   │
│  --keep-build                                                │
│                                                              │
└───────────────────────────────┬──────────────────────────────┘
                                │
                                ▼
                     🔎 Validate Input
                                │
                                ▼
                     🧭 Select Method
                                │
            ┌───────────────────┼───────────────────┐
            ▼                   ▼                   ▼
         📦 Package          📦 Tarball           🤖 Auto
            │                   │                   │
            │                   │          ┌────────┴────────┐
            │                   │          ▼                 ▼
            │                   │      APT found?       APT absent?
            │                   │          │                 │
            │                   │          ▼                 ▼
            │                   │         APT            Tarball
            │                   │
            │                   ▼
            │              🔐 SHA256
            │                   │
            │                   ▼
            │              🔧 Dependencies
            │                   │
            │                   ▼
            │               ⚙️ Configure
            │                   │
            │                   ▼
            │                🔨 Build
            │                   │
            │                   ▼
            │             📥 `make altinstall`
            │
            └───────────────────┬────────────────────────────┘
                                ▼
                         ✅ Verification
                                │
                                ▼
                         📝 Logging
                                │
                                ▼
                         🧹 Cleanup
```

</details>

---

# 5. Different Methods for Python Installation

## 📦 Package Manager

The package method uses APT to install a Python package available in the configured Ubuntu repositories.

Example:

```bash
./python-installer.sh \
    --version 3.12 \
    --method package
```

The implementation checks package availability using APT metadata before proceeding.

---

## 📦 Tarball

The tarball method downloads the requested Python source release and builds it locally.

Example:

```bash
./python-installer.sh \
    --version 3.13.7 \
    --method tarball \
    --sha256 <SHA256_CHECKSUM>
```

The flow is:

```text
Download
   ↓
SHA256 Verification
   ↓
Extract
   ↓
Configure
   ↓
Build
   ↓
`make altinstall`
   ↓
Verify
```

The source installation is placed under `/usr/local` and uses version-specific binaries such as:

```text
/usr/local/bin/python3.13
```

This avoids intentionally replacing the system-managed `/usr/bin/python3`.

---

## 🤖 Auto

The auto method checks APT first.

```bash
./python-installer.sh \
    --version 3.13.7 \
    --method auto \
    --sha256 <SHA256_CHECKSUM>
```

Decision:

```text
APT package available?
        │
    ┌───┴───┐
   YES      NO
    │        │
    ▼        ▼
   APT    Tarball
```

This reduces the need for the user to manually decide which installation mechanism should be used.

---

# 6. Method Comparison

| **Method** | **Main Purpose** | **Installation Source** | **Flexibility** | **Best Use Case** |
| ---------- | ---------------- | ------------------------ | ---------------- | ----------------- |
| 📦 Package | Standard repository installation | Ubuntu APT | Medium | Versions available in APT |
| 📦 Tarball | Source-based installation | Python source archive | High | Specific releases not available through APT |
| 🤖 Auto | Automatic selection | APT or source archive | High | Generic automated workflow |

---

# 7. Advantages and Disadvantages

| **Advantages** | **Disadvantages** |
| -------------- | ----------------- |
| ♻️ Repeatable installation process | 🔧 Tarball builds require compiler/build dependencies |
| 🐍 Supports multiple Python versions | ⏱️ Source compilation is slower than package installation |
| 📦 Supports package-manager installation | 📦 Available package versions depend on configured repositories |
| 📦 Supports source-tarball installation | 🔐 Tarball installation requires checksum management |
| 🤖 Auto method reduces manual decision-making | 🧩 Source installation has more operational steps |
| 🛡️ Avoids unnecessary reinstallation | ⚠️ Privileged installation is required under `/usr/local` |

---

# 8. Best Practices

| **Best Practice** | **Description** |
| ----------------- | --------------- |
| 🔎 Validate inputs | Reject unsupported versions and methods before performing system changes. |
| ♻️ Keep the script idempotent | Avoid unnecessary installation or rebuilding when the target version already exists. |
| 🔐 Verify source integrity | Validate SHA256 before extracting or compiling a downloaded source archive. |
| 🛡️ Protect system Python | Use version-specific installation behavior and `altinstall` for source builds. |
| 📝 Maintain logs | Keep execution records for troubleshooting and review. |
| 🧹 Clean temporary files | Remove successful build artifacts while preserving failed builds when debugging is required. |
| 🧪 Test positive and negative cases | Validate both successful workflows and expected failures. |
| 📚 Keep documentation aligned | Documentation and tests should reflect the actual implementation. |

---

# 9. Recommendation / Conclusion

For the SCRUM-11 requirement, the recommended operational entry point is:

```bash
./python-installer.sh \
    --version <version> \
    --method auto \
    --sha256 <SHA256_CHECKSUM>
```

The `auto` method provides a practical decision path:

```text
Requested version
      │
      ▼
APT package available?
   │           │
 YES           NO
   │            │
   ▼            ▼
 APT         Tarball
```

The explicit `package` and `tarball` modes remain available when the installation source is known in advance.

The implementation therefore addresses the ticket's stated requirements for:

```text
✅ Generic Bash script
✅ Installation
✅ Multiple Python versions
✅ Upgrades
✅ Tarball
✅ Package manager
```

Additional controls such as checksum verification, dependency checks, logging, cleanup, and tests provide supporting operational safeguards.

---

# 10. Proof of Concept (POC)

A Proof of Concept has been implemented through:

```text
python-installer.sh
```

### 📦 Package POC

```bash
./python-installer.sh \
    --version 3.12 \
    --method package
```

Verified behavior in the development environment:

```text
Package python3.12 is available in APT.
python3.12 is already installed.
Installed version: 3.12.3
Nothing to install.
```

### 📦 Tarball POC

Python 3.13.7 was built from source and installed separately.

Verification:

```bash
/usr/local/bin/python3.13 --version
```

Expected:

```text
Python 3.13.7
```

The source archive checksum was independently verified:

```bash
echo "6c9d80839cfa20024f34d9a6dd31ae2a9cd97ff5e980e969209746037a5153b2  Python-3.13.7.tgz" | sha256sum -c -
```

Expected:

```text
Python-3.13.7.tgz: OK
```

### 🤖 Auto POC

For Python 3.12:

```text
APT package found.
Using package manager.
```

For Python 3.13.7:

```text
APT package not available.
Falling back to tarball installation.
```

### 🧪 Test POC

Automated tests are located under:

```text
tests/test-installations.sh
```

Detailed testing documentation:

[Click here to view the Python Installation Test Documentation](../tests/README.md)

---

# 11. Contact Information

| **Name** | **Email** |
| -------- | --------- |
| Vashishtha Prakash | `<email>` |

---

# 12. References

| **Topic** | **Description** |
| --------- | --------------- |
| [Python Documentation](https://docs.python.org/3/) | Official Python documentation. |
| [Python Downloads](https://www.python.org/downloads/) | Official Python releases and downloads. |
| [Ubuntu Documentation](https://documentation.ubuntu.com/) | Official Ubuntu documentation. |
| [GNU Make](https://www.gnu.org/software/make/) | Documentation for the build tool used during source compilation. |
| [GNU Bash](https://www.gnu.org/software/bash/manual/) | Documentation for Bash scripting. |

---

<p align="center">

**🐍 Python Installation • Linux • Bash Automation • SCRUM-11**

</p>
