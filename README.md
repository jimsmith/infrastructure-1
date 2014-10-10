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


Now you have your box up to run the CKAN development environment
you'll need to do the following from within your guest os.

    source /vagrant/env/bin/activate
    paster serve /vagrant/ckan/development.ini


Writing extensions
------------------

If you're working on an existing extension you can skip ahead, this
first part covers how to create a new extension. This is taken from the
[ckan templating docs](http://docs.ckan.org/en/latest/theming/templates.html).

__This all should take place on the guest os__

    ```bash
    source /vagrant/env/bin/activate
    cd /vagrant/env/src
    # Create your new blank extension
    paster --plugin=ckan create -t ckanext ckanext-example_theme

    # Move it into the extensions folder, this is available to both
    # host and guest OS
    mv ckanext-example_theme /vagrant/extensions/
    ```

Now you need to create the plugin file:

    /vagrant/extensions/ckanext-example_theme/ckanext/example_theme/plugin.py

and enter the following:

    ```python
    import ckan.plugins as plugins
    import ckan.plugins.toolkit as toolkit


    class ExampleThemePlugin(plugins.SingletonPlugin):
        '''An example theme plugin.

        '''
        # Declare that this class implements IConfigurer.
        plugins.implements(plugins.IConfigurer)

        def update_config(self, config):

            # Add this plugin's templates dir to CKAN's extra_template_paths, so
            # that CKAN will use this plugin's custom templates.
            # 'templates' is the path to the templates dir, relative to this
            # plugin.py file.
            toolkit.add_template_directory(config, 'templates')
    ```

Now you need to edit

    /vagrant/extensions/ckanext-example_theme/setup.py

and change the enty point to be

    ```python
    entry_points='''
        [ckan.plugins]
        example_theme=ckanext.example_theme.plugin:ExampleThemePlugin
    ''',
    ```

Now we need to add our new template file. If for example we were going
to replace the homepage we would need to create a file

    /vagrant/extensions/ckanext-example_theme/ckanext/example_theme/templates/home/index.html

Add some content so you can see the changes on your dev server.

Finally we need to install our new plugin. Edit the .ini file at

    /vagrant/infrastructure/configs/ckan/development.ini

_(Be careful not to push this up until your're ready to release
your plugin)_

In the ini file add your new plugin to the list of plugins

    ckan.plugins = stats text_view recline_view example_theme

Now install the plugin

    ```bash
    source /vagrant/env/bin/activate
    cd /vagrant/extensions/ckanext-example_theme
    python setup.py develop
    ```

You can now restart your development server and see your changes!

Deploying a new extension
-------------------------

Once you have finished development of your new extension and want to
deploy it so that the rest of the team can bask in its wonderfulness you
will need to push it up and make some changes to the infrastructure repo.

__This is all performed on your HOST OS__

    ```bash
    cd ~/openglasgow/opendata/extensions/ckanext-example_theme
    git push origin master
    ```

Ensure that your plugin is added to the .ini file as above then edit the
infrastructure requirements to include your new extension.

    ```bash
    cd ~/openglasgow/opendata/infrastructure
    vi requirements.txt
    ```

You can install directly from git via pip using the following syntax

    git+ssh://git@github.com/openglasgow/ckanext-example_theme@master

Add that to the requirements.txt file above. Once it is added make sure
you push up your infrastructure branch and issue a pull request.

Now you're ready to make the changes in vagrant.

    ```bash
    cd ~/openglasgow/opendata
    vagrant up
    vagrant ssh

    # uninstall the develop version
    cd /vagrant/extensions/ckanext-example_theme
    python setup.py develop --uninstall

    # If you're sure you do not have any unpushed branches etc you
    # are now safe to remove this directory
    cd ..
    rm -rf ckanext-example_theme

    # finally you can install using the requirements file
    cd /vagrant/infrastructure
    pip install -r requirements.txt
    ```