
# Change to the cboard directory
cd ./cboard

# Run yarn build
yarn build

# Navigate to the build folder
cd build

# Copy the files to the 'www' folder in ccboard directory
yes | cp -rf ./* ../www/

# Copy the files to the 'www' folder in ccboard/platforms/ios directory
yes | cp -rf ./* ../platforms/ios/www/

echo "Build completed (check previous logs to confirm success)
files copied successfully and replaced!
run the build from Xcode"

