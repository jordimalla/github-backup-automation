#!/bin/sh

set -e

TIME_ZONE=${TIME_ZONE:=UTC}
echo "timezone=${TIME_ZONE}"

cp /usr/share/zoneinfo/${TIME_ZONE} /etc/localtime
echo "${TIME_ZONE}" > /etc/timezone

echo "$(date) -> start a backup scheduler"

while :; do
    DATE=$(date +%Y%m%d-%H%M%S)

    for u in $(echo $USERS | tr "," "\n"); do
        echo "$(date) -> execute backup for ${u}, ${DATE}"
        github-backup ${u} --token=$GITHUB_TOKEN --all --output-directory=/srv/var/github-backup/${DATE}/${u} --organization --private --gists

        echo "$(date) -> compress backup"
        tar -zcvf /srv/var/github-backup/${DATE}/${u}.tar.gz /srv/var/github-backup/${DATE}/${u}

        echo "$(date) -> delete un-archived files"
        rm -rf /srv/var/github-backup/${DATE}/${u}
    done

    objArray="$(du -sh /srv/var/github-backup/* | grep '^[0-9.]*[MG]' | sort -hr | sed -E '1i {
s/(.*)\t(.*)/"\2": "\1",/
$s/,$//
$a }')"
    message="${objArray}"
    SendTeamsMessage -t "GitHub Backup" -m "${message}" -H "${TEAMSWEBHOOK}" -s "GitHub Backup OK" --send-ok

    echo "$(date) -> cleanup"
    ls -d1 /srv/var/github-backup/* | head -n -${MAX_BACKUPS} | xargs rm -rf

    echo "$(date) -> sleep for ${DELAY_TIME}"
    sleep ${DELAY_TIME}
done
