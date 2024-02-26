mkdir -f ./certs/
cd ./certs/
openssl req -x509 -newkey rsa:4096 -keyout key.pem -out cert.crt -days 365 -nodes -subj "/C=GB/ST=Scotland/L=Glasgow/O=WACT Inc/OU=Unit 2A"