#!/bin/bash

echo -e "\n🔍 Analyse des vhosts Nginx actifs\n"

# Lister tous les fichiers *.conf dans sites-enabled (résolus depuis sites-available)
for conf in /etc/nginx/sites-enabled/*.conf; do
    echo "📄 Fichier : $conf"

    awk '
    BEGIN { vhost_id=1 }
    $1 == "server" && $2 == "{" { in_server=1; listen="—"; default="non"; server_name="—"; root="—"; next }
    in_server && $1 == "listen" {
        listen = $0;
        if ($0 ~ /default_server/) default="oui";
    }
    in_server && $1 == "server_name" { server_name = $0 }
    in_server && $1 == "root" { root = $0 }
    in_server && $0 ~ /^ *}/ {
        print "📦 Vhost #" vhost_id++
        print "  - listen       :\t" listen;
        print "  - default      :\t" default;
        print "  - server_name  :\t" server_name;
        print "  - root         :\t" root;
        print ""
        in_server=0;
    }
    ' "$conf"

done
