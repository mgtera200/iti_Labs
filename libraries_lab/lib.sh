#!/bin/bash

# Check if the user provided the required arguments
if [ -z "$1" ]; then
    echo "Usage: $0 [static|dynamic|clean] <compiler>"
    exit 1
fi

# Assign arguments to variables
TARGET=$1
COMPILER=$2

# If the user types 'arm', use the specific compiler
if [ "$COMPILER" == "arm" ]; then
    COMPILER="arm-cortexa9_neon-linux-musleabihf-gcc"
fi

# Execute the corresponding make target
case "$TARGET" in
    static)
        if [ -z "$COMPILER" ]; then
            echo "Usage: $0 [static|dynamic|clean] <compiler>"
            exit 1
        fi
        echo "[Eng.TERA] generating your static app..."
        make CC=$COMPILER static_app
        ;;
    dynamic)
        if [ -z "$COMPILER" ]; then
            echo "Usage: $0 [static|dynamic|clean] <compiler>"
            exit 1
        fi
        echo "[Eng.TERA] generating your dynamic app..."
        make CC=$COMPILER dynamic_app
        ;;
    clean)
    	echo "[Eng.TERA] Cleaning your directory..."
        make clean
        ;;
    *)
        echo "Invalid argument. Use 'static', 'dynamic', or 'clean'."
        exit 1
        ;;
esac

exit 0
