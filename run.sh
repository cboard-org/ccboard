rm -rf www/*
pushd .
cd ../cboard
npm run build
# npm run build-cordova-debug
cp -r ./build/* ../ccboard/www
popd
cordova build electron --release