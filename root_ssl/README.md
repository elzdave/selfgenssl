# SSL/TLS Root CA Private Key and Certificate generator

## General Information
* Author    : David Eleazar [[elzdave@student.untan.ac.id](mailto:elzdave@student.untan.ac.id)]
* Date      : 09 June, 2019

## Usage
1. Edit `root.info` according to your preference
2. Run `./genssl.sh -rsa` to generate RSA key or `./genssl.sh -ecdsa` to generate ECDSA key

## Output
This script will produce several files as follows : 
1. RSA/ECDSA key file : `rootCA.key`
2. Certificate file :  `rootCA.crt`
3. Hidden passphrase file : `.passphrase`