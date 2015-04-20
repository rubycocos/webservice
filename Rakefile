require 'hoe'
require './lib/webservice/version.rb'

Hoe.spec 'webservice' do

  self.version = Webservice::VERSION

  self.summary = 'webservice - yet another HTTP JSON API (web service) builder'
  self.description = summary

  self.urls    = ['https://github.com/rubylibs/webservice']

  self.author  = 'Gerald Bauer'
  self.email   = 'webslideshow@googlegroups.com'

  # switch extension to .markdown for gihub formatting
  self.readme_file  = 'README.md'
  self.history_file = 'HISTORY.md'

  self.extra_deps = [
    ['logutils' ],
    ['textutils' ],   # note: use for File.read_utf8
    ['rack']
  ]

  self.licenses = ['Public Domain']

  self.spec_extras = {
   required_ruby_version: '>= 1.9.2'
  }


end
