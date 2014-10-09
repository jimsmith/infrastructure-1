Development environment for data.glasgow.gov.uk
===============================================

__This is still in development and is likely full of bugs. Run at your
own risk. And please whatever you do DO NOT use in production!!__

Setting up
----------

Make sure you have VirtualBox and Vagrant installed. This also assumes
that your host OS is a *nix style environment and has only been run on
OSX 10.9.5 at this time.

    cd ~
    mkdir -p openglasgow/opendata
    cd openglasgow/opendata
    git clone git@github.com:openglasgow/infrastructure.git
    ln -s infrastructure/Vagrantfile Vagrantfile

Running Vagrant
---------------

To boot your new box and ssh into it do:

    vagrant up
    vagrant ssh

The first time you run `vagrant up` it could take quite sometime as it
downloads the required OS and packages. Subsequent boots should be much
shorter.

Installing the Glasgow ckanext
------------------------------

You will need to execute the following from within your guest os.

    source /vagrant/env/bin/activate
    cd /vagrant/extensions
    git clone git@github.com:okfn/ckanext-glasgow.git
    cd ckanext-glasgow/
    python setup.py develop
    pip install -r requirements.txt
    pip install -r requirements-dev.txt


Now you have your box running to run the CKAN development environment
you'll need to do the following from within your guest os.

   source /vagrant/env/bin/activate
   paster serve /vagrant/ckan/development.ini