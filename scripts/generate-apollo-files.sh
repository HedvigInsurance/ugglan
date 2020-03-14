#!/bin/bash

CONFIGURATION="DEBUG" sh Carthage/Build/iOS/Apollo.framework/check-and-run-apollo-cli.sh codegen:generate --includes=./Src/**/*.graphql --localSchemaFile=Src/Data/schema.json Src/Data/API.swift --target=swift
