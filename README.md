### Data Exploration Tool

#### Goals
Big Raw datafiles are hard to read if they are CSVs SQL or not. The problem is indexing which database do very well. This will treat every new line a in a file as a text record and apply a GiST or BTREE index to it (database specific).

Once data has been loaded you can execute queries and explore the record results as identified in a lookup.
#### Setup
This requires ruby. On OSX this is super easy using homebrew.
- $`brew update`
- $`brew install ruby-build`
- Install RVM via https://rvm.io/
- $`rvm reload`
- $`rvm install 2.3.1`
- Change directories out and back into the project to autocreate the gemset
- $`bundle install` If you don't have bundler run $`gem install bundler` first

#### Usage
All usage is from the command line. The program assumes there will be files in the data folder. They can be in subfolders it will read them all.

##### CONFIG FILE
1. Look for config.yml
2. configure the correct database adapter (mysql | postgres)
3. enter your server string following the examples provided

##### DB SETUP
The database will need to be setup prior to creating tables

- $`bundle exec ruby setup_db.rb`

##### Load Data Files
- $`bundle exec ruby load.rb`

This will create a file timestamped for the current load you can tail

##### Query
- $`bundle exec ruby query.rb <some_string> [<mode_strings>]`

This will also spawn a logfile and populate the link table with relations

#### Notes
##### Postgres
- Uses GiST index for fulltext searches
##### Mysql
- Uses BTREE index for fulltext searches
