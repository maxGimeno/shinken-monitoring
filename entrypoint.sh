cp -r /tmp/.ssh /home/shinken
chown -R shinken: /home/shinken/.ssh
echo "\$SMTP_USERNAME\$=$SMTP_USERNAME" >> /etc/shinken/resource.d/smtp.cfg
echo "\$SMTP_PASSWORD\$=$SMTP_PASSWORD" >> /etc/shinken/resource.d/smtp.cfg
supervisord -c /etc/supervisor/supervisord.conf -n
