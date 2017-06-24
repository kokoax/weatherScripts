require 'mysql'
require 'open-uri'

def main( )
  day    = `date "+%d"`.to_i().to_s().gsub( /\R/, "" )
  month  = `LC_ALL=C date "+%m"`.to_i().to_s().gsub( /\R/, "" )
  monthText  = `LC_ALL=C date "+%B"`.downcase().gsub( /\R/, "" )
  year   = `date "+%Y"`.to_s().gsub( /\R/, "" )

  # weather_data = `curl http://slate-dev.accuweather.com/en/jp/morioka-shi/224170/daily-weather-forecast/224170 2> /dev/null`
  url = "http://slate-dev.accuweather.com/en/jp/morioka-shi/224170/#{monthText}-weather/224170?monyr=#{month}/1/#{year}&view=table"
  puts( url )

  weather_data = open(url).read
  # puts( weather_data )

  tmp = weather_data.scan( /<table cellspacing="0" class="calendar-list">([\s\S]+?)<\/table>/m )
  #tmp = weather_data.scan( /<tr (?:[\s\S]+?)>([\s\S]+?)<\/tr>/m ).rstrip.split(/\R/).map {|line| line.chomp }
  #tmp = weather_data.scan( /<tr (?:[\s\S]+?)>([\s\S]+?)<\/tr>/m ).join()
  tmp = weather_data.scan( /<tr(?:[\s\S]*?)>([\s\S]+?)<\/tr>/m )
  word = []
  for index in tmp do
    index = index.join().to_s().gsub( /\R\s*/, "" )
    word.push( index )
    # print( "\n" )
  end
  word = word.join()
  #print( word )
  #print( tmp )
  time = word.scan( /<time>(.+?)<\/time>/m )
  td   = word.scan( /<td>(.+?)<\/td>/m )

  client = Mysql::new( "127.0.0.1", "kokoax", "yomo4808", "weather" )

  time.length().times{ |i|
    if( i >= day.to_i()-1 )
      # date
      date = sprintf( "%d%02d%02d", year, time[i].join().split( '/' )[0], time[i].join().split( '/' )[1] )
      update = "WHERE YMD = " + date

      request = sprintf( "INSERT INTO daily( YMD ) value( %s )", date )
      puts( request )
      begin
        client.query( request )
      rescue
        puts( "ALREADY INSERT YMD" )
      end


      # Hi / Lo
      high = td[i*5].join().split( "/" )[0].match( /([0-9]+)/ )[0].to_s()
      low  = td[i*5].join().split( "/" )[1].match( /([0-9]+)/ )[0].to_s()
      request = sprintf( 'UPDATE daily set HiLo = "%s/%s" %s', high, low, update )
      puts( request )
      client.query( request )

      # Precip
      precip = td[i*5+1].join().match( /([0-9]+)/ )[0].to_s()
      request = sprintf( 'UPDATE daily set Precip = %d %s', precip, update )
      puts( request )
      client.query( request )

      # Snow
      snow = td[i*5+2].join().match( /([0-9]+)/ )[0].to_s()
      request = sprintf( 'UPDATE daily set Snow = %d %s', snow, update )
      puts( request )
      client.query( request )

      # icon
      icon = sprintf( "%02d", td[i*5+3].to_s().match( /([0-9]+)/ )[0].to_i() )
      request = sprintf( 'UPDATE daily set Icon = "%s" %s', icon, update )
      puts( request )
      client.query( request )

      # cond
      # puts( td[i*5+3].to_s().match( /<p>(.+)<\/p>/ )[1].to_s() )
      cond = td[i*5+3].to_s().match( /<p>(.+)<\/p>/ )[1].to_s()
      request = sprintf( 'UPDATE daily set Cond = "%s" %s', cond, update )
      puts( request )
      client.query( request )

      # avg
      # puts( td[i*5+4] )
      avgHigh = td[i*5].join().split( "/" )[0].match( /([0-9]+)/ )[0].to_s()
      avgLow  = td[i*5].join().split( "/" )[1].match( /([0-9]+)/ )[0].to_s()
      request = sprintf( 'UPDATE daily set Avg = "%s/%s" %s', avgHigh, avgLow, update )
      puts( request )
      client.query( request )
    end
  }
  client.close()
end

main()
