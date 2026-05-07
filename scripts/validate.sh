#!/bin/bash

set -e

echo "Validating deployment..."

curl -f http://localhost || exit 1

echo "Application validation successful."