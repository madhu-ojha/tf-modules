#!/bin/bash
# Make scripts executable

chmod +x ./scripts/validate-all.sh
chmod +x ./scripts/install-hooks.sh
chmod +x ./scripts/setup-github-actions-aws.sh

echo "All scripts are now executable"
ls -lh ./scripts/
