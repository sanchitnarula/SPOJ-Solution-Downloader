#!/usr/local/bin/ruby

require 'mechanize'
require 'fileutils'
require 'highline/import'

def SockError
	puts 'Please connect to internet.'
end

def printResult(count)
	puts "\n"
	if count >=1
		puts " Downloaded All solutions Successfully !"
	else
		puts "No Solutions Found ! Solve Some Problems :) "
	end
end

def createFile (probname,subid,code)
	dirname="SPOJ"
	FileUtils.mkdir_p(dirname) unless Dir.exists?(dirname)
	dirname="SPOJ/#{probname}"
	FileUtils.mkdir_p(dirname) unless Dir.exists?(dirname)
	filename="#{dirname}/#{subid}"
	target=open(filename,'w')
	target.write(code)
	target.close
end

def invalidCredentials
	puts "\n"
	puts "Invalid Credentials !!"
		exit(1)
end
def checkValidation (username,password)
	if username.length==0 || password.length==0
		invalidCredentials()
	end
end
agent = Mechanize.new

print "Spoj Username : "
username=gets.chomp()
password = ask("Spoj password: ") { |q| q.echo = false }
checkValidation(username,password)
begin
	page = agent.get("http://www.spoj.com/")
	form = page.form_with(:id => 'login-form')
	form.login_user = username
	form.password = password
	page = form.submit

	signedpage=agent.get("http://www.spoj.com/status/#{username}/signedlist/")
    str=signedpage.body

   
	if str.length == 0
		invalidCredentials()
	end

	i=1
	while i<10
		if !str.nil?
			str=str.split("\n",2).last
		end
		i=i+1
		#chopping out waste lines 
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

		if ((status <=> "AC")==0)
			puts "Downloading #{probname} with id: #{subid} "
			code=agent.get("http://www.spoj.com/files/src/save/#{subid}").body
			createFile(probname,subid,code)
			count=count+1
		end
		
	end

	printResult(count)


rescue SocketError
	  SockError()
end
