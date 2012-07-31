## OSX Ruby Development Dependencies

* Homebrew 0.9
* RVM 1.14.2
* Ruby 1.9.3-p0
* Bundler 1.1.4

### Homebrew

[Homebrew](http://mxcl.github.com/homebrew/) is the easiest and most flexible way to install UNIX dependencies on OSX.

    /usr/bin/ruby -e "$(/usr/bin/curl -fsSL https://raw.github.com/mxcl/homebrew/master/Library/Contributions/install_homebrew.rb)"

or upgrade

    brew update

### RVM

[RVM](https://rvm.io/) is a version manager for Ruby.

    curl -L https://get.rvm.io | bash -s stable --ruby

or upgrade

    rvm get latest

### Ruby

    rvm install 1.9.3-p0
    rvm use 1.9.3-p0

### Create a Gemset

    rvm gemset create rails-3-2
    rvm gemset use rails-3-2

### Install Bundler

    gem install bundler --no-ri --no-rdoc --pre