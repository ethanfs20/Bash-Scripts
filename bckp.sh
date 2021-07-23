#!/bin/bash
#AUTHOR | ETHAN SHEARER
#DESC | This script allows you to back up any directory specified and automatically compress the archive. It has an easy naming convention and usage!
#USAGE | USE WITH CRONTAB OR MANUALLY EXECUTE FROM THE CLI BY "bash bckp.sh".

SAVENAME=backup-`date +%b-%d-%y`.tar.gz
TARGET=/var/lib/containers/storage/overlay/407020db12c53c4415f045dcc9d9e6de472db26c213959e85b53a0b21dd8117a/diff/txData/CFXDefault_ECA6A8.base
SAVEDIR=/root/bckp
tar -cpzf $SAVEDIR/$SAVENAME $TARGET