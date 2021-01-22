path="${TARGET_BUILD_DIR}/${PRODUCT_NAME}.app"
cd "$SRCROOT"
find -E . -type f -iregex ".*\.framework\/[^./]*" -exec file {} \; | grep 'current ar archive' | sed 's/.*\/\(.*.framework\).*/\1/' | sort | uniq | while read -r line ; do
    rm -vrf "${path}/Frameworks/$line"
    rm -vrf "${path}/Plugins/$line"
    rm -vrf "${path}/Watch/$line"
    rm -vrf "${path}/AppClips/$line"
    rm -vrf "${path}/AppClip.app/Frameworks/$line"
done
