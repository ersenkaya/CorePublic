######################
# Config
######################

CONFIGURATION=Release



######################
# Directories
######################

REPO=$(pwd)
PROJECT_DIR="${REPO}"
WORKSPACE_NAME="Core"
FRAMEWORK_NAME="Core"
PROJECT_NAME="Core"
BUILD_DIR="${REPO}/DerivedData/${PROJECT_NAME}/Build/Products"

SIMULATOR_LIBRARY_PATH="${BUILD_DIR}/${CONFIGURATION}-iphonesimulator/${FRAMEWORK_NAME}.framework"

DEVICE_LIBRARY_PATH="${BUILD_DIR}/${CONFIGURATION}-iphoneos/${FRAMEWORK_NAME}.framework"

UNIVERSAL_LIBRARY_DIR="${BUILD_DIR}/${CONFIGURATION}-iphoneuniversal"

FRAMEWORK="${UNIVERSAL_LIBRARY_DIR}/${FRAMEWORK_NAME}.framework"

OUTPUT="${PROJECT_DIR}/Output"



######################
# Clean
######################

#rm -rf ${BUILD_DIR}
#mkdir ${BUILD_DIR}

rm -rf ${OUTPUT}
mkdir ${OUTPUT}



######################
# Build Core Framework for device and simulator
######################

xcodebuild -workspace ${PROJECT_DIR}/${WORKSPACE_NAME}.xcworkspace -scheme ${PROJECT_NAME} -sdk iphonesimulator build CONFIGURATION_BUILD_DIR=${BUILD_DIR}/${CONFIGURATION}-iphonesimulator -arch x86_64 -UseModernBuildSystem=0 BITCODE_GENERATION_MODE=bitcode OTHER_CFLAGS="-fembed-bitcode"

xcodebuild -workspace ${PROJECT_DIR}/${WORKSPACE_NAME}.xcworkspace -scheme ${PROJECT_NAME} -sdk iphoneos build CONFIGURATION_BUILD_DIR=${BUILD_DIR}/${CONFIGURATION}-iphoneos -xcconfig -UseModernBuildSystem=0 BITCODE_GENERATION_MODE=bitcode OTHER_CFLAGS="-fembed-bitcode"

######################
# Create directory for universal
######################

rm -rf "${UNIVERSAL_LIBRARY_DIR}"

mkdir "${UNIVERSAL_LIBRARY_DIR}"

mkdir "${FRAMEWORK}"



######################
# Copy device framework to universal
######################

cp -r "${DEVICE_LIBRARY_PATH}/." "${FRAMEWORK}"



######################
# Make a universal binary
######################

lipo "${SIMULATOR_LIBRARY_PATH}/${FRAMEWORK_NAME}" "${DEVICE_LIBRARY_PATH}/${FRAMEWORK_NAME}" -create -output "${FRAMEWORK}/${FRAMEWORK_NAME}" | echo

# For Swift framework, Swiftmodule needs to be copied in the universal framework
if [ -d "${SIMULATOR_LIBRARY_PATH}/Modules/${FRAMEWORK_NAME}.swiftmodule/" ]; then
cp -f ${SIMULATOR_LIBRARY_PATH}/Modules/${FRAMEWORK_NAME}.swiftmodule/* "${FRAMEWORK}/Modules/${FRAMEWORK_NAME}.swiftmodule/" | echo
fi

if [ -d "${DEVICE_LIBRARY_PATH}/Modules/${FRAMEWORK_NAME}.swiftmodule/" ]; then
cp -f ${DEVICE_LIBRARY_PATH}/Modules/${FRAMEWORK_NAME}.swiftmodule/* "${FRAMEWORK}/Modules/${FRAMEWORK_NAME}.swiftmodule/" | echo
fi



######################
# Copy RB to output
######################

cp -r ${FRAMEWORK} ${OUTPUT}
cp -r ${FRAMEWORK} ${OUTPUT}/../../CorePublic/Output

######################
# Remove Build folder
######################

#rm -rf ${BUILD_DIR}

