TMPDIR=/tmp

if [[ -f $TMPDIR/swiftgen/bin/swiftgen ]]
then
    $TMPDIR/swiftgen/bin/swiftgen
    exit 0
fi

curl -o $TMPDIR/swiftgen.zip -L https://github.com/SwiftGen/SwiftGen/releases/download/6.1.0/swiftgen-6.1.0.zip

unzip $TMPDIR/swiftgen.zip -d $TMPDIR/swiftgen

$TMPDIR/swiftgen/bin/swiftgen
