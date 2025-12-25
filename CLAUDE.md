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

### FFI Struct Support
Hemlock now has FFI struct support. The bindings define these structs that match raylib's C structures:

**2D Types:** `Vector2`, `Vector3`, `Vector4`, `Rectangle`, `Camera2D`
**3D Types:** `Camera3D`, `Matrix`, `Ray`, `RayCollision`, `BoundingBox`
**Textures:** `Texture2D`, `Image`, `RenderTexture2D`
**Text:** `Font`, `GlyphInfo`
**Audio:** `Sound`, `Music`
**Colors:** `ColorStruct`

**Important: Struct types are auto-imported.** When you import anything from the raylib module, all struct types become globally available. Do NOT include them in the import list:

```hemlock
// GOOD - struct types are auto-available after any import
import { InitWindow, DrawCircleV, RED } from "hemlang/raylock";

// Create a Vector2 - the type is already available
let pos: Vector2 = { x: 100.0, y: 200.0 };

// Create a Rectangle
let bounds: Rectangle = { x: 0.0, y: 0.0, width: 800.0, height: 450.0 };

// Use with drawing functions
DrawCircleV(pos, 50.0, RED);
DrawRectangleRec(bounds, BLUE);
DrawTriangle({ x: 100.0, y: 200.0 }, { x: 150.0, y: 100.0 }, { x: 50.0, y: 100.0 }, GREEN);
```

```hemlock
// BAD - do NOT try to explicitly import struct types
import { Vector2, Rectangle } from "hemlang/raylock";  // Error: Undefined variable 'Vector2'
```

**Important: Counter-Clockwise Winding Order for Triangles**

Filled triangles require vertices in counter-clockwise (CCW) order:

```hemlock
// CCW order for upward-pointing triangle (tip at top)
let v1: Vector2 = { x: 50.0, y: 200.0 };   // bottom-left
let v2: Vector2 = { x: 150.0, y: 200.0 };  // bottom-right
let v3: Vector2 = { x: 100.0, y: 100.0 };  // top
DrawTriangle(v1, v2, v3, GREEN);
```

### ARM64 Float Parameter Bug
On ARM64 Macs (Apple Silicon), Hemlock's FFI may not correctly pass float parameters to some C functions. If drawing functions with floats don't work, use the integer-based helpers:

```hemlock
// If DrawCircle doesn't render on ARM64:
DrawCircleFill(200, 200, 50, RED);      // pixel-based, takes ints
DrawCircleOutline(200, 200, 50, GREEN); // circle outline
```

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

## 3D Graphics Support

The bindings include full 3D graphics support:

### Camera3D

```hemlock
import { BeginMode3D, EndMode3D, DrawCube, DrawGrid, CAMERA_PERSPECTIVE } from "hemlang/raylock";

// Create a 3D camera
let camera: Camera3D = {
    position: { x: 10.0, y: 10.0, z: 10.0 },
    target: { x: 0.0, y: 0.0, z: 0.0 },
    up: { x: 0.0, y: 1.0, z: 0.0 },
    fovy: 45.0,
    projection: CAMERA_PERSPECTIVE
};

// In your render loop:
BeginMode3D(camera);
DrawCube({ x: 0.0, y: 0.0, z: 0.0 }, 2.0, 2.0, 2.0, RED);
DrawGrid(10, 1.0);
EndMode3D();
```

### 3D Shapes
- `DrawCube`, `DrawCubeV`, `DrawCubeWires`
- `DrawSphere`, `DrawSphereEx`, `DrawSphereWires`
- `DrawCylinder`, `DrawCylinderEx`, `DrawCylinderWires`
- `DrawCapsule`, `DrawCapsuleWires`
- `DrawPlane`, `DrawGrid`, `DrawRay`
- `DrawLine3D`, `DrawPoint3D`, `DrawCircle3D`, `DrawTriangle3D`

### 3D Collision Detection
- `CheckCollisionSpheres`, `CheckCollisionBoxes`, `CheckCollisionBoxSphere`
- `GetRayCollisionSphere`, `GetRayCollisionBox`, `GetRayCollisionTriangle`, `GetRayCollisionQuad`

## Shader Support

```hemlock
import { LoadShader, BeginShaderMode, EndShaderMode, SetShaderValue, SHADER_UNIFORM_FLOAT } from "hemlang/raylock";

let shader = LoadShader("vertex.glsl", "fragment.glsl");
let timeLoc = GetShaderLocation(shader, "time");

// In render loop:
BeginShaderMode(shader);
// Draw with shader...
EndShaderMode();

// Don't forget to unload:
UnloadShader(shader);
```

## Spline Drawing

Draw smooth curves using splines:

```hemlock
import { DrawSplineLinear, DrawSplineCatmullRom, DrawSplineBezierCubic } from "hemlang/raylock";

// Points array (needs to be allocated and filled)
// DrawSplineLinear(points, pointCount, 2.0, RED);
// DrawSplineCatmullRom(points, pointCount, 2.0, GREEN);
// DrawSplineBezierCubic(points, pointCount, 2.0, BLUE);

// Or get points along a spline for custom use:
let point = GetSplinePointLinear(startPos, endPos, 0.5);  // t=0.5 means halfway
```

## Camera2D for Scrolling/Zooming

```hemlock
import { BeginMode2D, EndMode2D, GetScreenToWorld2D, GetWorldToScreen2D } from "hemlang/raylock";

let camera: Camera2D = {
    offset: { x: 400.0, y: 300.0 },  // Center of screen
    target: { x: 0.0, y: 0.0 },       // What we're looking at
    rotation: 0.0,
    zoom: 1.0
};

// In render loop:
BeginMode2D(camera);
// Draw world objects here - they will be affected by camera
DrawCircleV({ x: 0.0, y: 0.0 }, 50.0, RED);
EndMode2D();

// Convert mouse position to world coordinates:
let worldPos = GetScreenToWorld2D(GetMousePosition(), camera);
```

## Text Utilities

```hemlock
import { TextLength, TextToUpper, TextToLower, TextFindIndex, TextToInteger } from "hemlang/raylock";

let len = TextLength("Hello");  // 5
let upper = TextToUpper("hello");  // "HELLO"
let lower = TextToLower("HELLO");  // "hello"
let idx = TextFindIndex("Hello World", "World");  // 6
let num = TextToInteger("42");  // 42
```

## Native Color Functions

```hemlock
import { Fade, ColorToHSV, ColorFromHSV, ColorLerp } from "hemlang/raylock";

let transparent = Fade(RED, 0.5);  // RED with 50% alpha
let hsv = ColorToHSV(RED);  // Get hue, saturation, value
let color = ColorFromHSV(0.0, 1.0, 1.0);  // Pure red from HSV
let blend = ColorLerp(RED, BLUE, 0.5);  // Blend between colors
```

## Extended rlgl Functions

For custom low-level rendering:

```hemlock
import {
    rlPushMatrix, rlPopMatrix, rlTranslatef, rlRotatef, rlScalef,
    rlEnableDepthTest, rlDisableDepthTest,
    rlEnableWireMode, rlDisableWireMode
} from "hemlang/raylock";

// Transform stack
rlPushMatrix();
rlTranslatef(100.0, 100.0, 0.0);
rlRotatef(45.0, 0.0, 0.0, 1.0);
// Draw something...
rlPopMatrix();

// Toggle wireframe mode
rlEnableWireMode();
// Draw shapes as wireframes...
rlDisableWireMode();
```
