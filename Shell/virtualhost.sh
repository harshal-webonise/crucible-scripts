#!bin/bash
#This shell script is used to  setup crucible
if [ "$(whoami)" != 'root' ]; then
        echo "You have no permission to run $0 as non-root user. Use sudo !!!"
        exit 1;
fi
 
### Configure email and vhost dir
vhroot='/etc/nginx/sites-available'   # no trailing slash
iserror='no'
hosterror=''
direrror=''
 
# Take inputs host name and root directory
echo -e "Please provide hostname. e.g.crucible.webonise.com"
read  hostname
echo -e "Please provide web root directory. e.g. /home/projects/../Crucible/app/webroot"
read rootdir
 
### Check inputs
if [ "$hostname" = "" ]
then
    iserror="yes"
    hosterror="Please provide proper domain name."
fi
 
if [ "$rootdir" = "" ]
then
    iserror="yes"
    direrror="Please provide web root directory name."
fi
 
### Displaying errors
if [ "$iserror" = "yes" ]
then
    echo "Please correct following errors:"
    if [ "$hosterror" != "" ]
    then
        echo "$hosterror"
    fi
 
    if [ "$direrror" != "" ]
    then
        echo "$direrror"
    fi
    exit;
fi
 
### check whether hostname already exists
if [ -e $vhroot"/"$hostname ]; then
    iserror="yes"
    hosterror="Hostname already exists. Please provide another hostname."
fi
 
### check if directory exists or not
if ! [ -d $rootdir ]; then
    iserror="yes"
    direrror="Directory provided does not exists.";
fi
 
### Displaying errors
if [ "$iserror" = "yes" ]
then
    echo "Please correct following errors:"
    if [ "$hosterror" != "" ]
    then
        echo "$hosterror"
    fi
 
    if [ "$direrror" != "" ]
    then
        echo "$direrror"
    fi
    exit;
fi
 
if ! touch $vhroot/$hostname
then
        echo "ERROR: "$vhroot"/"$hostname" could not be created."
else
        echo "Virtual host document root created in "$vhroot"/"$hostname
fi
 
if ! echo "server {
   listen      80;
   server_name $hostname;
   access_log  /var/log/nginx/$hostname.access.log;
   error_log   /var/log/nginx/$hostname.error.log;
   rewrite_log on;
   root        $rootdir;
   index       index.php index.html index.htm;
   # Not found this on disk?
   # Feed to CakePHP for further processing!
   if (!-e \$request_filename) {
       rewrite ^/(.+)$ /index.php;
       break;
   }
   # Pass the PHP scripts to FastCGI server
   # listening on 127.0.0.1:9000
   location ~ \.php$ {
       # fastcgi_pass   unix:/tmp/php-fastcgi.sock;
       fastcgi_pass   127.0.0.1:9000;
       fastcgi_index  index.php;
       fastcgi_intercept_errors on; # to support 404s for PHP files not found
       fastcgi_param  SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
       include        fastcgi_params;
   }
   # Static files.
   # Set expire headers, Turn off access log
   location ~* \favicon.ico$ {
       access_log off;
       expires 1d;
       add_header Cache-Control public;
   }
   location ~ ^/(img|cjs|ccss)/ {
       access_log off;
       expires 7d;
       add_header Cache-Control public;
   }
   # Deny access to .htaccess files,
   # git & svn repositories, etc
   location ~ /(\.ht|\.git|\.svn) {
       deny  all;
   }
}" > $vhroot/$hostname
then
        echo "ERROR: the virtual host could not be added."
else
        echo "New virtual host added to the nginx"
fi
 
### Add hostname in /etc/hosts
if ! echo "127.0.0.1       $hostname" >> /etc/hosts
then
    echo "ERROR: Not able write in /etc/hosts"
else
    echo "Host added to /etc/hosts file"
fi
 
### enable website
sudo ln -s /etc/nginx/sites-available/$hostname /etc/nginx/sites-enabled/$hostname
 
### restart Apache
/etc/init.d/nginx restart
 
 
# show the finished message
echo "Complete! The new virtual host has been created.
To check the functionality browse http://"$hostname"
Document root is "$vhroot"/"$hostname