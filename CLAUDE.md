# Claude Instructions for raylib-hemlock

## Getting Hemlock

This project requires the Hemlock programming language interpreter. To get Hemlock:

```bash
# Clone the Hemlock repository
git clone https://github.com/hemlang/hemlock.git

# Build Hemlock (follow instructions in the hemlock repo)
cd hemlock
# Build commands depend on the hemlock project structure - check its README
```

## Project Overview

This is a raylib bindings library for Hemlock using FFI. The main bindings are in `src/raylib.hml`.

## Running Examples

Examples require:
1. Hemlock interpreter installed and in PATH
2. raylib library installed on the system

```bash
hemlock examples/hello_window.hml
hemlock examples/input_demo.hml
hemlock examples/animation.hml
```

## Running Tests

```bash
./tests/run_tests.sh /path/to/hemlock
```

## Key Files

- `src/raylib.hml` - Core raylib FFI bindings and utility functions
- `examples/` - Example Hemlock programs using raylib
- `tests/` - Test suite for utility functions
