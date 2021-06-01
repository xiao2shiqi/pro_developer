#!/usr/bin/env bash

set -e

cd "${0%/*}/.."

echo "Running rubocop standardrb"
bundle exec standardrb