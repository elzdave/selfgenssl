#!/bin/bash
# Generate trusted SSL certificate with speficied self-signed root CA
#
# (c) 2019, David Eleazar
#
# Usage : ./ssl.sh [-algo]
# Supported algo : rsa, ecdsa
# If no argument specified, then the RSA algorithm will be used

# Note : generate root CA first, and store generated root CA certificate to target OS/browser

# List of ANSI color escape
#Black        0;30     Dark Gray     1;30
#Red          0;31     Light Red     1;31
#Green        0;32     Light Green   1;32
#Brown/Orange 0;33     Yellow        1;33
#Blue         0;34     Light Blue    1;34
#Purple       0;35     Light Purple  1;35
#Cyan         0;36     Light Cyan    1;36
#Light Gray   0;37     White         1;37

NC='\033[0m'
BLACK='\033[0;30m'
RED='\033[0;31m'
GREEN='\033[0;32m'
BROWN='\033[0;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
LGRAY='\033[0;37m'
DGRAY='\033[1;30m'
LRED='\033[1;31m'
LGREEN='\033[1;32m'
YELLOW='\033[1;33m'
LBLUE='\033[1;34m'
LPURPLE='\033[1;35m'
LCYAN='\033[1;36m'
WHITE='\033[1;37m'

# get domain
if [ "$2" == "" ];then
    DOMAIN=random.domain
else
    DOMAIN=$2
fi

# Parameter, feel free to edit based on your needs
ROOT_CA_PATH=root_ssl   # set this to self-signed root CA path
PWD_FILE=.passphrase    # set this to self-signed root CA private key passphrase file name
CA=rootCA               # set this to self-signed root CA private key and certificate file name
KEY_LENGTH=3072         # RSA key length
EC_ALGO=secp384r1       # ECDSA algorithm
SHA_ALGO=sha384         # Hashing algorithm
TTL=1825                # this certificate will valid for ~5 years
ROOT_INFO=root.info     # root CA signer information
SIGNED_INFO=ssl.info    # our signed certificate information

# splash lines
clear
echo -e "${LPURPLE}######################################"
echo -e "${LPURPLE}### SSL/TLS Certificate generator  ###"
echo -e "${LPURPLE}######################################"
echo ""

# Load issuer information
ISSUER_C=$(sed '1q;d' $ROOT_CA_PATH/$ROOT_INFO)
ISSUER_S=$(sed '2q;d' $ROOT_CA_PATH/$ROOT_INFO)
ISSUER_LN=$(sed '3q;d' $ROOT_CA_PATH/$ROOT_INFO)
ISSUER_ON=$(sed '4q;d' $ROOT_CA_PATH/$ROOT_INFO)
ISSUER_OU=$(sed '5q;d' $ROOT_CA_PATH/$ROOT_INFO)
ISSUER_CN=$(sed '6q;d' $ROOT_CA_PATH/$ROOT_INFO)
ISSUER_E=$(sed '7q;d' $ROOT_CA_PATH/$ROOT_INFO)

# Load our information
SIGNED_C=$(sed '1q;d' $SIGNED_INFO)
SIGNED_S=$(sed '2q;d' $SIGNED_INFO)
SIGNED_LN=$(sed '3q;d' $SIGNED_INFO)
SIGNED_ON=$(sed '4q;d' $SIGNED_INFO)
SIGNED_OU=$(sed '5q;d' $SIGNED_INFO)
SIGNED_CN=$(sed '6q;d' $SIGNED_INFO)
SIGNED_E=$(sed '7q;d' $SIGNED_INFO)

# print issuer information
echo -e "${LGRAY}*** BEGIN OF ISSUER INFORMATION ***"
echo "Country Name      : $ISSUER_C"
echo "State             : $ISSUER_S"
echo "Locality          : $ISSUER_LN"
echo "Organization Name : $ISSUER_ON"
echo "Organization Unit : $ISSUER_OU"
echo "Common Name       : $ISSUER_CN"
echo "Email             : $ISSUER_E"
echo -e "${LGRAY}*** END OF ISSUER INFORMATION ***"
echo ""

# print issuer information
echo -e "${YELLOW}*** BEGIN OF SIGNED INFORMATION ***"
echo "Country Name      : $SIGNED_C"
echo "State             : $SIGNED_S"
echo "Locality          : $SIGNED_LN"
echo "Organization Name : $SIGNED_ON"
echo "Organization Unit : $SIGNED_OU"
echo "Common Name       : $SIGNED_CN"
echo "Email             : $SIGNED_E"
echo -e "${YELLOW}*** END OF SIGNED INFORMATION ***"
echo ""

# Algorithm information
if [ "$1" == "-rsa" ] || [ "$1" == "" ];then
    SEL_ALGO="RSA $KEY_LENGTH"
elif [ "$1" == "-ecdsa" ];then
    SEL_ALGO="ECDSA $EC_ALGO"
fi
echo -e "${LCYAN}*** BEGIN OF ALGORITHM INFORMATION ***"
echo "Authentication    : $SEL_ALGO"
echo "Hash              : ${SHA_ALGO^^}"
echo -e "${LCYAN}*** END OF ALGORITHM INFORMATION ***"
echo ""

# argument check
if [ "$1" == "-rsa" ] || [ "$1" == "" ];then
    echo -e "${WHITE}Generating ${CYAN}RSA $KEY_LENGTH ${WHITE}private key and certificate . . ."
    echo -e "${GREEN}"
    openssl genrsa -out $DOMAIN.key $KEY_LENGTH
elif [ "$1" == "-ecdsa" ];then
    echo -e "${WHITE}Generating ${CYAN}ECDSA $EC_ALGO ${WHITE}private key and certificate . . ."
    echo -e "${GREEN}"
    openssl ecparam -name $EC_ALGO -genkey -out $DOMAIN.key
fi
openssl req -new -key $DOMAIN.key -$SHA_ALGO -out $DOMAIN.csr < $SIGNED_INFO
openssl x509 -req -in $DOMAIN.csr -passin file:$ROOT_CA_PATH/$PWD_FILE -signkey $DOMAIN.key -$SHA_ALGO -days $TTL -CA $ROOT_CA_PATH/$CA.crt -CAkey $ROOT_CA_PATH/$CA.key -CAcreateserial -out $DOMAIN.crt
echo -e "\n${WHITE}Successfully generated ${CYAN}$SEL_ALGO ${WHITE}private key and certificate"
echo -e "${LCYAN}Certificate generation finished.${NC}"
exit