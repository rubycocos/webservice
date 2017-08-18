require 'hoe'
require './lib/webservice/version.rb'

Hoe.spec 'webservice' do

  self.version = Webservice::VERSION

  self.summary = 'webservice - yet another HTTP JSON API (web service) builder'
  self.description = summary

  self.urls    = ['https://github.com/rubylibs/webservice']

  self.author  = 'Gerald Bauer'
  self.email   = 'ruby-talk@ruby-lang.org'

  # switch extension to .markdown for gihub formatting
  self.readme_file  = 'README.md'
  self.history_file = 'HISTORY.md'

  self.extra_deps = [
    ['logutils'],
    ['rack', '>=2.0.3']
  ]

  self.licenses = ['Public Domain']

  self.spec_extras = {
   required_ruby_version: '>= 2.3'
  }


end
