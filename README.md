# Learning ruby [the practical way]

This project is based on a programming challenge for backend-services.
It utilizes Ruby with...

* Sinatra as webframework
* Rspec as test-framework
* Bundler for dependency management
* Mongodb as backing database
* Mongo_mapper as ORM
* And some smaller modules for writing the business logic

# Git tags / Levels

The challenge consists of 4 levels, which are properly tagged in this repository.
To checkout the specific solution for each level, use following clone commands:

```bash
#Tags names -> level[1-4]
git clone git clone --branch level1 https://github.com/magicpat/learning-ruby 
git clone git clone --branch level2 https://github.com/magicpat/learning-ruby 
git clone git clone --branch level3 https://github.com/magicpat/learning-ruby 
git clone git clone --branch level4 https://github.com/magicpat/learning-ruby 
```

# Setup / Requirements

This project requires a mongodb instance installed and running (default configuration).
After checking out the project, install all required dependencies:

```bash
cd learning-ruby

bundle install
```


# Run the server

```bash
ruby main.rb
```

# Run the tests

```bash
rspec spec/api_spec.rb
rspec spec/util_spec.rb
...

```
