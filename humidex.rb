#!/opt/sensu/embedded/bin/ruby
# Author: Hanine HAMZIOUI
# Email: hanynowsky@gmail.com
# Description: This small code parses a matrix CSV file to get the humidex value
# Horizontally = Relative Humidity
# Vertically = Temperature

require 'cgi'
require 'csv'

FEELING_OKAY="Well being sensation"
FEELING_UNKNOWN="Unknown sensation but probably fine"
FEELING_BAD="Feeling unwell - Water every 20 minutes - Pause 15 minutes each hour"
FEELING_MALAISE="Sensation of evident malaise - Water every 15 minutes - Pause 30 minutes per hour"
FEELING_KO="OFFSICK & DANGER"
FEELING_BOTHERED="Feeling disturbed - Drink Extra water"
feeling = ''
method = 'chart'
color = 'green'
gpbwidth = 34
opbwidth = 33
rpbwidth = 33


cgi = CGI.new('html4')
temperature = cgi['temperature'].to_f
humidity = cgi['humidity'].to_f
use_formula=cgi['formula'].to_i
if humidity.nil? or temperature.nil?
    puts "<p>Please enter values for relative humidity and temperture in celsius</p>"
    exit
end

humidex=0
humex=0

def chart(celsius,rh)
    humex=0
    begin
        h_index=0
        index=0
        CSV.foreach(File.path("humidex.csv")) do |col|
            # GET horizontal Index of humidity (Header)
            if index == 0
                jindex = 0
                col.each do |ce|
                    if ce.to_i == rh.to_i
                        h_index=jindex
                    else
                        if ce.to_i > rh.to_i
                            h_index=jindex
                        end
                    end
                    jindex += 1
                end
            end

            # GET INDEX of Temperature - Vertical
            if col[0].to_i == celsius
                #print "Row matching temperature #{temperature} => " + col.inspect
                tindex=0
                col.each do |te|
                    if tindex.to_i == h_index.to_i
                        #puts "\nFor Humidity #{rh}:#{h_index} Matching Humidex is: #{te}"
                        humex = te.to_f
                    end
                    tindex += 1
                end
            end
            index+=1
        end

    rescue Exception => e  
        puts e.message  
        puts e.backtrace.inspect  
    end
    return humex
end

def dew_point(temp, rh)
    e = 6.1121 * (10 ** (7.502 * temp / (237.7 + temp)))
    p = (rh * e) / 100.0
    dp = (-430.22 + 237.7 * Math.log(p))/(-(Math.log(p)) + 19.08);
    #puts "Dew point: #{dp.to_f}"
    return dp.to_f
end

def hx(t,hy)
    dewpoint = dew_point(t,hy)
    a = 6.11 * 2.7182818284**(5417.7530*( 1/273.16 - 1/(dewpoint+273.16 ) )   )
    b = (0.5555) * ( a - 10 )
    hmx = t + b
    return hmx.to_f
end
if use_formula == 1
    humex = hx(temperature,humidity)
    method = "<a href='http://gordon.dewis.ca/2012/06/20/calculating-the-humidex/'> Formula </a>"
else
    humex = chart(temperature,humidity)
end

hx = humex
if hx == -1
    feeling = '<em>Chart does not yet provide a humidex for your values. Use Formula instead.</em>'
    color = 'grey'
    gpbwidth = 0
    opbwidth = 0
    rpbwidth = 0
elsif hx < 20 and hx >= 0
    feeling =  FEELING_UNKNOWN
    color = 'gray'
    gpbwidth = 0
    opbwidth = 0
    rpbwidth = 0
elsif hx >= 20 and hx <= 29
    feeling =  FEELING_OKAY
    color = 'green'
    gpbwidth = 34
    opbwidth = 0
    rpbwidth = 0
elsif hx > 29 and hx <= 33
    feeling =  FEELING_BOTHERED
    color = 'white'
    gpbwidth = 34
    opbwidth = 6
    rpbwidth = 0
elsif hx > 33 and hx <= 39
    feeling=  FEELING_BAD
    color = 'yellow'
    gpbwidth = 34
    opbwidth = 33
    rpbwidth = 0
elsif hx > 39 and hx <= 45
    feeling =  FEELING_MALAISE
    color = 'orange'
    gpbwidth = 34
    opbwidth = 33
    rpbwidth = 0
elsif hx > 45
    feeling =  FEELING_KO
    color = 'red'
    gpbwidth = 34
    opbwidth = 33
    rpbwidth = 33
else
    feeling = 'N/A'
    color = 'cyan'
    gpbwidth = 0
    opbwidth = 0
    rpbwidth = 0
end

cgi.out{
    cgi.html {
    cgi.head { cgi.title{"Humidex Result"} + "<meta http-equiv='X-UA-Compatible' content='IE=edge'>
    <meta name='viewport' content='width=device-width, initial-scale=1'>" }  + 
    cgi.body {
    "<link href=\"https://maxcdn.bootstrapcdn.com/bootstrap/3.2.0/css/bootstrap.min.css\" rel=\"stylesheet\" />
    <div class='jumbotron'><p><kbd>Humidex = <b style='color:#{color}'>#{humex}</b></kbd> = #{feeling}</p>
    <p>Dew Point : #{dew_point(temperature,humidity)}</p> 
    <p>Method used is: #{method}</p>
    <a  href='humidex.html'>HOME</a>
    </div>

        <div class='progress'>
          <div class='progress-bar progress-bar-success' style='width: #{gpbwidth}%'>
              <span class='sr-only'>35% Complete (success)</span>
                </div>
                  <div class='progress-bar progress-bar-warning progress-bar-striped' style='width: #{opbwidth}%'>
                      <span class='sr-only'>20% Complete (warning)</span>
                        </div>
                          <div class='progress-bar progress-bar-danger' style='width: #{rpbwidth}%'>
                              <span class='sr-only'>10% Complete (danger)</span>
                                </div>
                                </div>

    "
}
}
}

#puts cgi.header  # content type 'text/html'
