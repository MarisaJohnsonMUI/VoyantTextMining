# Marisa Johnson
# 7 August 2019
# Digital Initiatives
# Getty Research Institute

class VoyantReader
	# get and set instance variables
	attr_accessor :urls
	
	# NECESSARY?
	# create the object
	def initialize(url = "http://google.com")
		@urls = url
	end
	
	# upload csv file to a csv called table
	def parse_text
		require 'csv'
		
		iterator = 0
		# create a two dimensional array
		# NOTE:n save links.csv (Huxtable links) to your computer
		table = CSV.read('links.csv')
		
		require 'open-uri'
		
		# loop through contents of table
		myCount = 0
		currUrl = ''
		#for i in 0..(table.length - 1) do
		# run 10 times for testing
		for i in 509..511 do
			currUrl = table[i][0]
			# don't print nil string
			if currUrl.nil?
				next
			elsif currUrl.include? "https"
				# FOUND A USEFUL URL
				begin
					f = open(currUrl)
				rescue Timeout::Error
					puts "The request for a page at #{currUrl} timed out... skipping"
					next
				rescue IOError
					puts "The request for a page at #{currUrl} returned an error."
					next
				rescue OpenURI::HTTPError
					puts "The request for a page at #{currUrl} returned an HTTP error."
					next
				rescue URI::InvalidURIError
					puts "The URL #{currUrl} is invalid."
					next
				else # no exceptions!!
					# read each line of the currently opened url
					puts currUrl
					
					# prints out each line at currUrl
					f.each_line do |line|
						puts line
					end
					
					myAuthor = ''
					myDate = ''
					myYear = 0
					myTitle = ''
					myText = ''
					
					f.each_line do |line|
					
				##########################################################################
						
						# find the author
						
						if line.include? '<meta name="author" content="'
							# index of where the author begins
							authorIndicator = '<meta name="author" content="'
							authorBegin = line.index(authorIndicator) + authorIndicator.length
							
							# index of where the author ends
							authorEnd = line.index('" />') - 1
							
							# create substring of author from its begin and end
							author = line[authorBegin..authorEnd]
							
							puts "\tAuthor: #{author}";
							
							# CHECK TO SEE IF AUTHOR IS ADA LOUISE HUXTABLE
							if author.include? "Ada Louise Huxtable"
								# set myAuthor equal to the author found
								myAuthor = author
								
								next # will exit loop for this 
							end # end of if statement to check if Huxtable is author
							
						elsif line.include? '"true" name="byl" content="By '
							# index of where the author begins
							authorIndicator = '"true" name="byl" content="By '
							authorBegin = line.index(authorIndicator) + authorIndicator.length
							
							# index of where the author ends
							lastPart = line[authorBegin..-1]
							authorEnd = lastPart.index('"/>') + authorBegin - 1
							
							# create substring of author from its begin and end
							author = line[authorBegin..authorEnd]
							puts "\tAuthor: #{author}";
							
							# CHECK TO SEE IF AUTHOR IS ADA LOUISE HUXTABLE
							if author.include? "Ada Louise Huxtable"
								# set myAuthor equal to the author found
								myAuthor = author
								
								next # will exit loop for this 
							end # end of if statement to check if Huxtable is author
							
						elsif line.include? '"true" name="byl" content="'
							# index of where the author begins
							authorIndicator = '"true" name="byl" content="'
							authorBegin = line.index(authorIndicator) + authorIndicator.length
							
							# index of where the author ends
							lastPart = line[authorBegin..-1]
							authorEnd = lastPart.index('"/>') + authorBegin - 1
							
							# create substring of author from its begin and end
							author = line[authorBegin..authorEnd]
							
							
							# titleize author name
							currName = author.split
							currName.each do |name|
								name.capitalize!
							end

							# turn elements of array into a string
							author = currName.join(" ")
							puts "\tAuthor: #{author}";
							
							# CHECK TO SEE IF AUTHOR IS ADA LOUISE HUXTABLE
							if author.include? "Ada Louise Huxtable"
								# set myAuthor equal to the author found
								myAuthor = author
								
								next # will exit loop for this 
							end # end of if statement to check if Huxtable is author
						
						# AUTHORS IN THIS STYLE ARE NOT EXECUTING THE DATE	
						elsif line.include? '<p class="css-exrw3m evys1bk0">ADA LOUISE HUXTABLE'
							# index of where the author begins
							authorIndicator = '<p class="css-exrw3m evys1bk0">ADA LOUISE HUXTABLE'
							alhLength = "ADA LOUISE HUXTABLE".length
							# need to add number of characters in ^ substring
							authorBegin = line.index(authorIndicator) + authorIndicator.length - alhLength
							
							# index of where the author ends
							lastPart = line[authorBegin..-1]
							if lastPart.include? ' New York City</p></div><aside class='
								authorEnd = lastPart.index(' New York City</p></div><aside class=') + authorBegin - 1
							else lastPart.include? '</p>'
								authorEnd = lastPart.index('</p>') + authorBegin - 1
							end
							
							# create substring of author from its begin and end
							author = line[authorBegin..authorEnd]
							
							# titleize author name
							currName = author.split
							currName.each do |name|
								name.capitalize!
							end

							# turn elements of array into a string
							author = currName.join(" ")
							puts "\tAuthor: #{author}";
							puts "\t=> found here!!"
							
							# CHECK TO SEE IF AUTHOR IS ADA LOUISE HUXTABLE
							if author.include? "Ada Louise Huxtable"
								# set myAuthor equal to the author found
								myAuthor = author
								
								next # will exit loop for this 
							end # end of if statement to check if Huxtable is author
							
						elsif line.include? '<p class="css-exrw3m evys1bk0">To the Editor:'
							# this is a letter to the editor
							puts "\t=> Letter to the Editor, not Huxtable"
						end # end of if statement checking for author
						
				##########################################################################
						
						# find the date
						
						if line.include? '<meta name="DISPLAYDATE" content="'
							puts "META NAME DATE"
							# index of where the date begins
							dateIndicator = '<meta name="DISPLAYDATE" content="'
							dateBegin = line.index(dateIndicator) + dateIndicator.length
			
							#index of where the date ends
							lastPart = line[dateBegin..-1]
							dateEnd = lastPart.index('" />') + dateBegin - 1
							
							#puts "Date Begin: #{dateBegin}\tDate End: #{dateEnd}"
			
							date = line[dateBegin..dateEnd]
							myDate = date
							puts "\tDate: #{date}"
			
							year = (date[date.length - 4,4]).to_i
							myYear = year
							puts "\tYear: #{year}"
						
						# NOT BEING EXECUTED WITH P CLASS
						elsif line.include? 'dateTime="'
							#puts "ENTERING DATE TIME STATEMENT"
							# index of where the date begins
							dateIndicator = 'dateTime="'
							dateBegin = line.index(dateIndicator) + dateIndicator.length + '2000-09-24">'.length
							
							# index of where the date ends
							lastPart = line[dateBegin..-1]
							dateEnd = lastPart.index('</time>') + dateBegin - 1
							
							#print "Date Begin: #{dateBegin}"
							#print "\tDate End: #{dateEnd}"
							
							date = line[dateBegin..dateEnd]
							myDate = date
							puts "\tDate: #{date}"
							
							year = (date[date.length - 4,4]).to_i
							myYear = year
							puts "\tYear: #{year}"
						end
						
				##########################################################################
				
						# find the title
					
				##########################################################################
				
						# find the body text
					
				##########################################################################
					
					end # end of f.each_line do |line|
					
				##########################################################################
				
				# write to CSV
				
				#puts currUrl
				#puts "\tAuthor: #{myAuthor}"
				#puts "\tmyDate: #{myDate}"
				#puts "\tmyYear: #{myYear}"
				#puts "\tmyTitle: #{myTitle}"
				#puts "\tmyText: #{myText}"
					
				# send myAuthor/myDate/myYear/.../ values to CSV file
				#if myAuthor != ''
					# author is Ada Louise Huxtable
					# write to CSV
				#end
					
				end # end of begin/rescue/end
				myCount += 1
			
			# don't print header
			else
				next
			end # if statement to only work w/ strings that contain 'https'
		end # end of parse text function
		
		#puts "I counted #{myCount} urls"
		
		# for loop through the table you've created
		# use iterator to access table
		
		
		# opens CSV file of links one line at a time
		#CSV.foreach("/Users/marisajohnson/Desktop/RubyProjects/links.csv") do |row|
			# this opens => prints out every row of the CSV column s
			#link = row[iterator][0]
			#puts link
			
			#function to check if page can be opened
			#require 'open-uri'
			# ERROR IN NEXT LINE
			#f = open(link)
	
			# make sure URL opens
			#f = open('www.com')
			
			# make sure Ada Louise Huxtable is the author
	
			# grab the text located at this page
	
			# clean up this grabbed text
	
			# write to file
			# File.open("out.txt", 'w') {|file| file.write("WRITE YOUR STUFF HERE")}
	
			# MUST DO TAB DELIMITED CSV
			# write cleaned text to a CSV file
			#CSV.open("cleanLinks.csv", "w") do |csv|
				#csv << [ article text ]
			#end
			
			# increment iterator
			#iterator += 1
		
		
		#end
	end
end

if __FILE__ == $0
	# create a text to parse and print
	myFile = VoyantReader.new
	myFile.parse_text
	
end








