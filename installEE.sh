#!/bin/bash

#Oct 5. 2012 - EE Preinstall script
#Edited December 10. 2013

#Clear screen and make colors default
clear
echo -e -n "\033[0m "

#Find the username of this machine
export username=$(whoami)
 
if [ ! -d /Users/$username/Sites/Paperplate/ ]; then

echo -e "\033[31m The EE Boilerplate file does not exist.  Please make sure the boilerplate file exists in /Users/$username/Sites/Paperplate/ before running this script." 
echo -e -n "\033[0m "
exit 0

fi 

echo -e "Enter the name of the project: \c"
read projectName

#Create the project folder
mkdir /Users/$username/Sites/$projectName

#Copy the EE Boilerplate project to your newly created project folder
echo "Copying files..."
cp -r /Users/$username/Sites/Paperplate/* /Users/$username/Sites/$projectName
echo -e "\033[32m Done!"
echo -e -n "\033[0m "

#Make entire project 755 before changing other permissions (just in case)
echo "Configuring permissions..."
chmod -R 755 /Users/$username/Sites/$projectName/CMS

#EE installation permissions changes

chmod 666 /Users/$username/Sites/$projectName/CMS/__ee_admin/expressionengine/config/config.php
chmod 666 /Users/$username/Sites/$projectName/CMS/__ee_admin/expressionengine/config/database.php
chmod -R 777 /Users/$username/Sites/$projectName/CMS/__ee_admin/expressionengine/cache
chmod -R 777 /Users/$username/Sites/$projectName/CMS/images
echo -e "\033[32m Done!"
echo -e -n "\033[0m "

#Write to Vhosts and hostfile in 2 steps

#Make files writable
echo "Writing to host files..."
sudo chmod 777 /etc/hosts
sudo chmod 777 /private/etc/apache2/extra/httpd-vhosts.conf

#Append to the hostfile

cat << EOF >> /etc/hosts

127.0.0.1 $projectName.dev
EOF

#Append to the vhosts file
cat << EOF >> /private/etc/apache2/extra/httpd-vhosts.conf

<VirtualHost *:80>
 DocumentRoot "/Users/$username/Sites/$projectName/CMS"
 ServerName $projectName.dev
</VirtualHost>
EOF

#Return the permissions to the default state
sudo chmod 644 /etc/hosts
sudo chmod 644 /private/etc/apache2/extra/httpd-vhosts.conf
echo -e "\033[32m Done!"
echo -e -n "\033[0m "

#TODO: Create the database

echo "Creating database..."
mysql -u root -h 127.0.0.1 -Bse "CREATE DATABASE $projectName;"
echo -e "\033[32m Done!"
echo -e -n "\033[0m "

#Restart Apache
echo "Restarting server..."
sudo apachectl restart
echo -e "\033[32m Done!"  
echo -e -n "\033[0m "

echo "Project $projectName has been created in /Users/$username/Sites/$projectName"
open "http://$projectName.dev/passport.php"