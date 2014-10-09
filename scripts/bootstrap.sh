echo "<~>"
echo " ,_____"
echo "       ___"
echo "       ('>-__"
echo "         ~      ~~~--__            **              ***"
echo "               ______  (@\   *******  ****    *******    ******"
echo "              /******~~~~\|**********************************"
echo "      \       --____******************************************"
echo "     / ~~~--_____    ~~~/ ***************************************"
echo "                 ~~~~~         ******************************"
echo "                                      ****    **************"
echo "                                        ***       ***********"
echo "                                                        ********"
echo "HERE BE DRAGONS. START CKAN INSTALL"

echo "updating the package manager"
sudo apt-get update

echo "installing dependencies available via apt-get"
sudo apt-get install python-dev postgresql libpq-dev python-pip python-virtualenv git-core solr-jetty openjdk-6-jdk python-pastescript apache2 libapache2-mod-wsgi nginx vim git -y

echo "create virtualenv"
mkdir -p /vagrant/env
virtualenv --no-site-packages /vagrant/env
source /vagrant/env/bin/activate

echo "install ckan from git"
pip install -e 'git+https://github.com/ckan/ckan.git@ckan-2.2#egg=ckan'

echo "install ckan requirements"
pip install -r /vagrant/env/src/ckan/requirements.txt

echo "install pylons"
pip install pylons

echo "install ckan glasgow extension"
mkdir -p /vagrant/extensions
cd /vagrant/extensions
git clone git@github.com:okfn/ckanext-glasgow.git
cd ckanext-glasgow/
python setup.py develop
pip install -r requirements.txt
pip install -r requirements-dev.txt

echo "setup postgresql"
sudo -u postgres psql -f /vagrant/infrastructure/data/initial.sql
#sudo -u postgres createuser -S -D -R --no-password ckan_default
#sudo -u postgres psql -c "alter user ckan_default with password 'pass'"
#sudo -u postgres createdb -O ckan_default ckan_default -E utf-8

echo "create ckan config files"
mkdir -p /vagrant/ckan
ln -s /vagrant/infrastructure/configs/ckan/development.ini /vagrant/ckan/development.ini

echo "create folders"
mkdir -p /vagrant/ckan/media/storage

echo "setup solr-jetty"
sudo rm -f /etc/default/jetty
sudo ln -s /vagrant/infrastructure/configs/jetty/jetty /etc/default/jetty
sudo service jetty start
sudo rm -f /etc/solr/conf/schema.xml
sudo ln -s /vagrant/env/src/ckan/ckan/config/solr/schema.xml /etc/solr/conf/schema.xml
sudo service jetty restart

#echo "create db tables"
#cd /vagrant/env/src/ckan
#paster db init -c /vagrant/ckan/development.ini

echo "link who.ini"
ln -s /vagrant/env/src/ckan/who.ini /vagrant/ckan/who.ini

echo "install node"
sudo apt-get install nodejs npm -y
sudo ln -s /usr/bin/nodejs /usr/bin/node

echo "compile ckan css"
sudo npm install less -g
lessc /vagrant/env/src/ckan/ckan/public/base/less/main.less > /vagrant/env/src/ckan/ckan/public/base/css/main.debug.css

touch ~/.bootstrapped