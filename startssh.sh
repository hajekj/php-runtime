if [ "$WEBSITE_SSH_ENABLED" != "0" ]; then
    sed -i "s/SSH_PORT/$SSH_PORT/g" /etc/ssh/sshd_config
    service ssh start
fi