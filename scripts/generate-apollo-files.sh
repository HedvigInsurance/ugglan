#!/bin/bash

CONFIGURATION="DEBUG" sh Carthage/Build/iOS/Apollo.framework/check-and-run-apollo-cli.sh codegen:generate --includes=./Sources/Space/**/*.graphql --localSchemaFile=Sources/Space/schema.json Sources/Space/API.swift --target=swift
