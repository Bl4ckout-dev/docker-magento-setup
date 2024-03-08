#!/bin/bash
# E-Mail used for urgent renewal and security notices 
email=$1

# Ask user for email if non is provided as arg
if [ -z "${email}" ]; then
    echo "E-Mail used for urgent renewal and security notices:"
    read email
fi

# Get script location
scriptDir=$(dirname "${BASH_SOURCE[0]}")
confDir="$scriptDir/nginx/conf"

# Check if conf folder exits
if ! [ -d $confDir ]; then
  echo "Missing nginx conf directory"
  exit
fi

# Find all .conf files
# Using *.*.conf to exclude files like global.conf
readarray -d '' vhosts < <(find $confDir -maxdepth 1 -type f -name "*.*.conf" -print0)

# Go through vhosts
for i in "${vhosts[@]}"
do
    # Remove base directory
    domain="${i##*/}"
    # Remove last file extension e.g. .conf
    domain="${domain%.*}"

    docker run -it --rm -p 80:80 \
      -v $scriptDir/nginx/letsencrypt/conf:/etc/letsencrypt \
      -v $scriptDir/nginx/letsencrypt/lib:/var/lib/letsencrypt \
      -v $scriptDir/nginx/webroot:/data/letsencrypt \
      -v $scriptDir/nginx/letsencrypt/logs:/var/log/letsencrypt \
      certbot/certbot certonly --standalone --expand --webroot-path=/data/letsencrypt --rsa-key-size=4096 -d $domain --no-eff-email --agree-tos -m $email
done
