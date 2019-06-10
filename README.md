# SSL/TLS Private Key and Certificate generator using OpenSSL

## General Information
* Author    : David Eleazar [[elzdave@student.untan.ac.id](mailto:elzdave@student.untan.ac.id)]
* Date      : 09 June, 2019
* Operating System : Linux-based OS with OpenSSL installed

## Usage
1. Edit `ssl.info` according to your preference
2. Make sure you have generated your root CA first in `root_ssl` folder
3. Run `./ssl.sh -rsa domain` to generate RSA key or `./ssl.sh -ecdsa domain` to generate ECDSA key, change `domain` to your domain

## Output
This script will produce several files as follows : 
1. RSA/ECDSA key file : `domain.key`
2. Certificate file :  `domain.crt`
3. Certificate Signing Request file : `domain.csr`