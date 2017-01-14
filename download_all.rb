#!/usr/local/bin/ruby

require 'mechanize'

agent = Mechanize.new

print "Spoj Username : "
	username=gets.chomp()
print "Spoj Password : "
	password=gets.chomp()

begin
page = agent.get("http://www.spoj.com/")
if File.exist?("cookies.yaml")
	  agent.cookie_jar.load("cookies.yaml")
else
	form = page.form_with(:id => 'login-form')
	form.login_user = username
	form.password = password
	page = form.submit
end
 str=agent.get("http://www.spoj.com/status/#{username}/signedlist/").body
if str.length == 0
	puts "Invalid Credentials"
	exit(1)
end
# puts str
i=1
while i<10
	if !str.nil?
		str=str.split("\n",2).last
	end
	i=i+1
end
count=0
while !str.nil?
	if !str.include? "|"
		break
	end
	eachrow=str.split("\n",2).first
	str=str.split("\n",2).last

	splitarray=eachrow.split("|",6)
	
	subid=splitarray[1].gsub(/\s+/, "")
	probname=splitarray[3].gsub(/\s+/, "")
	status=splitarray[4].gsub(/\s+/, "")
	if status == 'AC'
		puts "Downloading #{probname} with id: #{subid} "
		count=count+1
	end
	code=agent.get("http://www.spoj.com/files/src/save/#{subid}").body
	target=open("#{probname}-#{subid}.cpp",'w')
	target.write(code)
	target.close
end

puts "\n"
if count >=1
	puts " Downloaded All solutions Successfully !"
else
	puts "No Solutions Found ! Solve Some Problems :) "
end

agent.cookie_jar.save("cookies.yaml")

rescue SocketError
  puts 'Please connect to internet.'
end
