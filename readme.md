#Edentic Base Project based on Laravel Homestead

##Introduction
Edentic Base Project contains all you need to setup a new PHP project. Based upon the populare Laravel Homestead Vagrant box, the Edentic Base Project contains everything to get a new project up and running in no time! Edentic Base Project includes a default `npm` and `gulp` setup, which manages all the front-end assets, including compiling `sass` to `css` and compressing `images` and `js` sources. Also `bower` is included for easier JS front-end package management. The best of all is that all theese tools comes packaged and pre-installed in the vagrant box.


##Requirements
- [VirtualBox](http://virtualbox.org)
- [Vagrant](http://vagrantup.com)

##How to get going
1. Download the Edentic Base Project and unzip it
2. Place all the base project files in a new folder for your project
3. Copy your project files into the same folder - the `public/` directory is setup as the root for the webserver.
3. `cd` into your new project folder and run `vagrant up`
4. When Vagrant has finished setting up your box, use `vagrant ssh` to SSH into your newly setup Vagrant box
5. When in `cd` into your projects directory using `cd Code/` and you are ready to go!
6. `Exit` and use `vagrant halt` to shut down the Vagrant box, when finished developing

##Laravel Homestead box documentation
Documentation on the Laravel Homested box [is located here](http://laravel.com/docs/homestead?version=4.2).