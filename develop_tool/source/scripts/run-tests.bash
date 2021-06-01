#!/usr/bin/env bash

set -e

cd "${0%/*}/.."

echo "Running tests"
# 只执行 action 层面的单元测试
bundle exec rspec