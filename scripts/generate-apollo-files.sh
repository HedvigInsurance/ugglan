#!/bin/bash
CONFIGURATION="DEBUG" sh Pods/Apollo/scripts/check-and-run-apollo-cli.sh codegen:generate --queries="$(find . -name '*.graphql')"  --schema=Hedvig/Data/schema.json Hedvig/Data/API.swift
