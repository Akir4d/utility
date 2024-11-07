#!/bin/bash

# Creazione della directory /opt/autoresize se non esiste
if [ ! -d "/opt/autoresize" ]; then
    sudo mkdir -p /opt/autoresize
fi

# Copia dello script di autoridimensionamento in /opt/autoresize
cat << 'EOF' | sudo tee /opt/autoresize/autoresize.sh > /dev/null
#!/bin/sh

sleep 5
xrandr --output "$(xrandr | awk '/ connected/{print $1; exit; }')" --auto
xev -root -event randr | \
grep --line-buffered 'subtype XRROutputChangeNotifyEvent' | \
while read foo ; do \
    xrandr --output "$(xrandr | awk '/ connected/{print $1; exit; }')" --auto
done
EOF

# Dare i permessi di esecuzione e accesso alla cartella /opt/autoresize
sudo chmod 755 /opt/autoresize
sudo chmod +x /opt/autoresize/autoresize.sh

# Creazione del file .xsessionrc per eseguire /opt/autoresize se spice-vdagent è installato
cat << 'EOF' > ~/.xsessionrc
#!/bin/sh

if [ -x /usr/bin/spice-vdagent ] ; then
    /opt/autoresize/autoresize.sh &
fi
EOF

# Dare i permessi di esecuzione a .xsessionrc
chmod +x ~/.xsessionrc

# Copiare .xsessionrc in /etc/skel per renderlo disponibile a nuovi utenti
sudo cp -a ~/.xsessionrc /etc/skel/

echo "Installazione completata. Lo script di autoridimensionamento è configurato e pronto per l'uso."

sleep 5
rm $0
sudo reboot
