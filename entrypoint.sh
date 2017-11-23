cp -r /tmp/.ssh /home/shinken
chown -R shinken: /home/shinken/.ssh
#add confidential stuff in the smtp config
echo "\$SMTP_USERNAME\$=$SMTP_USERNAME" >> /etc/shinken/resource.d/smtp.cfg
echo "\$SMTP_PASSWORD\$=$SMTP_PASSWORD" >> /etc/shinken/resource.d/smtp.cfg
#add confidential stuff in the hosts config
echo "_SNMPCOMMUNITY $CGAL_PASSWD" >> /etc/shinken/hosts/gauguin.cfg
echo "}" >> /etc/shinken/hosts/gauguin.cfg
echo "_SNMPCOMMUNITY $CGAL_PASSWD" >> /etc/shinken/hosts/friedrich.cfg
echo "}" >> /etc/shinken/hosts/friedrich.cfg
supervisord -c /etc/supervisor/supervisord.conf -n
