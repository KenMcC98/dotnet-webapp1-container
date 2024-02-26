mkdir ./certs/
cd ./certs/
openssl req -x509 -newkey rsa:4096 -keyout key.pem -out cert.crt -days 365 -nodes -subj '/C=GB/ST=Scotland/L=Glasgow/O=WACT Inc/OU=Unit 2A/CN=localhost/emailAddress=johnsmith@fake.com'

# -- Replace openssl req with below if using Git Bash on Windows: --
# openssl req -x509 -newkey rsa:4096 -keyout key.pem -out cert.crt -days 365 -nodes -subj '//C=GB\ST=Scotland\L=Glasgow\O=WACT Inc\OU=Unit 2A\CN=localhost\emailAddress=johnsmith@fake.com'