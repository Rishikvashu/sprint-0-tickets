#!/bin/bash

set -euo pipefail

VERSION=""
METHOD=""
SHA256=""
UPGRADE=false
KEEP_BUILD=false

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_DIR="${SCRIPT_DIR}/logs"
LOG_FILE="${LOG_DIR}/python-installer.log"


# ---------------------------------------------------------
# Logging
# ---------------------------------------------------------

mkdir -p "$LOG_DIR"

log() {

    local level="$1"
    shift

    local message="$*"
    local timestamp

    timestamp="$(date '+%Y-%m-%d %H:%M:%S')"

    echo "${timestamp} [${level}] ${message}" >> "$LOG_FILE"

    echo "${message}"
}


info() {

    log "INFO" "$@"
}


warn() {

    log "WARN" "$@"
}


error() {

    log "ERROR" "$@"

    exit 1
}


# ---------------------------------------------------------
# Cleanup
# ---------------------------------------------------------

BUILD_DIR=""

cleanup() {

    local exit_code=$?

    if [[ -n "$BUILD_DIR" && -d "$BUILD_DIR" ]]; then

        if [[ "$KEEP_BUILD" == false && "$exit_code" -eq 0 ]]; then

            info "Cleaning build directory: $BUILD_DIR"

            rm -rf "$BUILD_DIR"

            info "Build directory cleaned."

        elif [[ "$KEEP_BUILD" == true ]]; then

            info "Keeping build directory: $BUILD_DIR"

        elif [[ "$exit_code" -ne 0 ]]; then

            warn "Installation failed."

            warn "Build directory preserved for debugging: $BUILD_DIR"

        fi

    fi

    exit "$exit_code"
}

trap cleanup EXIT


# ---------------------------------------------------------
# Usage
# ---------------------------------------------------------

usage() {

    echo
    echo "Python Installer"
    echo
    echo "Usage:"
    echo "  $0 --version <version> --method <package|tarball|auto> [options]"
    echo
    echo "Options:"
    echo "  --version <version>     Python version"
    echo "  --method <method>       package, tarball or auto"
    echo "  --sha256 <checksum>     SHA256 for tarball"
    echo "  --upgrade               Upgrade existing installation"
    echo "  --keep-build            Keep temporary build directory"
    echo "  --help                  Show help"
    echo
    echo "Examples:"
    echo
    echo "  $0 --version 3.12 --method package"
    echo
    echo "  $0 --version 3.12 --method package --upgrade"
    echo
    echo "  $0 --version 3.13.7 --method tarball \\"
    echo "      --sha256 <checksum>"
    echo
    echo "  $0 --version 3.13.7 --method auto \\"
    echo "      --sha256 <checksum>"
    echo

    exit 1
}


# ---------------------------------------------------------
# Validation
# ---------------------------------------------------------

validate_version() {

    if [[ ! "$VERSION" =~ ^3\.[0-9]+(\.[0-9]+)?$ ]]; then

        error "Invalid Python version: $VERSION. Expected 3.x or 3.x.y"

    fi
}


validate_method() {

    case "$METHOD" in

        package|tarball|auto)
            ;;

        *)
            error "Unsupported method '$METHOD'. Supported methods: package, tarball, auto"
            ;;

    esac
}


validate_sha256() {

    if [[ -z "$SHA256" ]]; then

        error "SHA256 checksum is required for tarball installation."

    fi


    if [[ ! "$SHA256" =~ ^[a-fA-F0-9]{64}$ ]]; then

        error "Invalid SHA256 checksum format. Expected exactly 64 hexadecimal characters."

    fi
}


# ---------------------------------------------------------
# Dependency checking
# ---------------------------------------------------------

check_required_commands() {

    info "Checking required commands..."

    local commands=(
        gcc
        make
        tar
        wget
        sha256sum
    )

    local command_name

    for command_name in "${commands[@]}"; do

        if command -v "$command_name" >/dev/null 2>&1; then

            info "$command_name: OK"

        else

            error "Required command '$command_name' is missing."

        fi

    done

    info "Required commands are available."
}


