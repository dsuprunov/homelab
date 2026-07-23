#!/usr/bin/env sh
set -eu

sudo apt-get update -o Acquire::Retries=5 -o APT::Update::Error-Mode=any
