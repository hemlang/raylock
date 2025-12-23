# raylib-hemlock

Raylib bindings for the Hemlock programming language using FFI.

## Requirements

- [Hemlock](https://github.com/hemlang/hemlock) interpreter
- [raylib](https://www.raylib.com/) 5.0+

### Installing raylib

**macOS (Homebrew)**
```bash
brew install raylib
```

**Linux (Ubuntu/Debian)**
```bash
sudo apt install libraylib-dev
```

**Linux (From Source)**
```bash
git clone https://github.com/raysan5/raylib.git
cd raylib/src
make PLATFORM=PLATFORM_DESKTOP
sudo make install
```

## Quick Start

```hemlock
// Load raylib library - adjust path for your system:
//   Linux: import "/usr/lib/libraylib.so";
//   macOS (Apple Silicon): import "/opt/homebrew/opt/raylib/lib/libraylib.dylib";
//   macOS (Intel): import "/usr/local/lib/libraylib.dylib";
import "/usr/lib/libraylib.so";

extern fn InitWindow(width: i32, height: i32, title: string): void;
extern fn CloseWindow(): void;
extern fn WindowShouldClose(): i32;
extern fn BeginDrawing(): void;
extern fn EndDrawing(): void;
extern fn ClearBackground(color: u32): void;
extern fn DrawText(text: string, x: i32, y: i32, size: i32, color: u32): void;

// Color helper (ABGR format for little-endian)
fn Color(r: u8, g: u8, b: u8, a: u8): u32 {
    let r32: u32 = r;
    let g32: u32 = g;
    let b32: u32 = b;
    let a32: u32 = a;
    return (a32 << 24) | (b32 << 16) | (g32 << 8) | r32;
}

let WHITE = Color(255, 255, 255, 255);
let BLACK = Color(0, 0, 0, 255);

InitWindow(800, 450, "Hello Raylib!");

while (WindowShouldClose() == 0) {
    BeginDrawing();
    ClearBackground(WHITE);
    DrawText("Hello from Hemlock!", 300, 200, 20, BLACK);
    EndDrawing();
}

CloseWindow();
```

## Running Examples

```bash
cd raylib-hemlock

# Adjust library path in examples for your system first
hemlock examples/hello_window.hml
hemlock examples/input_demo.hml
hemlock examples/animation.hml
```

## Running Tests

The test suite verifies the utility functions (collision detection, math helpers, color functions):

```bash
# Run all tests
./tests/run_tests.sh /path/to/hemlock

# Or run individual tests
hemlock tests/test_colors.hml
hemlock tests/test_collision.hml
hemlock tests/test_math.hml
hemlock tests/test_constants.hml
```

## Project Structure

```
raylib-hemlock/
├── src/
│   └── raylib.hml           # Core raylib bindings reference
├── examples/
│   ├── hello_window.hml     # Basic window, shapes, and text
│   ├── input_demo.hml       # Keyboard and mouse input
│   └── animation.hml        # Bouncing balls with physics
├── tests/
│   ├── run_tests.sh         # Test runner script
│   ├── test_colors.hml      # Color function tests
│   ├── test_collision.hml   # Collision detection tests
│   ├── test_math.hml        # Math utility tests
│   └── test_constants.hml   # Constant value tests
├── .gitignore
└── README.md
```

## Available Bindings

### Window Management
- `InitWindow`, `CloseWindow`, `WindowShouldClose`
- `SetTargetFPS`, `GetFPS`, `GetFrameTime`, `GetTime`
- `GetScreenWidth`, `GetScreenHeight`, `GetRenderWidth`, `GetRenderHeight`
- `GetMonitorCount`, `GetCurrentMonitor`, `GetMonitorWidth`, `GetMonitorHeight`
- `ToggleFullscreen`, `ToggleBorderlessWindowed`
- `MaximizeWindow`, `MinimizeWindow`, `RestoreWindow`
- `SetWindowTitle`, `SetWindowPosition`, `SetWindowSize`
- `SetWindowMinSize`, `SetWindowMaxSize`, `SetWindowOpacity`

### Drawing
- `BeginDrawing`, `EndDrawing`, `ClearBackground`
- `BeginBlendMode`, `EndBlendMode`
- `BeginScissorMode`, `EndScissorMode`
- `DrawPixel`, `DrawLine`, `DrawLineEx`
- `DrawCircle`, `DrawCircleGradient`, `DrawCircleLines`
- `DrawEllipse`, `DrawEllipseLines`
- `DrawRectangle`, `DrawRectangleGradientV`, `DrawRectangleGradientH`, `DrawRectangleLines`
- `DrawTriangle`, `DrawTriangleLines`
- `DrawText`, `MeasureText`

### Input - Keyboard
- `IsKeyPressed`, `IsKeyPressedRepeat`, `IsKeyDown`, `IsKeyReleased`, `IsKeyUp`
- `GetKeyPressed`, `GetCharPressed`, `SetExitKey`

### Input - Mouse
- `IsMouseButtonPressed`, `IsMouseButtonDown`, `IsMouseButtonReleased`, `IsMouseButtonUp`
- `GetMouseX`, `GetMouseY`, `GetMouseWheelMove`
- `SetMousePosition`, `SetMouseOffset`, `SetMouseScale`
- `ShowCursor`, `HideCursor`, `IsCursorHidden`
- `EnableCursor`, `DisableCursor`, `IsCursorOnScreen`

### Input - Gamepad
- `IsGamepadAvailable`, `GetGamepadName`
- `IsGamepadButtonPressed`, `IsGamepadButtonDown`, `IsGamepadButtonReleased`, `IsGamepadButtonUp`
- `GetGamepadButtonPressed`, `GetGamepadAxisCount`, `GetGamepadAxisMovement`
- `SetGamepadMappings`

### Input - Touch & Gestures
- `GetTouchX`, `GetTouchY`, `GetTouchPointId`, `GetTouchPointCount`
- `SetGesturesEnabled`, `IsGestureDetected`, `GetGestureDetected`
- `GetGestureHoldDuration`, `GetGestureDragAngle`, `GetGesturePinchAngle`

### Audio
- `InitAudioDevice`, `CloseAudioDevice`, `IsAudioDeviceReady`
- `SetMasterVolume`, `GetMasterVolume`

### Utility Functions (Pure Hemlock)
- **Colors**: `Color`, `ColorAlpha`, `ColorBrightness`, `ColorGetR/G/B/A`
- **Collision**: `CheckCollisionCirclesXY`, `CheckCollisionRectsXY`, `CheckCollisionPointRectXY`, `CheckCollisionPointCircleXY`, `CheckCollisionCircleRecXY`
- **Math**: `Vector2Distance`, `Vector2Length`, `Vector2Dot`, `Lerp`, `Clamp`, `ClampInt`, `Remap`, `Wrap`, `NormalizeAngle`, `Deg2Rad`, `Rad2Deg`

### Constants
- **Colors**: `LIGHTGRAY`, `GRAY`, `DARKGRAY`, `YELLOW`, `GOLD`, `ORANGE`, `PINK`, `RED`, `MAROON`, `GREEN`, `LIME`, `DARKGREEN`, `SKYBLUE`, `BLUE`, `DARKBLUE`, `PURPLE`, `VIOLET`, `DARKPURPLE`, `BEIGE`, `BROWN`, `DARKBROWN`, `WHITE`, `BLACK`, `BLANK`, `MAGENTA`, `RAYWHITE`
- **Keys**: `KEY_A`-`KEY_Z`, `KEY_ZERO`-`KEY_NINE`, `KEY_SPACE`, `KEY_ESCAPE`, `KEY_ENTER`, arrow keys, function keys, modifiers, etc.
- **Mouse**: `MOUSE_BUTTON_LEFT`, `MOUSE_BUTTON_RIGHT`, `MOUSE_BUTTON_MIDDLE`, etc.
- **Gamepad**: Button and axis constants
- **Blend Modes**: `BLEND_ALPHA`, `BLEND_ADDITIVE`, `BLEND_MULTIPLIED`, etc.
- **Gestures**: `GESTURE_TAP`, `GESTURE_HOLD`, `GESTURE_DRAG`, swipes, pinch, etc.

## Notes

### Library Path
Each example needs the raylib library path adjusted for your system. Common paths:
- **Linux**: `/usr/lib/libraylib.so` or `/usr/local/lib/libraylib.so`
- **macOS (Apple Silicon)**: `/opt/homebrew/opt/raylib/lib/libraylib.dylib`
- **macOS (Intel)**: `/usr/local/lib/libraylib.dylib`

### Color Format
Raylib uses RGBA colors packed as 32-bit integers. On little-endian systems (most modern computers), the bytes are stored as ABGR in memory. The `Color()` helper function handles this conversion.

### Struct Limitations
Since Hemlock's FFI currently passes structs by value for small structs but doesn't have full struct support, some raylib functions that require complex structs (like `Vector2`, `Rectangle`, `Camera2D`) have coordinate-based alternatives provided in the bindings.

## License

MIT License - see raylib's license for the raylib library itself.
