#!/bin/bash
# Pre-commit hook installer
# Run this once to install all pre-commit hooks

set -e

if ! command -v pre-commit &> /dev/null; then
    echo "pre-commit is not installed"
    echo "Install it with: pip install pre-commit"
    exit 1
fi

echo "Installing pre-commit hooks..."
pre-commit install
pre-commit install --hook-type commit-msg

echo "Pre-commit hooks installed successfully"
echo ""
echo "Your commits will now be automatically validated!"
echo "To validate all files manually, run: pre-commit run --all-files"
