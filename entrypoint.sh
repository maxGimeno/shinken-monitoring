cp -r /tmp/.ssh /home/shinken
chown -R shinken: /home/shinken/.ssh
supervisord -c /etc/supervisor/supervisord.conf -n
