 #!bin/bash
#My Crucible Pacakges

### Checking for user
if [ "$(whoami)" != 'root' ]; then
        echo "You have no permission to run $0 as non-root user. Use sudo !!!"
        exit 1;
fi

#mysql
if [ -f /etc/init.d/mysql* ]; then
    echo "installed"
else 
    apt-get install mysql-server libapache2-mod-auth-mysql php5-mysql
    mysql_install_db
    /usr/bin/mysql_secure_installation
fi

apt-get install php5 libapache2-mod-php5 php5-mcrypt

#php
apt-get install php5-fpm php-pear

#vim
apt-get install vim

#nginx
apt-get install nginx
service nginx start
service nginx reload

#curl
apt-get install curl php5-curl

# Install Ruby with RVM
sudo apt-get update
\curl -L https://get.rvm.io |    bash -s stable --ruby --autolibs=enable --auto-dotfiles
source ~/.rvm/scripts/rvm
rvm requirements

# Install Ruby
rvm install ruby
rvm use ruby --default

apt-get install build-essential
rvm install ruby-dev

apt-get install libmysqlclient-dev 

#Install Rake
apt-get install rake

#Install JAVA
apt-get install python-software-properties
add-apt-repository ppa:webupd8team/java
apt-get update
apt-get install oracle-java7-installer oracle-java6-installer

#Memcache
memcache
apt-get install php5-memcached memcached

#WKhtmltopdf
apt-get install wkhtmltopdf xvfb
echo 'xvfb-run --server-args="-screen 0, 1024x768x24" /usr/bin/wkhtmltopdf $*' > /usr/bin/wkhtmltopdf.sh
chmod a+rx /usr/bin/wkhtmltopdf.sh
ln -s /usr/bin/wkhtmltopdf.sh /usr/local/bin/wkhtmltopdf

#Install Redis
apt-get update
apt-get install build-essential tcl8.5
wget http://download.redis.io/releases/redis-stable.tar.gz
tar xzf redis-stable.tar.gz
make
make test
make install
cd utils
./install_server.sh
service redis_6379 start
service redis_6379 stop
cd ..

#Change PHP User

#change Nginx User
