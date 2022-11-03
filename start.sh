#! /bin/bash

rvm use ruby-2.6.6
ruby InitProvStateContract.rb && 
rails s webrick