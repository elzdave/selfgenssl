#!/bin/bash
# Generate trusted SSL certificate with speficied self-signed root CA using OpenSSL
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
SUBJ_INFO=ssl.info      # our signed certificate information

# splash lines
clear
echo -e "${LPURPLE}######################################"
echo -e "${LPURPLE}### SSL/TLS Certificate generator  ###"
echo -e "${LPURPLE}######################################"
echo ""

# Load issuer information
DEC_SSL=$(openssl x509 -in $ROOT_CA_PATH/$CA.crt -text -noout | grep 'Issuer:')
ISSUER_C=$(echo $DEC_SSL | awk -F"," '{print $1}' | awk -F"= " '{print $2}')
ISSUER_ST=$(echo $DEC_SSL | awk -F"," '{print $2}' | awk -F"= " '{print $2}')
ISSUER_L=$(echo $DEC_SSL | awk -F"," '{print $3}' | awk -F"= " '{print $2}')
ISSUER_O=$(echo $DEC_SSL | awk -F"," '{print $4}' | awk -F"= " '{print $2}')
ISSUER_OU=$(echo $DEC_SSL | awk -F"," '{print $5}' | awk -F"= " '{print $2}')
ISSUER_CN=$(echo $DEC_SSL | awk -F"," '{print $6}' | awk -F"= " '{print $2}')
ISSUER_E=$(echo $DEC_SSL | awk -F"," '{print $7}' | awk -F"= " '{print $2}')

# Load subject information
SUBJ_C=$(sed '1q;d' $SUBJ_INFO)
SUBJ_ST=$(sed '2q;d' $SUBJ_INFO)
SUBJ_L=$(sed '3q;d' $SUBJ_INFO)
SUBJ_O=$(sed '4q;d' $SUBJ_INFO)
SUBJ_OU=$(sed '5q;d' $SUBJ_INFO)
SUBJ_CN=$(sed '6q;d' $SUBJ_INFO)
SUBJ_E=$(sed '7q;d' $SUBJ_INFO)

# print issuer information
echo -e "${LGRAY}*** BEGIN OF ISSUER INFORMATION ***"
echo "Country Name      : $ISSUER_C"
echo "State             : $ISSUER_ST"
echo "Locality          : $ISSUER_L"
echo "Organization Name : $ISSUER_O"
echo "Organization Unit : $ISSUER_OU"
echo "Common Name       : $ISSUER_CN"
echo "Email             : $ISSUER_E"
echo -e "${LGRAY}*** END OF ISSUER INFORMATION ***"
echo ""

# print subject information
echo -e "${YELLOW}*** BEGIN OF SUBJECT INFORMATION ***"
echo "Country Name      : $SUBJ_C"
echo "State             : $SUBJ_ST"
echo "Locality          : $SUBJ_L"
echo "Organization Name : $SUBJ_O"
echo "Organization Unit : $SUBJ_OU"
echo "Common Name       : $SUBJ_CN"
echo "Email             : $SUBJ_E"
echo -e "${YELLOW}*** END OF SUBJECT INFORMATION ***"
echo ""

# Algorithm information
if [ "$1" == "-rsa" ] || [ "$1" == "" ];then
    SEL_ALGO="RSA $KEY_LENGTH"
    PRIV_KEY_GEN="openssl genrsa -out $DOMAIN.key $KEY_LENGTH"
elif [ "$1" == "-ecdsa" ];then
    SEL_ALGO="ECDSA $EC_ALGO"
    PRIV_KEY_GEN="openssl ecparam -name $EC_ALGO -genkey -out $DOMAIN.key"
fi
echo -e "${LCYAN}*** BEGIN OF ALGORITHM INFORMATION ***"
echo "Authentication    : $SEL_ALGO"
echo "Hash              : ${SHA_ALGO^^}"
echo -e "${LCYAN}*** END OF ALGORITHM INFORMATION ***"
echo ""

# begin works
echo -e "${WHITE}Generating ${CYAN}$SEL_ALGO ${WHITE}private key and certificate . . ."
echo -e "${GREEN}"
eval $PRIV_KEY_GEN
openssl req -new -key $DOMAIN.key -$SHA_ALGO -out $DOMAIN.csr < $SUBJ_INFO
openssl x509 -req -in $DOMAIN.csr -passin file:$ROOT_CA_PATH/$PWD_FILE -signkey $DOMAIN.key -$SHA_ALGO -days $TTL -CA $ROOT_CA_PATH/$CA.crt -CAkey $ROOT_CA_PATH/$CA.key -CAcreateserial -out $DOMAIN.crt
echo -e "\n${WHITE}Successfully generated ${CYAN}$SEL_ALGO ${WHITE}private key and certificate"
echo -e "${LCYAN}Certificate generation finished.${NC}"
exit