# Python Installation - SOP

<p align="center">
  <img src="https://www.python.org/static/community_logos/python-logo-master-v3-TM-flattened.png" alt="Python Logo" width="300"/>
</p>

<p align="center">
  <img src="https://img.shields.io/badge/platform-linux-blue" />
  <img src="https://img.shields.io/badge/automation-supported-orange" />
  <img src="https://img.shields.io/badge/license-open--source-lightgrey" />
</p>

---

| Author       | Created On | Version | Last Updated By | Last Edited On | Pre Reviewer | L0 Reviewer | L1 Reviewer | L2 Reviewer  |
| ------------ | ---------- | ------- | --------------- | -------------- | ------------ | ----------- | ----------- | ------------ |
| Vashishtha Prakash | 31/08/2026 | 1.0     | Vashishtha Prakash    | 31/08/2026     | Team         | Sunny | Shreya/Nikita | Mahesh Kumar |

---

## Table of Contents

* [Introduction](#introduction)
* [Installation Methods Overview](#installation-methods-overview)
* [Why Multiple Installation Methods Matter](#why-multiple-installation-methods-matter)
* [Installation via Package Manager](#installation-via-package-manager)
* [Installation via Source (Tarball)](#installation-via-source-tarball)
* [Installation via Bash Automation](#installation-via-bash-automation)
* [Version Management](#version-management)
* [Best Practices](#best-practices)
* [Troubleshooting](#troubleshooting)
* [FAQs](#faqs)
* [References](#references)
* [Contact Information](#contact-information)

---

## Introduction

Python is an interpreted, high-level programming language known for its simplicity and wide range of use cases such as automation, backend development, and data processing. Installing Python is not just about running code—it is about setting up a reliable and consistent environment.

A proper installation approach helps avoid version conflicts, ensures smooth execution across systems, and supports DevOps practices like automation and environment isolation.

---

## Installation Methods Overview

| Method           | Description                         | Best Use Case                    | Complexity |
| ---------------- | ----------------------------------- | -------------------------------- | ---------- |
| Package Manager  | Installs Python via OS repositories | Quick setup, system environments | Low        |
| Tarball (Source) | Compile Python from source code     | Custom builds, version control   | Medium     |
| Bash Automation  | Script-based automated installation | CI/CD pipelines, repeatability   | High       |

---

## Why Multiple Installation Methods Matter

No single installation method fits all environments. Each approach serves a specific operational need:

* **Flexibility**: Different environments require different Python versions
* **Control**: Source builds enable fine-grained customization
* **Automation**: Scripts support CI/CD and repeatable deployments
* **Stability**: Prevents conflicts with system-level dependencies

Using multiple methods ensures the right balance of speed, control, and reliability.

---

## Installation via Package Manager

This is the most straightforward and widely used approach, leveraging the operating system's repository.

### Commands

```bash
sudo apt update
sudo apt install python3 python3-pip -y
```
><img width="1256" height="593" alt="Screenshot from 2026-04-21 16-31-34" src="https://github.com/user-attachments/assets/0366af2c-6e39-4dc2-8050-2e98981a853c" />


### Characteristics

| Aspect      | Details                 |
| ----------- | ----------------------- |
| Speed       | Fast                    |
| Stability   | High (tested packages)  |
| Flexibility | Limited version control |
| Maintenance | Managed via OS updates  |

---

## Installation via Source (Tarball)

This method provides full control over Python versions and build configurations.

### Commands

```bash
wget https://www.python.org/ftp/python/3.12.0/Python-3.12.0.tgz
tar -xvf Python-3.12.0.tgz
cd Python-3.12.0
./configure --enable-optimizations
make -j$(nproc)
sudo make altinstall
```
><img width="1041" height="471" alt="Screenshot from 2026-04-21 16-38-10" src="https://github.com/user-attachments/assets/b2738730-6f77-427c-9c2c-9b62b78f5a03" />

### Characteristics

| Aspect      | Details                        |
| ----------- | ------------------------------ |
| Control     | Full version and build control |
| Performance | Optimized builds possible      |
| Complexity  | Requires dependencies          |
| Risk        | Manual handling required       |

---

## Installation via Bash Automation

Automation scripts are essential for scaling installations across multiple systems.

### Example Script

><img width="1218" height="958" alt="image" src="https://github.com/user-attachments/assets/c2f00369-200d-45bf-b9d0-1fab83a51130" />


### Characteristics

| Aspect      | Details                            |
| ----------- | ---------------------------------- |
| Automation  | Fully automated                    |
| Reusability | High                               |
| Scalability | Suitable for large environments    |
| Consistency | Ensures identical setup everywhere |

---

## Version Management

```bash
python3 --version
update-alternatives --config python3
```
><img width="1177" height="343" alt="image" src="https://github.com/user-attachments/assets/c3f40d80-e01b-44e3-9257-c23600ac4c20" />


| Task                     | Command             |
| ------------------------ | ------------------- |
| Check version            | python3 --version   |
| Switch versions          | update-alternatives |
| Install alternate binary | make altinstall     |

---

## Best Practices

* Use virtual environments (venv) for project isolation
* Avoid modifying system Python binaries
* Prefer automation scripts for repeatability
* Maintain dependency documentation
* Validate installation in staging before production rollout

---

## Troubleshooting

| Issue            | Cause                   | Resolution                   |
| ---------------- | ----------------------- | ---------------------------- |
| Python not found | PATH misconfiguration   | Update environment variables |
| pip missing      | Incomplete installation | Install python3-pip          |
| Build failure    | Missing dependencies    | Install required libraries   |

---

## FAQs

**1. Which installation method should I use in production?**

> Use tarball or automated scripts to ensure version control and consistency.

**2. Why avoid modifying system Python?**

> System tools depend on it; changes may break OS functionality.

**3. What is the safest way to manage multiple versions?**

> Use altinstall or version managers to avoid conflicts.

**4. Is automation necessary for small environments?**

> Not mandatory, but recommended for consistency and scalability.

**5. How do I verify installation success?**

> Run python3 --version and pip3 --version.

---

## References

| Resource        | Link                                                                                   |
| --------------- | -------------------------------------------------------------------------------------- |
| Official Python | [https://www.python.org/downloads/](https://www.python.org/downloads/)                 |
| Documentation   | [https://docs.python.org/3/using/unix.html](https://docs.python.org/3/using/unix.html) |
| Guide           | [https://realpython.com/installing-python/](https://realpython.com/installing-python/) |

---

## Contact Information

| Name         | Email                                                                             |
| ------------ | --------------------------------------------------------------------------------- |
| Mukesh Kharb | [mukesh.Kharb.snaatak@mygurukulam.co](mailto:mukesh.Kharb.snaatak@mygurukulam.co) |

---
