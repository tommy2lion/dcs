#!/usr/bin/env bash
# build.sh — one-shot build for both dcs_cli.exe and dcs_gui.exe.
#
# Usage:
#   ./build.sh              # release build (-O2)        — default
#   ./build.sh release      # release build (-O2)        — explicit
#   ./build.sh debug        # debug build (-g -O0 -DDEBUG)
#   ./build.sh clean        # remove build artefacts
#   ./build.sh test         # run the full test suite
#   ./build.sh package      # release build + portable zip (Windows)
#   ./build.sh -h           # this help
#
# Reads DCS_BUILD_SALT from `.env` if present (see .env.example).
# Override on the command line:  ./build.sh release  (then) make DCS_BUILD_SALT=x cli
# or copy/edit .env per the .env.example documentation.
#
# Pure wrapper around `make` — does nothing the Makefile can't do directly.

set -euo pipefail

mode="${1:-release}"
# State file remembers the last successful build mode. On mode switch we
# pass -B so make recompiles everything against the new CFLAGS (CFLAGS
# values aren't in make's dependency graph, so an incremental build would
# silently keep the previous mode's objects).
STATE_FILE=".build_mode"
last_mode="$(cat "$STATE_FILE" 2>/dev/null || true)"
force_flag=""
if [ "$mode" != "$last_mode" ] && [ "$mode" != "clean" ] && [ "$mode" != "test" ] \
   && [ "$mode" != "package" ] \
   && [ "$mode" != "-h" ] && [ "$mode" != "--help" ] && [ "$mode" != "help" ]; then
    force_flag="-B"
fi
# `package` builds release internally — line up the state file accordingly.
if [ "$mode" = "package" ] && [ "$last_mode" != "release" ]; then
    force_flag="-B"
fi

print_help() {
    sed -n '2,17p' "$0"
}

print_built() {
    echo
    echo "==> built (mode: $mode)"
    ls -lh dcs_cli.exe dcs_gui.exe 2>/dev/null || true
    echo
    if [ -x ./dcs_cli.exe ]; then ./dcs_cli.exe --version; fi
}

case "$mode" in
    release)
        echo "==> release build${force_flag:+ ($force_flag — mode changed since last build)}"
        make $force_flag cli
        make $force_flag gui
        echo "$mode" > "$STATE_FILE"
        print_built
        ;;
    debug)
        echo "==> debug build${force_flag:+ ($force_flag — mode changed since last build)}"
        DBG='CFLAGS=-Wall -Wextra -g -O0 -std=c99 -DDEBUG'
        make $force_flag "$DBG" cli
        make $force_flag "$DBG" gui
        echo "$mode" > "$STATE_FILE"
        print_built
        ;;
    clean)
        make clean
        rm -f "$STATE_FILE"
        ;;
    test)
        make test
        ;;
    package)
        # Portable Windows release: dcs_cli.exe + dcs_gui.exe + the two
        # raylib DLLs + user-facing docs + the curated circuits gallery,
        # all bundled into dcs-v<version>-windows-x86_64.zip in the repo
        # root. Users extract anywhere and run dcs_gui.exe directly — no
        # MSYS2 install required on the destination machine.
        echo "==> packaging portable Windows release"
        make $force_flag cli
        make $force_flag gui
        echo release > "$STATE_FILE"

        if [ ! -x ./dcs_cli.exe ]; then
            echo "error: dcs_cli.exe missing after build" >&2
            exit 1
        fi
        # --version prints "DCS X.Y.Z:date:commit:sig" — keep just X.Y.Z.
        version=$(./dcs_cli.exe --version | tr -d '\r' | cut -d: -f1 | awk '{print $2}')
        if [ -z "$version" ]; then
            echo "error: could not extract version from --version output" >&2
            exit 1
        fi

        stage="dcs-v${version}-windows-x86_64"
        zip="${stage}.zip"
        echo "==> staging into ${stage}/"
        rm -rf "$stage" "$zip"
        mkdir -p "$stage"

        # Binaries + the two raylib DLLs the GUI needs at runtime.
        cp dcs_cli.exe dcs_gui.exe "$stage/"
        cp /c/msys64/mingw64/bin/libraylib.dll "$stage/"
        cp /c/msys64/mingw64/bin/glfw3.dll "$stage/"

        # User-facing docs and the demo gallery.
        cp README.md QUICKSTART.md INSTALL.md CHANGELOG.md LICENSE "$stage/"
        cp dcs.png "$stage/" 2>/dev/null || true
        cp -r circuits "$stage/"

        # Strip the script-generator dotfiles from the staged circuits dir.
        find "$stage/circuits" -maxdepth 1 -name '.*' -type f -print -delete

        echo "==> creating ${zip} via PowerShell Compress-Archive"
        if ! command -v powershell.exe >/dev/null 2>&1; then
            echo "error: powershell.exe not found — can't create zip" >&2
            exit 1
        fi
        # PowerShell needs Windows-style paths. Resolve via cygpath.
        win_stage=$(cygpath -w "$(pwd)/$stage")
        win_zip=$(cygpath -w "$(pwd)/$zip")
        powershell.exe -NoProfile -Command \
            "Compress-Archive -Path '${win_stage}' -DestinationPath '${win_zip}' -Force"

        # Keep the zip, drop the staging directory.
        rm -rf "$stage"

        echo
        ls -lh "$zip"
        echo
        echo "==> portable release ready: $zip"
        ;;
    -h|--help|help)
        print_help
        ;;
    *)
        echo "error: unknown mode '$mode'" >&2
        echo "usage: $0 [release|debug|clean|test|package|-h]" >&2
        exit 1
        ;;
esac
