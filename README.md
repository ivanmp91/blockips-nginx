blockips-nginx
==============

Script to generate an IP blacklist for nginx from the url: http://www.badips.com/get/list/wordpress/
The script use etckeeper to commit the changes for the configuration file or revert changes. By default uses: /etc/nginx/conf.d/blockips.conf
After get the list if there are changes, the script copy the new file on /etc/nginx/conf.d/blockips.conf, reload nginx and commit the changes. If the reload fails the script will revert the changes and reload again nginx with the previous configuration.
