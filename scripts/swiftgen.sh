if [ -z "$CI" ]; then
    TMPDIR=/tmp/swiftgen-6.6.3
else
    mkdir build
    TMPDIR=build/swiftgen-6.6.3
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
    exit 0
fi

mkdir $TMPDIR

curl -o $TMPDIR/swiftgen.zip -L https://github.com/SwiftGen/SwiftGen/releases/download/6.6.3/swiftgen-6.6.3.zip

unzip $TMPDIR/swiftgen.zip -d $TMPDIR

$TMPDIR/bin/swiftgen
