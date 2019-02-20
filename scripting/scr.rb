#!/usr/bin/env ruby

require 'oauth2'
require 'terminal-table'
require 'json'

UID="2d0d880c05bb3571714892bce3611f4f41ff4abf433525acb7979facfb22f251"
SECRET="25b2337b7282367d43a485aa0d28c3d2dd650336c4fadefb5332278fb7b3bacc"
# Create the client with your credentials
client = OAuth2::Client.new(UID, SECRET, site: "https://api.intra.42.fr")
# Get an access token
@token = client.client_credentials.get_token
@base = "/Users/hrice/Desktop/init/scripting/irka-base.json"

$i = 0

def update_users
  if (!File.file?(@base))
    f = File.open(@base, 'a')
    while users = @token.get("/v2/campus/17/users" ,params: {page: {number: $i}}).parsed do
      f.write(users)
      sleep(2)
      $i += 1
      puts $i*30
    end
    f.close
  end
end

def get_id(login)
  fd = File.open(@base, 'r')
  data = ""
  fd.each do |line|
    data << line
  end
  fd.close
  json_data = JSON.parse(data)
  json_data.each do |str|
    if login == str["login"]
      return str["id"]
    end
  end
end

def events()
 exams = @token.get("/v2/campus/17/exams").parsed
 rows = []

 exams.each do |child|
   d = Date.parse(child['end_at'])
   beginTime = Time.parse(child['begin_at']).localtime("+03:00").strftime('%d %b %H:%M')
   if d >= Date.today
     if (child['nbr_subscribers'] < child['max_people'])
       rows << [child['name'], "\e[32m"+child['nbr_subscribers'].to_s+"\e[0m / \e[31m"+child['max_people'].to_s+"\e[0m", beginTime]
     else
       rows << [child['name'], "\e[31m"+child['nbr_subscribers'].to_s+"\e[0m / \e[31m"+child['max_people'].to_s+"\e[0m", beginTime]
     end
   end
 end
 table = Terminal::Table.new :title => "Events", :headings => ["Name of event", "Places", "Begin at"], :rows => rows
 table.style = {:padding_left => 2, :padding_right => 2, :border_x => "=", :border_i => "x"}
 puts table
end

def get_ira(id)
 user = @token.get("/v2/users/#{id}").parsed
 puts user
end

# id = get_id(ARGV[0])
# puts id
# update_users
events
