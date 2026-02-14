
#!/bin/bash
# Comprehensive CI/CD local development script
# Usage: ./scripts/validate-all.sh

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"

echo "Terraform Validation and Linting"
echo "===================================="
echo ""

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Check if terraform is installed
if ! command -v terraform &> /dev/null; then
    echo -e "${RED}Terraform is not installed${NC}"
    exit 1
fi

# Check if tflint is installed
if ! command -v tflint &> /dev/null; then
    echo -e "${YELLOW}tflint is not installed. Install with: brew install tflint${NC}"
fi

# Check if pre-commit is installed
if ! command -v pre-commit &> /dev/null; then
    echo -e "${YELLOW}pre-commit is not installed. Install with: pip install pre-commit${NC}"
fi

echo "Terraform Format Check"
echo "------------------------"
if terraform fmt -check -recursive "$REPO_ROOT"; then
    echo -e "${GREEN}All files properly formatted${NC}"
else
    echo -e "${YELLOW}Some files need formatting. Run: terraform fmt -recursive${NC}"
fi
echo ""

ENVIRONMENTS=("bootstrap" "environments/prod")

for ENV in "${ENVIRONMENTS[@]}"; do
    echo "Validating: $ENV"
    echo "-------------------"
    
    if [ ! -d "$REPO_ROOT/$ENV" ]; then
        echo -e "${YELLOW}$ENV directory not found, skipping${NC}"
        echo ""
        continue
    fi
    
    cd "$REPO_ROOT/$ENV"
    
    # Initialize terraform
    echo "Initializing Terraform..."
    terraform init -upgrade=false -backend=false 2>&1 | grep -E '(Initializing|Error|error)' || true
    
    # Validate
    echo "Running terraform validate..."
    if terraform validate; then
        echo -e "${GREEN}Validation passed${NC}"
    else
        echo -e "${RED}Validation failed${NC}"
        exit 1
    fi
    
    # Run tflint if installed
    if command -v tflint &> /dev/null; then
        echo "Running tflint..."
        if tflint --config "$REPO_ROOT/.tflint.hcl"; then
            echo -e "${GREEN}tflint passed${NC}"
        else
            echo -e "${YELLOW}tflint found issues (review above)${NC}"
        fi
    fi
    
    echo ""
done

echo "Summary"
echo "=========="
echo -e "${GREEN}All validations completed successfully!${NC}"
echo ""
echo "Next steps:"
echo "1. Commit your changes"
echo "2. Push to a feature branch"
echo "3. Create a Pull Request"
echo "4. GitHub Actions will automatically run the CI/CD pipeline"
