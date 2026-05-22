# Installing DCS

DCS currently builds on Windows via MSYS2. Linux support is on the
roadmap (v1.1.0).

## Windows (MSYS2)

1. Install [MSYS2](https://www.msys2.org/) and open the **MSYS2 MinGW64**
   shell.
2. Install the toolchain and raylib:
   ```
   pacman -S --needed mingw-w64-x86_64-gcc mingw-w64-x86_64-make mingw-w64-x86_64-raylib
   ```
3. Clone this repo and `cd` into the `dcs/` directory.
4. Build:
   ```
   ./build.sh
   ```
   Two binaries land in the project root:
   - `dcs_gui.exe` — the GUI editor (raylib window).
   - `dcs_cli.exe` — the headless simulator (prints truth tables).

Run `./build.sh -h` for debug / clean / test / package modes. The
Makefile is the underlying build system; `make test` runs the full
suite (931 tests as of v1.0.0).

## Packaging a portable release

```
./build.sh package
```

builds the release binaries and zips them together with the two
required raylib DLLs (`libraylib.dll`, `glfw3.dll`), the user-facing
docs, and the curated `circuits/` gallery into
`dcs-v<version>-windows-x86_64.zip`. The zip is self-contained: any
Windows machine can extract it and run `dcs_gui.exe` without
installing MSYS2 or raylib.

## Optional — personal build salt

Copy `.env.example` to `.env` and edit `DCS_BUILD_SALT` if you want
the tamper signature embedded in the binary to use your own salt
instead of the default. See the comments in `.env.example` for
precedence rules.

## Verifying the build

```
./dcs_cli.exe --version
```

should print the version string followed by the build date, commit
hash, and tamper signature.

## Next steps

See [QUICKSTART.md](./QUICKSTART.md) to draw and simulate your first
circuit.
