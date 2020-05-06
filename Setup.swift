import ProjectDescription

let setup = Setup([
    .homebrew(packages: ["swiftlint", "carthage", "swiftformat"]),
    .custom(name: "Install Git Hooks", meet: ["./scripts/githooks.sh"], isMet: ["exit 1"]),
    .custom(name: "Carthage", meet: ["./scripts/carthage.sh"], isMet: ["Carthage"]),
            .custom(name: "Translations", meet: ["./scripts/translations.sh"], isMet: ["exit 1"]),
    .custom(name: "Swiftgen", meet: ["./scripts/swiftgen.sh"], isMet: ["exit 1"]),
])
