#!/usr/bin/env bash

# This is run by cloud-init as root

set -e

if [ -f /etc/redhat-release ]
then {
    # Update repos list
    yum -y update
    # Install Apache
    yum -y install httpd
    # Start the Apache server
    chkconfig httpd on
    service httpd start
}
fi

if [ -f /etc/lsb-release ]
then {
  # Update repos list
  apt-get update
  # Install Apache
  apt-get install -y apache2
  # Start apache2
  service apache2 start
}
fi

# Bonus: Create index page
cat << EOF > /var/www/html/index.html
<html>
    <header>
        <title>www.playqtest.com</title>
    </header>
    <body>
        Welcome to www.playqtest.com!
    </body>
</html>
EOF

# Adjust permissions
chmod -R g+w /var/www/html
