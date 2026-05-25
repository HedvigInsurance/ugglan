mkdir -p Projects/hCoreUI/Sources/Derived
mkdir -p Projects/App/Sources/Derived
mkdir -p Projects/hCore/Sources/Derived
mkdir -p Projects/Forever/Sources/Derived
mkdir -p Projects/Contracts/Sources/Derived
mkdir -p Projects/Home/Sources/Derived
mkdir -p Projects/Market/Sources/Derived

SWIFTGEN_VERSION=6.6.3
mise install swiftgen@$SWIFTGEN_VERSION
mise exec swiftgen@$SWIFTGEN_VERSION -- swiftgen

# Stock SwiftGen swift5 template emits `public enum hCoreUIAssets` with non-Sendable
# static lets, which Swift 6 strict concurrency rejects. Annotate with @MainActor.
ASSETS_FILE="Projects/hCoreUI/Sources/Derived/Assets.swift"
if [ -f "$ASSETS_FILE" ] && ! grep -q "@MainActor" "$ASSETS_FILE"; then
    sed -i '' 's/public enum hCoreUIAssets/@MainActor \npublic enum hCoreUIAssets/g' "$ASSETS_FILE"
fi
