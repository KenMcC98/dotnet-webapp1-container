mkdir ./certs/
cd ./certs/
openssl req -x509 -newkey rsa:4096 -keyout key.pem -out cert.crt -days 365 -nodes