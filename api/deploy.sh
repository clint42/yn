#!/usr/bin/env bash
ssh clint@zerobeta.me << EOF
cd /home/clint/yn/tmp
echo "Cloning repository..."
git clone git@github.com:/clint42/yn
cd yn/api
echo "NPM Install"
npm install
echo "Cleaning old deployement"
rm -fr /home/clint/yn/api/deploy/ynapi
mkdir ynapi
echo "Moving files..."
mv * /home/clint/yn/api/deploy/ynapi
rm -fr /home/clint/yn/tmp/yn
echo "Done."
EOF
