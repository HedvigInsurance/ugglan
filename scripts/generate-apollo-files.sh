#!/bin/bash
CONFIGURATION="DEBUG" sh Carthage/Build/iOS/Apollo.framework/check-and-run-apollo-cli.sh codegen:generate --queries="$(find Src -name '*.graphql')"  --schema=Src/Data/schema.json Src/Data/API.swift
