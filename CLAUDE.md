# Claude Instructions for raylock

## Installation

Install raylock as a Hemlock module:

```bash
hpm install hemlang/raylock
```

**Prerequisites:**
- Hemlock interpreter installed and in PATH
- raylib library installed on the system

## Usage

```hemlock
import {
    InitWindow, CloseWindow, WindowShouldClose,
    BeginDrawing, EndDrawing, ClearBackground,
    DrawText, RED, RAYWHITE
} from "hemlang/raylock";

InitWindow(800, 450, "Hello Raylock");

while (WindowShouldClose() == 0) {
    BeginDrawing();
    ClearBackground(RAYWHITE);
    DrawText("Hello from raylock!", 190, 200, 20, RED);
    EndDrawing();
}

CloseWindow();
```

## Project Overview

This is a raylib bindings library for Hemlock using FFI. The main bindings are in `src/raylib.hml`.

## Running Examples

Examples use relative imports for development. To run them:

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

- `package.json` - hpm module manifest
- `src/raylib.hml` - Core raylib FFI bindings and utility functions (module entry point)
- `src/raylib_loader.hml` - Cross-platform raylib library loader (macOS + Linux)
- `examples/` - Example Hemlock programs using raylib
- `tests/` - Test suite for utility functions

## Cross-Platform Support

The `src/raylib_loader.hml` module automatically detects the platform and loads raylib from common installation paths:

- **macOS (Apple Silicon)**: `/opt/homebrew/opt/raylib/lib/libraylib.dylib`
- **macOS (Intel)**: `/usr/local/lib/libraylib.dylib`
- **Linux**: `/usr/lib/libraylib.so`, `/usr/local/lib/libraylib.so`

Examples import the loader first, then define their extern functions.

## Hemlock Language Quirks

When writing Hemlock code for raylib, be aware of these quirks:

### No Block Scoping
Variables declared with `let` inside `if` blocks or `while` loops remain in scope for the rest of the function. You cannot redeclare a variable with the same name later in the function.

```hemlock
// BAD - will error "Variable 'i' already defined"
if (condition != 0) {
    let i = 0;
    // ...
}
let i = 0;  // Error!

// GOOD - use different variable names
if (condition != 0) {
    let i = 0;
    // ...
}
let j = 0;  // OK
```

### Function Return Type Syntax
Use `: type` not `-> type` for return types:

```hemlock
// GOOD
fn myFunc(x: i32): i32 {
    return x * 2;
}

// BAD - will not parse
fn myFunc(x: i32) -> i32 {
    return x * 2;
}
```

### String Type
Use `string` not `str` for string types.

### DrawTriangle Does NOT Work - Use DrawTriangleFill Instead
The raylib `DrawTriangle` function expects `Vector2` structs, but Hemlock's FFI cannot properly pass C structs. **Use `DrawTriangleFill` instead**, which is a helper function that uses low-level rlgl calls.

```hemlock
// BAD - DrawTriangle won't render (Vector2 struct issue)
DrawTriangle(100.0, 200.0, 50.0, 100.0, 150.0, 100.0, RED);

// GOOD - Use DrawTriangleFill helper
DrawTriangleFill(100.0, 200.0, 150.0, 100.0, 50.0, 100.0, RED);
```

**Important: Counter-Clockwise Winding Order Required**

Filled triangles require vertices in counter-clockwise (CCW) order. In screen coordinates (Y increases downward), for a triangle with tip at bottom:
- v1: bottom point
- v2: top-right point
- v3: top-left point

```hemlock
// CCW order for upward-pointing triangle (tip at top):
// bottom-left, bottom-right, top
DrawTriangleFill(50.0, 200.0, 150.0, 200.0, 100.0, 100.0, GREEN);

// CCW order for downward-pointing triangle (tip at bottom):
// bottom, top-right, top-left
DrawTriangleFill(100.0, 200.0, 150.0, 100.0, 50.0, 100.0, BLUE);
```

Also available: `DrawTriangleOutline` for triangle outlines.

### Type Mixing in Arithmetic
Be careful mixing `i32` and `f32` in arithmetic expressions passed directly to draw functions. Convert to the expected type first:

```hemlock
// Safer approach
let posX: i32 = myFloatX;  // Convert once
let posY: i32 = myFloatY;
DrawRectangle(posX - 10, posY - 10, 20, 20, RED);
```

### Integer Division - Use `divi` NOT `/`
The `/` operator in Hemlock always produces a float result. For integer division, use the `divi` function:

```hemlock
// BAD - / produces float, causes position bugs
let row = index / 10;        // Returns 1.1 for index=11, not 1
let centerX = width / 2;     // Returns float, not int

// GOOD - divi performs integer division
let row = divi(index, 10);   // Returns 1 for index=11
let centerX = divi(width, 2); // Returns integer result
```

This is critical for:
- Grid position calculations (row/column from index)
- Centering UI elements (screenWidth / 2)
- Level calculations in games (lines / 10)
- Any math where you need an integer result

### Available Colors
These colors are defined: `LIGHTGRAY`, `GRAY`, `DARKGRAY`, `YELLOW`, `GOLD`, `ORANGE`, `PINK`, `RED`, `MAROON`, `GREEN`, `LIME`, `DARKGREEN`, `SKYBLUE`, `BLUE`, `DARKBLUE`, `PURPLE`, `VIOLET`, `DARKPURPLE`, `BEIGE`, `BROWN`, `DARKBROWN`, `WHITE`, `BLACK`, `BLANK`, `MAGENTA`, `RAYWHITE`

Note: `CYAN` is NOT defined - use `SKYBLUE` instead.
