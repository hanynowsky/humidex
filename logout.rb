#!/usr/local/rvm/wrappers/ruby-2.1.2/ruby

require 'rubygems'
require 'cgi'
require 'cgi/session'
require 'cgi/session/pstore'     # provides CGI::Session::PStore

cgi = CGI.new('html4')


values = cgi.cookies['magician']  # <== array of 'name'
# if not 'name' included, then return [].
names = cgi.cookies.keys      # <== array of cookie names

cgi.cookies['magician'].expires = Time.now + 1
sess = CGI::Session.new( cgi, "session_key" => "magician",  "new_session" => "new", "session_expires" => Time.now + 1) # The session_expires is the main player here
sess.close
sess.delete
#sess['magician'] = nil unless key == 'flash'

cgi.out {
  cgi.html {
    cgi.body {
      "<code> Expired session: #{values} amongst #{names}</code>
            <meta http-equiv=\"Refresh\" content=\"0; url=http://hanine.magic.fr/ \" />
      "
    }
  }
}


puts cgi.header
