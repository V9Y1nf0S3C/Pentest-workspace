#!/bin/sh
set -ue

if [ $# -ne 2 ]; then
	echo "Please supply 2 tokens" 1>&2
	exit 1
fi

cmd="python3 jwt_forgery.py"

echo "Running command: $cmd <token1> <token2>"

$cmd $1 $2 | awk '
	/==/ { exit }

	/GCD|^ 0x/ { next }
	
	{ sub(/\[\+] /, "") }
	
	/Found n/ {
	  print "";
	  sub(/  :.*/, ":");
	  print;
	  next;
	}
	
	/x509|pkcs1/ {
	  cmd = "base64 -w0 " $3;
	  sub(/.*_/, "", $3);
	  sub(/\.pem/, "", $3);
	  cmd | getline key;
	  print "    Base64 encoded "$3" key: " key;
	  next;
        }
	
	{
	  sub(/^/, "    ");
	  gsub(/b?\047/, "");
	  print;
	}
'
