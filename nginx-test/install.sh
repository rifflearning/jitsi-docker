#! /usr/bin/env bash
#
# Installs this test site as THE nginx site.
# After installing nginx, this script adds symlinks in /etc/nginx

REPO_DIR=/home/ubuntu/riff/jitsi-docker

sudo rm /etc/nginx/sites-enabled/*
sudo rm /etc/nginx/conf.d/*

# snippets
pushd ${REPO_DIR}/nginx-test/snippets
for f in *
do
    sudo ln -s ${REPO_DIR}/nginx-test/snippets/$f /etc/nginx/snippets/$f
done
popd

# main configuration file
pushd /etc/nginx/conf.d
sudo ln -s ${REPO_DIR}/nginx-test/conf.d/riffdata.riffplatform.com.conf riffdata.riffplatform.com.conf
popd

# riffdata test html file
pushd /usr/share/nginx/html
sudo ln -s ${REPO_DIR}/nginx-test/riffdata-test.html riffdata-test.html
popd


# SSL Certs
echo 'You should copy the ssl cert/private key files to /etc/ssl/certs and /etc/ssl/private'
echo 'or create links in those locations pointing to those files.'
echo 'The snippets/site_ssl_cert.conf should be edited to reflect those files'
echo 'You may need to create /etc/ssl/certs/dhparam.pem'
echo 'to do that use the command:'
echo 'sudo openssl dhparam -out /etc/ssl/certs/dhparam.pem 2048'
echo
echo 'You should also add riffdata to the /etc/hosts file with the appropriate IP address'
echo
echo 'Use "sudo systemctl restart nginx" to have the new configuration loaded'
