require 'yaml'
require File.expand_path(File.dirname(__FILE__) + '/pinger')

f = File.open('settings.yml','r+')
settings = YAML.load(f)
pinger = Pinger.new(settings)
pinger.start :any
