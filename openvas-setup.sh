
# Run as sudo

test -e /var/lib/openvas/CA/cacert.pem || openvas-mkcert -q
openvas-nvt-sync
test -e /var/lib/openvas/users/om || openvas-mkcert-client -n om -i
service openvas-manager stop
service openvas-scanner stop
openvassd
openvasmd --migrate
openvasmd --rebuild
openvas-scapdata-sync
openvas-certdata-sync
test -e /var/lib/openvas/users/admin || openvasad -c adduser -n admin -r Admin
killall openvassd
sleep 15
service openvas-scanner start
service openvas-manager start
service openvas-administrator restart
service greenbone-security-assistant restart
