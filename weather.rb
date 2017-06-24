require 'mysql'

def getDate( date, client )
  statement = client.query( 'SELECT YMD FROM daily WHERE YMD = ' + date )
  ret = ""
  statement.each do |index|
    ret = index[0]
  end
  return ret
end

def getLargeTemp( date, client )
  statement = client.query( 'SELECT HiLo FROM daily WHERE YMD = ' + date )
  ret = ""
  statement.each do |index|
    ret = index[0].split( "/" )[0]
  end
  return ret
end

def getSmallTemp( date, client )
  statement = client.query( 'SELECT HiLo FROM daily WHERE YMD = ' + date )
  ret = ""
  statement.each do |index|
    ret = index[0].split( "/" )[1]
  end
  return ret
end

def getPrecip( date, client )
  statement = client.query( 'SELECT Precip FROM daily WHERE YMD = ' + date )
  ret = ""
  statement.each do |index|
    ret = index[0]
  end
  return ret
end

def getSnow( date, client )
  statement = client.query( 'SELECT Snow FROM daily WHERE YMD = ' + date )
  ret = ""
  statement.each do |index|
    ret = index[0]
  end
  return ret
end

def getIconNum( date, client )
  statement = client.query( 'SELECT Icon FROM daily WHERE YMD = ' + date )
  ret = ""
  statement.each do |index|
    ret = index[0]
  end
  return ret
end

def getCond( date, client )
  statement = client.query( 'SELECT Cond FROM daily WHERE YMD = ' + date )
  ret = ""
  statement.each do |index|
    ret = index[0]
  end
  return ret
end

def getAvgLargeTemp( date, client )
  statement = client.query( 'SELECT Avg FROM daily WHERE YMD = ' + date )
  ret = ""
  statement.each do |index|
    ret = index[0].split( "/" )[0]
  end
  return ret
end

def getAvgSmallTemp( date, client )
  statement = client.query( 'SELECT Avg FROM daily WHERE YMD = ' + date )
  ret = ""
  statement.each do |index|
    ret = index[0].split( "/" )[1]
  end
  return ret
end

def main( arg )
  cmd = 'date "+%Y%m%d" -d "' + arg[0].gsub( "-", "" ) + ' days"'
  nowDate = `#{cmd}`.to_s()
  # puts( nowDate )

  client = Mysql::new( "127.0.0.1", "weather", "weather", "weather" )

  if( arg.include?( "-day" ) ) then
    return getDate( nowDate, client )

  elsif( arg.include?( "-lt" ) ) then
    return getLargeTemp( nowDate, client )

  elsif( arg.include?( "-st" ) ) then
    return getSmallTemp( nowDate, client )

  elsif( arg.include?( "-pre" ) ) then
    return getPrecip( nowDate, client )

  elsif( arg.include?( "-snow" ) ) then
    return getSnow( nowDate, client )

  elsif( arg.include?( "-i" ) ) then
    return getIconNum( nowDate, client )

  elsif( arg.include?( "-c" ) ) then
    return getCond( nowDate, client )

  elsif( arg.include?( "-alt" ) ) then
    return getAvgLargeTemp( nowDate, client )

  elsif( arg.include?( "-ast" ) ) then
    return getAvgSmallTemp( nowDate, client )

  end
  client.close()
  return "-1"
end

puts( main( ARGV ) )

