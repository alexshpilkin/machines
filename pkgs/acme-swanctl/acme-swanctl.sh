#!/bin/sh -eu
# Compatible with both lego and uacme.

cd -- "${1:-.}"

h=$(basename -- "$PWD")
t=$(mktemp -p /etc/swanctl/x509ca); trap 'rm -f "$t"' EXIT
cat cert.pem | {
	openssl x509 -out "/etc/swanctl/x509/$h.pem~"
	mv "/etc/swanctl/x509/$h.pem~" "/etc/swanctl/x509/$h.pem"
	while openssl x509 -out "$t" 2>/dev/null; do
		fp=$(openssl x509 -in "$t" -noout -md5 -fingerprint |
		     sed 's/.*=//; s/://g')
		cat -- "$t" > /etc/swanctl/x509ca/$fp.pem~
		mv /etc/swanctl/x509ca/$fp.pem~ /etc/swanctl/x509ca/$fp.pem
	done
}

umask 027
cat key.pem > "/etc/swanctl/private/$h.pem~"
mv "/etc/swanctl/private/$h.pem~" "/etc/swanctl/private/$h.pem"
