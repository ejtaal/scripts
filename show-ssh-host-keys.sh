
echo "/etc/ssh/..."
for i in /etc/ssh/*pub; do
	echo "$(basename $i):"
	echo -n "\t"
	ssh-keygen -lf "$i"
done
