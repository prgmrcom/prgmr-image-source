#!/bin/sh
set -e

argument () {
  opt=$1
  shift

  if test $# -eq 0; then
      printf "%s: option requires an argument -- \`%s'\n" "$0" "$opt" 1>&2
      exit 1
  fi
  echo $1
}

output=$(/usr/sbin/$(basename $0) "$@")

# Check the arguments.
while test $# -gt 0
do
    option=$1
    shift
    case "$option" in
    -o | --output)
        grub_cfg=`argument $option "$@"`; shift;;
    --output=*)
        grub_cfg=`echo "$option" | sed 's/--output=//'`
        ;;
    esac
done

if [ "x$grub_cfg" = "x" ] ; then
		echo "$output"
		exit 0
fi

menu=$(cat "$grub_cfg" | /usr/local/sbin/prgmr-grub2-to-pv-grub-menu "$grub_cfg")

if [ -e /boot/grub/menu.lst ] ; then
		cp /boot/grub/menu.lst /boot/grub/menu.lst.bak
else
		mkdir -p /boot/grub/
fi
echo "$menu" > /boot/grub/menu.lst

