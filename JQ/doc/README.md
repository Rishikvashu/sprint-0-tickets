# COMMON STACK | JQ | JQ Documentation

---

# Author Table

| **Author**         | **Created On** | **Version** | **Last Updated By** | **Last Edited On** | **L0 Reviewer** | **L1 Reviewer** | **L2 Reviewer** |
| ------------------ | -------------- | ----------- | ------------------- | ------------------ | --------------- | --------------- | --------------- |
| Vashishtha Prakash | 25-08-2026     | 1.0         | Vashishtha Prakash  | 25-08-2026         | TBD             | TBD             | TBD             |

---

# Table of Contents

1. [Introduction](#1-introduction)

2. [What is JQ](#2-what-is-jq)

3. [Why JQ is Required](#3-why-jq-is-required)

4. [JQ CI/CD Workflow](#4-jq-cicd-workflow)

   * [4.1 Workflow Diagram](#41-workflow-diagram)

5. [Different Tools for JSON Processing](#5-different-tools-for-json-processing)

6. [Tool Comparison](#6-tool-comparison)

7. [Advantages and Disadvantages](#7-advantages-and-disadvantages)

8. [Best Practices](#8-best-practices)

9. [Recommendation / Conclusion](#9-recommendation--conclusion)

10. [Proof of Concept (POC)](#10-proof-of-concept-poc)

11. [Contact Information](#11-contact-information)

12. [References](#12-references)

---

# 1. Introduction

**jq (JQ)** is a lightweight and flexible command-line JSON processor used to parse, filter, extract, transform, and format structured JSON data.

JQ is particularly useful in DevOps and CI/CD environments because many commonly used tools and services, such as REST APIs and cloud CLIs, return data in JSON format.

Instead of manually searching through large JSON responses, JQ allows engineers to select the required information using filters and expressions.

Typical use cases include:

* Extracting specific fields from JSON.
* Filtering JSON objects based on conditions.
* Processing JSON arrays.
* Transforming JSON into a required structure.
* Formatting JSON for better readability.
* Processing API responses.
* Extracting information from AWS CLI output.
* Using JSON data inside shell scripts and CI/CD pipelines.
* Validating and processing configuration or deployment-related JSON data.

The official JQ project describes jq as a lightweight command-line JSON processor that can slice, filter, map, and transform structured data.

---

# 2. What is JQ

JQ is a command-line utility designed specifically for processing JSON data.

The basic syntax is:

```bash
jq '<filter>' <input-file>
```

For example:

```bash
jq '.name' employee.json
```

Consider the following JSON:

```json
{
  "id": 101,
  "name": "Vashishtha",
  "department": "IT"
}
```

The command:

```bash
jq '.name' employee.json
```

produces:

```text
"Vashishtha"
```

Here:

| Component       | Description                               |
| --------------- | ----------------------------------------- |
| `jq`            | JSON processing command                   |
| `.name`         | JQ filter used to select the `name` field |
| `employee.json` | Input JSON file                           |

JQ works by accepting JSON input and applying a filter written in the JQ language. The filter determines how the input should be selected, transformed, or processed.

### Basic JQ Concepts

#### Current Input

The `.` filter represents the current input.

```bash
jq '.' employee.json
```

#### Field Extraction

A field can be accessed using `.fieldName`.

```bash
jq '.name' employee.json
```

#### Nested Field Access

Nested fields can be accessed by chaining field names.

```bash
jq '.employee.address.city' employee.json
```

#### Array Processing

The `[]` operator can be used to iterate over array elements.

```bash
jq '.employees[]' employees.json
```

#### Pipe Operator

The `|` operator allows multiple JQ filters to be chained.

```bash
jq '.employees[] | .name' employees.json
```

#### Filtering

The `select()` function can be used to select objects that satisfy a condition.

```bash
jq '.employees[] | select(.department == "IT")' employees.json
```

---

# 3. Why JQ is Required

Modern applications, cloud platforms, APIs, and DevOps tools frequently generate structured JSON output.

A JSON response can contain hundreds or thousands of lines, while an engineer may only need one or two values.

For example:

```bash
aws ec2 describe-instances
```

may return a large JSON response containing information about multiple EC2 instances.

If only instance IDs are required, JQ can extract them directly:

```bash
aws ec2 describe-instances \
  | jq -r '.Reservations[].Instances[].InstanceId'
```

This provides only the required information instead of requiring the engineer to manually inspect the complete JSON response.

### Problems Without JQ

* Large JSON responses are difficult to read.
* Required information may be difficult to locate manually.
* JSON filtering becomes difficult in shell scripts.
* Extracting nested values manually is inefficient.
* Automation scripts become more complicated.
* Data transformation requires additional scripting.

### Benefits of Using JQ

JQ provides:

* Structured JSON filtering.
* Field extraction.
* Array processing.
* Conditional selection.
* Data transformation.
* Sorting and aggregation.
* Raw output suitable for shell scripts.
* Easy integration with command-line tools.

Therefore, JQ is useful wherever structured JSON data needs to be processed from the command line.

---

# 4. JQ CI/CD Workflow

JQ itself is not a CI/CD platform. Instead, it can be used as a **JSON processing component inside a CI/CD pipeline**.

A typical workflow can be represented as:

```text
Developer
    |
    | Code Commit
    v
Source Code Repository
    |
    v
CI/CD Pipeline
    |
    +----------------------+
    |                      |
    v                      v
Build / Test          CLI / API Command
                           |
                           v
                      JSON Response
                           |
                           v
                          JQ
                           |
                           v
                  Extract / Filter /
                  Validate / Transform
                           |
                           v
                    CI Decision
                           |
                 +---------+---------+
                 |                   |
              Success              Failure
                 |                   |
                 v                   v
              Deploy             Stop / Report
```

### Example CI/CD Scenario

Suppose a CI pipeline calls an API that returns:

```json
{
  "status": "success",
  "environment": "production",
  "version": "1.8.2"
}
```

JQ can extract the deployment status:

```bash
jq -r '.status' response.json
```

The pipeline can then use the result to decide whether to continue.

For example:

```bash
STATUS=$(jq -r '.status' response.json)

if [ "$STATUS" = "success" ]; then
    echo "Validation successful"
else
    echo "Validation failed"
    exit 1
fi
```

This demonstrates how JQ can participate in automated CI/CD decision-making.

---

## 4.1 Workflow Diagram

<details>

<summary>Click to Expand JQ CI/CD Workflow Diagram</summary>

```text
+-------------------+
|     Developer     |
+---------+---------+
          |
          | Git Commit / Pull Request
          v
+-------------------+
| Source Repository |
+---------+---------+
          |
          v
+-------------------+
|   CI/CD Pipeline  |
+---------+---------+
          |
          +----------------------+
          |                      |
          v                      v
+-------------------+   +-------------------+
| Build / Test      |   | API / CLI Command |
+-------------------+   +---------+---------+
                                  |
                                  v
                         +-------------------+
                         |    JSON Output    |
                         +---------+---------+
                                  |
                                  v
                         +-------------------+
                         |        JQ         |
                         | Filter / Extract  |
                         | Transform / Check |
                         +---------+---------+
                                  |
                                  v
                         +-------------------+
                         | Pipeline Decision |
                         +---------+---------+
                                  |
                     +------------+------------+
                     |                         |
                     v                         v
                +---------+              +---------+
                | Success |              | Failure |
                +----+----+              +----+----+
                     |                        |
                     v                        v
                  Deploy                 Stop / Alert
```

</details>

---

# 5. Different Tools for JSON Processing

Several tools can be used to inspect or process structured data.

| **Tool**   | **Description**                                                                                                   |
| ---------- | ----------------------------------------------------------------------------------------------------------------- |
| **JQ**     | Command-line JSON processor for filtering, extracting, transforming, and processing JSON.                         |
| **yq**     | Command-line processor primarily designed for YAML, with support for JSON processing as well.                     |
| **fx**     | Interactive command-line JSON viewer and processor designed for exploring JSON data.                              |
| **Python** | General-purpose programming language that can parse and manipulate JSON using built-in and third-party libraries. |

### JQ

JQ is specifically designed around JSON processing and provides a compact filter language suitable for command-line automation.

### yq

yq is particularly useful when YAML is the primary format but JSON processing is also required.

### fx

fx provides an interactive terminal-oriented experience for exploring JSON.

### Python

Python provides much more general programming capabilities and can perform complex JSON processing, but requires more code than JQ for simple command-line transformations.

---

# 6. Tool Comparison

| **Tool**   | **Main Purpose**                  | **Speed** | **Ease of Use**    | **Best Use Case**                           |
| ---------- | --------------------------------- | --------- | ------------------ | ------------------------------------------- |
| **JQ**     | JSON filtering and transformation | Fast      | Easy for CLI users | DevOps, APIs, shell scripts, CI/CD          |
| **yq**     | YAML/JSON processing              | Fast      | Easy               | YAML-heavy DevOps workflows                 |
| **fx**     | Interactive JSON exploration      | Fast      | Easy               | Exploring and inspecting JSON interactively |
| **Python** | General-purpose data processing   | Fast      | Moderate           | Complex processing and automation           |

### Recommended Selection

For a workflow where the primary requirement is **JSON processing from the command line**, JQ is the most focused option.

For YAML-heavy environments, yq may be more appropriate.

For interactive exploration, fx can be useful.

For complex business logic or large automation scripts, Python may be preferable.

---

# 7. Advantages and Disadvantages

| **Advantages**                                              | **Disadvantages**                                                                      |
| ----------------------------------------------------------- | -------------------------------------------------------------------------------------- |
| Lightweight command-line tool                               | Requires learning JQ filter syntax                                                     |
| Designed specifically for JSON                              | Not a replacement for a general-purpose programming language                           |
| Fast for common JSON processing tasks                       | Complex transformations can become difficult to maintain                               |
| Works well with shell scripts and CLI tools                 | Very large or highly complex processing may be better suited to dedicated applications |
| Supports filtering, transformation, arrays, and aggregation | YAML is not its primary format                                                         |
| Useful in DevOps and CI/CD automation                       | Incorrect filters can produce unexpected results                                       |

---

# 8. Best Practices

| **Best Practice**                                   | **Description**                                                                                     |
| --------------------------------------------------- | --------------------------------------------------------------------------------------------------- |
| **Use `-r` when shell-friendly output is required** | Use raw output when passing string values into shell variables or commands.                         |
| **Keep filters simple and readable**                | Break complex filters into understandable stages using the pipe operator.                           |
| **Validate expected JSON structure**                | Ensure the input contains the fields expected by the JQ filter.                                     |
| **Use explicit filters**                            | Select only the required fields instead of processing unnecessary data.                             |
| **Handle errors in CI/CD scripts**                  | Ensure that JQ failures or unexpected values cause the pipeline to respond appropriately.           |
| **Pin or standardize JQ versions**                  | Use a consistent JQ version across CI environments to reduce compatibility issues.                  |
| **Avoid exposing sensitive JSON values**            | Do not unnecessarily print credentials, tokens, secrets, or other sensitive information in CI logs. |
| **Test filters before pipeline integration**        | Verify JQ expressions against representative JSON input before using them in production pipelines.  |

---

# 9. Recommendation / Conclusion

JQ is recommended for **command-line JSON processing**, particularly in DevOps, automation, API integration, AWS CLI workflows, and CI/CD pipelines.

Its main strength is that it provides a concise way to:

* Read JSON.
* Extract fields.
* Process arrays.
* Filter records.
* Transform JSON.
* Sort and aggregate data.
* Integrate JSON processing into shell scripts.
* Consume JSON output from APIs and CLI tools.

For simple to moderately complex JSON processing requirements, JQ is generally preferable to writing a custom script because it is lightweight, focused, and designed specifically for structured JSON data.

For highly complex processing involving business logic, external APIs, error handling, or extensive application logic, a general-purpose programming language such as Python may be more appropriate.

---

# 10. Proof of Concept (POC)

A separate Proof of Concept will be created to demonstrate the practical implementation of **JQ**.

The POC will cover:

1. JQ installation and version verification.
2. Creating and reading JSON files.
3. Basic JQ filters.
4. Field extraction.
5. Nested JSON processing.
6. Array processing.
7. Filtering with `select()`.
8. Pipe-based filter chaining.
9. JSON transformation.
10. Raw output using `-r`.
11. JQ with `curl`.
12. JQ with AWS CLI.
13. JQ usage in a CI/CD shell script.

[Click here to view the JQ POC](POC_URL)

---

# 11. Contact Information

| **Name**           | **Email** |
| ------------------ | --------- |
| Vashishtha Prakash | vashishtha123456789@gmail.com   |

---

# 12. References

| **Topic**                                            | **Description**                                                                   |
| ---------------------------------------------------- | --------------------------------------------------------------------------------- |
| [JQ Official Documentation](https://jqlang.org/)     | Official documentation and resources for the JQ JSON processor.                   |
| [JQ GitHub Repository](https://github.com/jqlang/jq) | Canonical source repository for the JQ implementation.                            |
| [JQ Manual](https://jqlang.org/manual/)              | Reference for JQ syntax, filters, functions, operators, and command-line options. |
| [JQ Releases](https://github.com/jqlang/jq/releases) | Official JQ release history and release assets.                                   |

JQ is maintained under the **jqlang** organization, which identifies `jqlang/jq` as the canonical source repository for the C implementation of JQ.

The current release information should be checked from the official release page before standardizing a version in a CI environment.
