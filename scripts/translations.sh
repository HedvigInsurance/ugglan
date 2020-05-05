TMPDIR=/tmp

if [[ -f $TMPDIR/swiftTranslationsCodegen ]]
then
    $TMPDIR/swiftTranslationsCodegen --projects '[App, IOS]' --destination 'Projects/App/Sources/Assets/Localization/Localization.swift'
    exit 0
fi

curl -o $TMPDIR/swiftTranslationsCodegen "https://raw.githubusercontent.com/HedvigInsurance/swift-translations-codegen/master/main.swift?$(date +%s)"

chmod +x $TMPDIR/swiftTranslationsCodegen

$TMPDIR/swiftTranslationsCodegen --projects '[App, IOS]' --destination 'Projects/App/Sources/Assets/Localization/Localization.swift'
