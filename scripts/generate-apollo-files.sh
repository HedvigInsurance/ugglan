#!/bin/bash

CONFIGURATION="DEBUG" sh Carthage/Build/iOS/Apollo.framework/check-and-run-apollo-cli.sh codegen:generate --includes=./Sources/DataKit/**/*.graphql --localSchemaFile=Sources/DataKit/schema.json Sources/DataKit/API.swift --target=swift