check_build_packages() {

    info "Checking Python build libraries..."

    local packages=(
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
    )

    local package
    local missing_packages=()

    for package in "${packages[@]}"; do

        if dpkg-query -W -f='${Status}' "$package" 2>/dev/null \
            | grep -q "install ok installed"; then

            info "$package: OK"

        else

            warn "$package: MISSING"

            missing_packages+=("$package")

        fi

    done


    if [[ ${#missing_packages[@]} -gt 0 ]]; then

        echo
        echo "Missing build packages:"
        printf '  %s\n' "${missing_packages[@]}"

        echo
        echo "Install them with:"
        echo
        echo "sudo apt update"
        echo "sudo apt install -y ${missing_packages[*]}"
        echo

        error "Required Python build libraries are missing."

    fi


    info "Python build libraries are available."
}


check_tarball_dependencies() {

    check_required_commands

    check_build_packages
}


# ---------------------------------------------------------
# Version handling
# ---------------------------------------------------------

compare_versions() {

    local installed="$1"
    local target="$2"


    if [[ "$installed" == "$target" ]]; then

        echo "SAME"

        return 0

    fi


    if [[ "$(printf '%s\n' "$installed" "$target" | sort -V | tail -n1)" == "$target" ]]; then

        echo "UPGRADE"

    else

        echo "DOWNGRADE"

    fi
}


get_installed_version() {

    local binary="$1"

    "$binary" --version | awk '{print $2}'
}


# ---------------------------------------------------------
# APT
# ---------------------------------------------------------

check_package() {

    local package="python${VERSION}"


    if apt-cache show "$package" >/dev/null 2>&1; then

        info "Package $package is available in APT."

        return 0

    fi


    info "Package $package is NOT available in APT."

    return 1
}


install_from_package() {

    local package="python${VERSION}"


    if command -v "$package" >/dev/null 2>&1; then

        local installed_version

        installed_version=$(get_installed_version "$(command -v "$package")")


        info "$package is already installed."
        info "Installed version: $installed_version"


        if [[ "$UPGRADE" == false ]]; then

            info "Nothing to install."

            return 0

        fi


        info "Upgrade requested."

        sudo apt update

        sudo apt install --only-upgrade -y "$package"


        info "Verifying Python installation..."

        "$package" --version

        return 0

    fi


    info "Python $VERSION is not installed."

    info "Installing $package using APT..."

    sudo apt update

    sudo apt install -y "$package"


    info "Installation completed."

    "$package" --version
}


# ---------------------------------------------------------
# Tarball
# ---------------------------------------------------------

install_from_tarball() {

    local filename="Python-${VERSION}.tgz"

    local url="https://www.python.org/ftp/python/${VERSION}/${filename}"

    BUILD_DIR="/tmp/python-build-${VERSION}"

    local python_binary="/usr/local/bin/python${VERSION%.*}"


    info "Tarball installation selected."
    info "Target version: ${VERSION}"


    # Existing installation check

    if [[ -x "$python_binary" ]]; then

        local installed_version

        installed_version=$(get_installed_version "$python_binary")


        info "Existing Python found: $installed_version"


        local comparison

        comparison=$(compare_versions "$installed_version" "$VERSION")


        info "Version comparison: $comparison"


        case "$comparison" in

            SAME)

                info "Python ${VERSION} is already installed."

                if [[ "$UPGRADE" == true ]]; then

                    info "Upgrade requested, but target version is already installed."

                fi

                info "Nothing to install."

                return 0
                ;;


            DOWNGRADE)

                error "Target version ${VERSION} is older than installed version ${installed_version}. Downgrade is not supported."
                ;;


            UPGRADE)

                if [[ "$UPGRADE" == false ]]; then

                    error "A newer target version ${VERSION} is requested. Use --upgrade."

                fi

                info "Upgrade required: ${installed_version} → ${VERSION}"
                ;;

        esac

    else

        info "Python ${VERSION} is not currently installed."

    fi


    # Validate checksum

    validate_sha256


    # Build dependencies

    check_tarball_dependencies


    # Create build directory

    mkdir -p "$BUILD_DIR"

    info "Build directory: $BUILD_DIR"

    cd "$BUILD_DIR"


    # Download

    info "Downloading Python ${VERSION}..."

    if [[ ! -f "$filename" ]]; then

        wget -q --show-progress "$url" -O "$filename"

    else

        info "Tarball already downloaded."

    fi


    if [[ ! -s "$filename" ]]; then

        error "Downloaded tarball is empty."

    fi


    # Verify checksum

    info "Verifying SHA256 checksum..."

    if ! echo "${SHA256}  ${filename}" | sha256sum -c -; then

        error "SHA256 verification failed. The tarball will not be built."

    fi


    info "Checksum verification successful."


    # Extract

    if [[ ! -d "Python-${VERSION}" ]]; then

        info "Extracting Python source..."

        tar -xzf "$filename"

    else

        info "Source directory already exists."

    fi


    cd "Python-${VERSION}"


    # Configure

    info "Configuring Python..."

    ./configure --prefix=/usr/local


    # Build

    info "Building Python using $(nproc) CPU cores..."

    make -j"$(nproc)"


    # Install

    info "Installing Python..."

    sudo make altinstall


    # Verify

    info "Verifying installation..."

    "$python_binary" --version


    info "Python ${VERSION} installation completed successfully."
}


# ---------------------------------------------------------
# Auto
# ---------------------------------------------------------

install_auto() {

    info "Automatic installation method selected."


    if check_package; then

        info "APT package found."
        info "Using package manager."

        install_from_package

        return 0

    fi


    info "APT package not available."
    info "Falling back to tarball installation."

    install_from_tarball
}


# ---------------------------------------------------------
# Main
# ---------------------------------------------------------

main() {

    if [[ $# -eq 0 ]]; then

        usage

    fi


    while [[ $# -gt 0 ]]; do

        case "$1" in

            --version)

                if [[ $# -lt 2 ]]; then

                    error "--version requires a value."

                fi

                VERSION="$2"

                shift 2
                ;;


            --method)

                if [[ $# -lt 2 ]]; then

                    error "--method requires a value."

                fi

                METHOD="$2"

                shift 2
                ;;


            --sha256)

                if [[ $# -lt 2 ]]; then

                    error "--sha256 requires a value."

                fi

                SHA256="$2"

                shift 2
                ;;


            --upgrade)

                UPGRADE=true

                shift
                ;;


            --keep-build)

                KEEP_BUILD=true

                shift
                ;;


            --help)

                usage
                ;;


            *)

                error "Unknown argument: $1"

                ;;

        esac

    done


    if [[ -z "$VERSION" ]]; then

        error "Python version is required."

    fi


    if [[ -z "$METHOD" ]]; then

        error "Installation method is required."

    fi


    validate_version

    validate_method


    info "----------------------------------------"
    info "Python installer started"
    info "Target version: $VERSION"
    info "Method: $METHOD"
    info "Upgrade: $UPGRADE"
    info "Keep build: $KEEP_BUILD"
    info "----------------------------------------"


    case "$METHOD" in

        package)

            check_package

            install_from_package
            ;;


        tarball)

            install_from_tarball
            ;;


        auto)

            install_auto
            ;;

    esac


    info "Python installer finished successfully."
}


main "$@"
