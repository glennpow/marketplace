require File.dirname(__FILE__) + '/marketplace/marketplace_control'
require File.dirname(__FILE__) + '/marketplace/acts_as_marketer'
require File.dirname(__FILE__) + '/marketplace/has_many_features'

I18n.load_path.unshift(File.dirname(__FILE__) + '/locales/en.yml')

Configuration.load_path << File.dirname(__FILE__) + '/config.yml'
