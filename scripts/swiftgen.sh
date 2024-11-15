if [ -z "$CI" ]; then
    TMPDIR=/tmp/swiftgen-6.4.0
else
    mkdir build
    TMPDIR=build/swiftgen-6.4.0
fi

mkdir Projects/hCoreUI/Sources/Derived
mkdir Projects/App/Sources/Derived
mkdir Projects/hCore/Sources/Derived
mkdir Projects/Forever/Sources/Derived
mkdir Projects/Contracts/Sources/Derived
mkdir Projects/Home/Sources/Derived
mkdir Projects/Market/Sources/Derived

if [[ -f $TMPDIR/bin/swiftgen ]]
then
    $TMPDIR/bin/swiftgen
    file="Projects/hCoreUI/Sources/Derived/Assets.swift"         # File where you want to insert the new line
    search_text="public enum hCoreUIAssets"             # Line number at which to insert the new line
    replace_text="@MainActor \npublic enum hCoreUIAssets"  # Text to insert
    sleep 1
    if grep -q "@MainActor" "$file"; then
        echo "Already @MainActor"
    else
        if [ ! -f "$file" ]; then
            echo "File not found!"
            exit 1
        fi
    sed -i '' "s/${search_text}/${replace_text}/g" "$file"
    fi
    exit 0
fi

mkdir $TMPDIR

curl -o $TMPDIR/swiftgen.zip -L https://github.com/SwiftGen/SwiftGen/releases/download/6.6.3/swiftgen-6.6.3.zip

unzip $TMPDIR/swiftgen.zip -d $TMPDIR

$TMPDIR/bin/swiftgen
