#!/bin/bash
# Generate trusted self-signed SSL root CA certificate using OpenSSL
# based on the information from root.info
#
# (c) 2019, David Eleazar
#
# Usage : ./genssl.sh [-algo]
# Supported algo : rsa, ecdsa
# If no argument specified, then the RSA algorithm will be used

# Warning : only regenerate key when it really needs to, this will make all installed root CA to be invalid!
# Please use with caution !

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

# Parameter, feel free to edit based on your needs
PASSWD=$(openssl rand -base64 36)   # generate random passphrase for private key encryption
PWD_FILE=.passphrase                # root CA private key passphrase file name
CA=rootCA                           # root CA private key and certificate file name
KEY_LENGTH=4096                     # RSA key length
EC_ALGO=secp384r1                   # ECDSA algorithm
SHA_ALGO=sha384                     # Hashing algorithm
AES_ALGO=aes256                     # Encryption algorithm
TTL=7320                            # this certificate will valid for ~20 years
ROOT_INFO=root.info                 # root CA signer information

# delete old root CA key
if [ -e $CA.key ] || [ -e $CA.crt ]; then
    rm -rf $CA*
fi

# splash lines
clear
echo -e "${LPURPLE}###########################################"
echo -e "${LPURPLE}### SSL/TLS Root Certificate generator  ###"
echo -e "${LPURPLE}###########################################"
echo ""

# Load signer information
C=$(sed '1q;d' $ROOT_INFO)
S=$(sed '2q;d' $ROOT_INFO)
LN=$(sed '3q;d' $ROOT_INFO)
ON=$(sed '4q;d' $ROOT_INFO)
OU=$(sed '5q;d' $ROOT_INFO)
CN=$(sed '6q;d' $ROOT_INFO)
E=$(sed '7q;d' $ROOT_INFO)

echo -e "${YELLOW}*** BEGIN OF SIGNER INFORMATION ***"
echo "Country Name      : $C"
echo "State             : $S"
echo "Locality          : $LN"
echo "Organization Name : $ON"
echo "Organization Unit : $OU"
echo "Common Name       : $CN"
echo "Email             : $E"
echo -e "${YELLOW}*** END OF SIGNER INFORMATION ***"
echo ""

# Algorithm information
if [ "$1" == "-rsa" ] || [ "$1" == "" ];then
    SEL_ALGO="RSA $KEY_LENGTH"
    PRIV_KEY_GEN="openssl genrsa -out $CA.key -$AES_ALGO -passout file:$PWD_FILE $KEY_LENGTH"
elif [ "$1" == "-ecdsa" ];then
    SEL_ALGO="ECDSA $EC_ALGO"
    PRIV_KEY_GEN="openssl ecparam -name $EC_ALGO -genkey | openssl ec -$AES_ALGO -passout file:$PWD_FILE -out $CA.key"
fi
echo -e "${LCYAN}*** BEGIN OF ALGORITHM INFORMATION ***"
echo "Authentication    : $SEL_ALGO"
echo "Encryption        : ${AES_ALGO^^}"
echo "Hash              : ${SHA_ALGO^^}"
echo -e "${LCYAN}*** END OF ALGORITHM INFORMATION ***"
echo ""

# generate random password
echo $PASSWD > $PWD_FILE
chmod 600 $PWD_FILE
echo -e "${WHITE}Private key password : ${LGREEN}$PASSWD${NC}"
echo -e "${WHITE}The password is stored in ${LRED}.passphrase${WHITE} file in this folder, please keep it in a safe place"

# begin works
echo -e "${WHITE}Generating ${CYAN}$SEL_ALGO ${WHITE}private key and certificate . . ."
echo -e "${GREEN}"
eval $PRIV_KEY_GEN
openssl req -x509 -passin file:$PWD_FILE -new -nodes -key $CA.key -$SHA_ALGO -days $TTL -out $CA.crt < $ROOT_INFO
echo -e "\n\n${WHITE}Successfully generated ${CYAN}$SEL_ALGO ${WHITE}private key and certificate"
echo -e "${LCYAN}Certificate generation finished.${NC}"
exit