#/bin/sh
openssl req -newkey rsa:4096  -subj "/C=US/ST=Oregon/L=Portland/O=IT/CN=front-end" -nodes -sha256 -keyout ./domain.key -x509 -days 5000 -out ./domain.crt
#openssl genrsa -des3 -out ca.key 4096
#openssl req -new -nodes -passin pass:buildit -passout pass:buildit -x509 -subj "/C=US/ST=Oregon/L=Portland/O=IT/CN=front-end" -days 3650 -key ca.key -out ca.crt
#openssl req -new -nodes -x509 -subj "/C=US/ST=Oregon/L=Portland/O=IT/CN=front-end" -days 3650 -keyout ca.key -out ca.crt -extensions v3_ca
#openssl genrsa -des3 -out client.key 4096
#openssl req -new  -subj "/C=US/ST=Oregon/L=Portland/O=IT/CN=front-end" -key client.key -out client.csr
#openssl x509 -req  -passin pass:buildit -passout pass:buildit -days 3650 -in client.csr -CA ca.crt -CAkey ca.key -set_serial 01 -out client.crt
