#!/bin/sh
# `/sbin/setuser memcache` runs the given command as the user `memcache`.
# If you omit that part, the command will be run as root.
exec /elasticsearch/bin/elasticsearch >> /var/log/elasticsearch.log 2>&1