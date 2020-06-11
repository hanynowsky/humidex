#!/usr/local/rvm/wrappers/ruby-2.1.2/ruby

require 'rubygems'
require 'cgi'
require 'cgi/session'
require 'cgi/session/pstore'     # provides CGI::Session::PStore
require 'json/ext'
require 'rest_client'

cgi = CGI.new('html4')
username = cgi['username']
password = cgi['password']
if username.nil? or password.nil?
  puts "<p>Needs login as 1st argument and password as second</p>"
  exit
end

# jira_url='http://crowd.hegerys.com/crowd/rest/usermanagement/1';
data = "<?xml version='1.0' encoding='UTF-8'?>
                  <authentication-context>
                          <username>#{username}</username>
                          <password>#{password}</password>
                          <validation-factors>
                                  <validation-factor>
                                          <name>remote_address</name>
                                          <value>127.0.0.1</value>
                                  </validation-factor>
                          </validation-factors>
                  </authentication-context>";
begin
  result = RestClient.post "http://mbt:crw7LkhR2@crowd.hegerys.com/crowd/rest/usermanagement/1/session", data , {:content_type => :xml, :Accept => :json}
  objarray = JSON.parse(result)
  unless objarray['token'].nil?
    begin
      sess = CGI::Session.new( cgi, "session_key" => "magician", "session_id" => "9650", "prefix" => "ruby_web_session.", "new_session" => "false",'session_expires' => Time.now + 60 * 24 * 7 * 60) 
      lastaccess = sess["lastaccess"].to_s
      sess["lastaccess"] = Time.now
      sess.delete
    rescue ArgumentError
    end
    sess = CGI::Session.new( cgi, "session_key" => "magician", "session_id" => "9650", "prefix" => "ruby_web_session.", "new_session" => "true") 
    sess.close
    cgi.out{
      cgi.html {
        cgi.body {
          "<link href=\"https://maxcdn.bootstrapcdn.com/bootstrap/3.2.0/css/bootstrap.min.css\" rel=\"stylesheet\" />
             <div class=\"jumbotron\">Ruby Session Last access time:</div> #{lastaccess}
          <div class='jumbotron'><h1 style=\"color:green;\">success</h1></div><p><kbd>" + objarray['token'] + "</kbd></p>
           <meta http-equiv=\"Refresh\" content=\"0; url=http://hanine.magic.fr/magic/phones.php \" />"
        }
      }
    }

    #cookie = CGI::Cookie.new("name" => "magician", "value" => "2015",)
    #cgi.out("cookie" => [cookie]) { "string" }
    #puts "<pre>"
    #cgi.out("session" => [sess]) { "" }
    #puts "</pre>"
    #return objArray['token']
  end
rescue => e
  cgi.out{
    cgi.html {
      cgi.body {
        "<p><code>failure</code></p><meta http-equiv=\"Refresh\" content=\"2; url=http://hanine.magic.fr/magic/form.php?failure=1\" />"
      }
    }
  }
end

puts cgi.header  # content type 'text/html'
