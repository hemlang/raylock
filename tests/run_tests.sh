#!/bin/bash
# Run all raylib-hemlock tests
# Usage: ./tests/run_tests.sh [hemlock_path]

# Find hemlock interpreter
if [ -n "$1" ]; then
    HEMLOCK="$1"
elif command -v hemlock &> /dev/null; then
    HEMLOCK="hemlock"
elif [ -f "../hemlock/hemlock" ]; then
    HEMLOCK="../hemlock/hemlock"
elif [ -f "/home/user/hemlock/hemlock" ]; then
    HEMLOCK="/home/user/hemlock/hemlock"
else
    echo "Error: hemlock interpreter not found"
    echo "Usage: $0 [path/to/hemlock]"
    exit 1
fi

echo "Using hemlock: $HEMLOCK"
echo ""

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

TOTAL_FAILED=0
TESTS_RUN=0

# Run each test file
for test_file in test_*.hml; do
    if [ -f "$test_file" ]; then
        echo "=========================================="
        echo "Running: $test_file"
        echo "=========================================="

        TESTS_RUN=$((TESTS_RUN + 1))
        if "$HEMLOCK" "$test_file"; then
            echo ""
        else
            echo "[ERROR] Test file failed: $test_file"
            TOTAL_FAILED=$((TOTAL_FAILED + 1))
        fi
        echo ""
    fi
done

echo "=========================================="
echo "All Tests Complete"
echo "=========================================="
echo "Test files run: $TESTS_RUN"

if [ $TOTAL_FAILED -eq 0 ]; then
    echo "Result: ALL PASSED"
    exit 0
else
    echo "Result: $TOTAL_FAILED test file(s) had failures"
    exit 1
fi
