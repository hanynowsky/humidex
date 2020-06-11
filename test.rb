#!/usr/local/rvm/wrappers/ruby-2.1.2/ruby

require 'cgi'
require 'csv'
cgi = CGI.new("html4")

lastaccess = Time.now
cgi.out{
  cgi.html {
    cgi.body {
      "Last access time: #{lastaccess}"
    }
  }
}
