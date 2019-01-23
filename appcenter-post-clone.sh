set -ex
brew uninstall node@6
NODE_VERSION="8.5.0"
curl "https://nodejs.org/dist/v${NODE_VERSION}/node-v${NODE_VERSION}.pkg" > "$HOME/Downloads/node-installer.pkg"
sudo installer -store -pkg "$HOME/Downloads/node-installer.pkg" -target "/"

echo "Installing Apollo"
npm install apollo@1.9 -g
