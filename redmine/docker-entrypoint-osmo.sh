#!/bin/sh

# Periodically fetch git repositories
# https://www.redmine.org/projects/redmine/wiki/RedmineRepositories
# Double fork, so it still runs after the exec below
(while :; do
	sleep 10m
	echo
	echo "=== Fetching git repositories (OS#5331) ==="
	rails runner "Repository.fetch_changesets" -e production
	echo
done &) &

# Run the original docker-entrypoint.sh script. Exec is important, so "tini"
# inside the original script becomes pid 1 to clean up zombies from redmine.
# https://github.com/docker-library/redmine/
exec /docker-entrypoint.sh "$@"
