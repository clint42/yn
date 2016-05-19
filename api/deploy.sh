#!/usr/bin/env bash
ssh clint@zerobeta.me << EOF
exec ssh-agent bash
ssh-add /home/clint/.ssh/id_rsa.pub
cd /home/clint/yn/tmp
echo "Cloning repository..."
git clone git@github:clint42/yn.git yn
cd yn/api
echo "NPM Install"
npm install
echo "Cleaning old deployement"
rm -fr /home/clint/yn/deploy/api
echo "Moving files..."
mkdir /home/clint/yn/deploy/api
mv /home/clint/yn/tmp/yn/api/* /home/clint/yn/deploy/api
echo "Removing temporary files..."
rm -fr /home/clint/yn/tmp/yn
echo "Start application using PM2"
cd /home/clint/yn/deploy/api/
NODE_ENV=production pm2 start bin/www -i max
pm2 list
echo "Done"
EOF
