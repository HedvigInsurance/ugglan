buildDir=$(xcodebuild \
-workspace Ugglan.xcworkspace \
-scheme Codegen \
build | grep 'TARGET_BUILD_DIR')

eval $buildDir

$TARGET_BUILD_DIR/Codegen.app/Contents/MacOS/Codegen
