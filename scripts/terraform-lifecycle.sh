#!/usr/bin/env bash
set -euo pipefail

ACTION="${1:-}"
TFVARS_FILE="${TFVARS_FILE:-terraform.tfvars}"
PLAN_FILE="${PLAN_FILE:-terraform.tfplan}"
AUTO_APPROVE="${AUTO_APPROVE:-false}"
SKIP_INIT="${SKIP_INIT:-false}"

if [[ -z "$ACTION" ]]; then
  echo "Usage: ./scripts/terraform-lifecycle.sh <validate|plan|apply|destroy|output>"
  exit 1
fi

if ! command -v terraform >/dev/null 2>&1; then
  echo "Terraform CLI not found. Install Terraform and retry."
  exit 1
fi

if ! command -v az >/dev/null 2>&1; then
  echo "Azure CLI not found. Install Azure CLI and retry."
  exit 1
fi

az account show >/dev/null

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
cd "$REPO_ROOT"

run_tf() {
  echo "terraform $*"
  terraform "$@"
}

if [[ "$SKIP_INIT" != "true" ]]; then
  run_tf init -upgrade -reconfigure
fi

case "$ACTION" in
  validate)
    run_tf validate
    ;;

  plan)
    run_tf plan -var-file="$TFVARS_FILE" -out="$PLAN_FILE"
    echo "Plan written to $PLAN_FILE"
    ;;

  apply)
    if [[ "$AUTO_APPROVE" == "true" ]]; then
      run_tf apply -var-file="$TFVARS_FILE" -auto-approve
    else
      run_tf apply -var-file="$TFVARS_FILE"
    fi
    ;;

  destroy)
    if [[ "$AUTO_APPROVE" != "true" ]]; then
      echo "Destroy will remove ALL managed resources for this state."
      read -r -p "Type 'destroy' to continue: " CONFIRM
      if [[ "$CONFIRM" != "destroy" ]]; then
        echo "Destroy cancelled by user."
        exit 1
      fi
    fi

    if [[ "$AUTO_APPROVE" == "true" ]]; then
      run_tf destroy -var-file="$TFVARS_FILE" -auto-approve
    else
      run_tf destroy -var-file="$TFVARS_FILE"
    fi
    ;;

  output)
    run_tf output
    ;;

  *)
    echo "Unsupported action: $ACTION"
    echo "Valid actions: validate, plan, apply, destroy, output"
    exit 1
    ;;
esac
