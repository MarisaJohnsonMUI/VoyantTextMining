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
		headers = ["URL", "Author", "Date", "Year", "Title", "Text", "Digitized?"]
		
		# write headers to CSV
		CSV.open("/Users/marisajohnson/Desktop/RubyProjects/myCSV.csv", "w") do |csv|
			csv << headers
		end
		
		iterator = 0
		# create a two dimensional array
		# NOTE:n save links.csv (Huxtable links) to your computer
		table = CSV.read('links.csv')
		
		require 'open-uri'
		
		csvRow = Array.new
		
		myAuthor = ''
		myDate = ''
		myYear = 0
		myTitle = ''
		myText = ''
		digitized = true
		
		# loop through contents of table
		myCount = 0
		currUrl = ''
		#for i in 0..(table.length - 1) do
		# run 10 times for testing
		for i in 0..771 do
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
					#puts currUrl
					
					# prints out each line at currUrl
					#f.each_line do |line|
						#puts line
					#end
					
					# empty out contents of csvRow array for each new article
					csvRow.clear 
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
							
							#puts "\tAuthor: #{author}";
							
							author.slice!('amp;amp;')
							
							myAuthor = author
								
								#next # will exit loop for this 
							#end # end of if statement to check if Huxtable is author
							
						elsif line.include? '"true" name="byl" content="By '
							# index of where the author begins
							authorIndicator = '"true" name="byl" content="By '
							authorBegin = line.index(authorIndicator) + authorIndicator.length
							
							# index of where the author ends
							lastPart = line[authorBegin..-1]
							authorEnd = lastPart.index('"/>') + authorBegin - 1
							
							# create substring of author from its begin and end
							author = line[authorBegin..authorEnd]
							#puts "\tAuthor: #{author}";
							
							author.slice!('amp;amp;')
							
							myAuthor = author
							
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
							#puts "\t dirty author: #{author}";
							
							author.slice!('amp;amp;')
							
							myAuthor = author
						
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
							#puts "\tAuthor: #{author}";
							#puts "\t=> found here!!"
							
							author.slice!('amp;amp;')
							
							myAuthor = author
							
						elsif line.include? '<p class="css-exrw3m evys1bk0">To the Editor:'
							# this is a letter to the editor
							#puts "\t=> Letter to the Editor, not Huxtable"
						end # end of if statement checking for author
						
				##########################################################################
						
						# find the date
						
						if line.include? '<meta name="DISPLAYDATE" content="'
							#puts "META NAME DATE"
							# index of where the date begins
							dateIndicator = '<meta name="DISPLAYDATE" content="'
							dateBegin = line.index(dateIndicator) + dateIndicator.length
			
							#index of where the date ends
							lastPart = line[dateBegin..-1]
							dateEnd = lastPart.index('" />') + dateBegin - 1
							
							#puts "Date Begin: #{dateBegin}\tDate End: #{dateEnd}"
			
							date = line[dateBegin..dateEnd]
							myDate = date
							#puts "\tDate: #{date}"
			
							year = (date[date.length - 4,4]).to_i
							myYear = year
							#puts "\tYear: #{year}"
						
						# NOT BEING EXECUTED WITH P CLASS
						elsif line.include? 'dateTime="'
							#puts "ENTERING DATE TIME STATEMENT"
							# index of where the date begins
							dateIndicator = 'dateTime="'
							dateBegin = line.index(dateIndicator) + dateIndicator.length + '2000-09-24">'.length
							
							# index of where the date ends
							lastPart = line[dateBegin..-1]
							dateEnd = lastPart.index('</time>') + dateBegin - 1
							
							# dateTime="1970-10-25T01:00:00-04:00">Oct. 25, 1970</time>
							if (lastPart[0] == '0') || (lastPart[0] == '1')
								#puts "Must fix date begin!"
								dateBegin += 'T01:00:00-04:00'.length
							end
							
							#print "Date Begin: #{dateBegin}"
							#print "\tDate End: #{dateEnd}"
							
							date = line[dateBegin..dateEnd]
							myDate = date
							#puts "\tDate: #{date}"
							
							year = (date[date.length - 4,4]).to_i
							myYear = year
							#puts "\tYear: #{year}"
						
						# try to find date in URL if this all fails
						# itemprop="datePublished dateCreated" content="1975-11-23T05:00:00.000Z"/>
						elsif line.include? 'itemprop="datePublished dateCreated" content="'
							#puts "found date published"
							
							# create a hash of months
							months = { "01" => "January", "02" => "February", "03" => "March", "04" => "April", "05" => "May", "06" => "June", "07" => "July", "08" => "August", "09" => "September", "10" => "October", "11" => "November", "12" => "December"}
							
							# index of where the date begins
							dateIndicator = 'itemprop="datePublished dateCreated" content="'
							dateBegin = line.index(dateIndicator) + dateIndicator.length
							
							# date substring
							dateLength = '1975-11-23'.length
							date = line[dateBegin, dateLength]
							
							#year
							yearInt = date[0, 4]
							year = yearInt.to_i
							#puts "\tYear: #{year}"
							
							#month
							month = months[date[5,2]]
							
							#day
							dayInt = date[8,2]
							day = dayInt.to_i
							
							# combined date
							combDate = "#{month} #{day}, #{year}"
							#puts "\tDate: #{combDate}"
							
							myDate = combDate
							myYear = year
							
						end # end of date and year if statements
						
				##########################################################################
				
						# find the title
						if (line.include? '<title>') || (line.include? '<title data-rh="true">')
							# index of where the title begins
							if line.include? '<title>'
								titleIndicator = '<title>'
							elsif line.include? '<title data-rh="true">'
								titleIndicator = '<title data-rh="true">'
							end
							
							titleBegin = line.index(titleIndicator) + titleIndicator.length
							
							#puts line[line.index(titleIndicator)..-1]
							
							if line.include? '</title>'
								# index of where the title ends
								titleEnd = line.index('</title>')
								# need to subtract one so that the < of </title> is not included
								titleEnd -= 1
								
								title = line[titleBegin..titleEnd]
							else
								title = line[titleBegin..-1]
							end
							
							# clean up title
							junk = ''
							
							# remove &#x27;
							numDel = title.count('&#') / 2
							#if numDel != 0
								#puts "Dirty Title: #{title}\nNeed to delete #{numDel} from title"
							#end
							
							# counter for number of &#x27; to delete
							m = 0
							# deletes each &#x27; from string
							for j in 0..(numDel - 1) do
								if title.include? '&#'
									junkBegin = title.index('&#')
									junk = title[junkBegin,6]
									title.slice!(junk)
								end
							end
							
							
							
							# remove ' - The New York Times'
							if title.include? ' The Public Editor'
								title.slice! (' The Public Editor')
							end
							
							if title.include? ' - The New York Times'
								title.slice! (' - The New York Times')
							end
							
							# replace &amp; with &
							if title.include? '&amp;'
								title.sub! '&amp;', '&'
							end
							
							# remove 'ARCHITECTURE VIEW;' from string
							if title.include? 'ARCHITECTURE VIEW; '
								title.slice! ('ARCHITECTURE VIEW; ')
							end
							
							# trim leading and tailing white space
							title.strip
							
							#puts "\tTitle: #{title}"
							#puts ''
							
							# IF NECESSARY, GET TITLE FROM URL?
							# titleize the title??
							
							myTitle = title
						
						end # end of title if statements
					
				##########################################################################
				
						# find the body text
						if (line.include? '<p class="story-body-text" itemprop="articleBody">') || (line.include? '<p class="css-exrw3m evys1bk0">') || (line.include? '<p class="story-body-text story-content"') || (line.include? '<p class="css-1byx4j2">')
							bodyIndicator = ''
							
							# index of where the text body begins
							if line.include? '<p class="story-body-text" itemprop="articleBody">'
								bodyIndicator = '<p class="story-body-text" itemprop="articleBody">'
								bodyIndicator = '<p class="story-body-text" itemprop="articleBody">'
								
								# counts number of total paragraphs
								numPgh = line.scan(/<p class="story-body-text" itemprop="articleBody">/).length
							
							elsif line.include? '<p class="css-exrw3m evys1bk0">'
								bodyIndicator = '<p class="css-exrw3m evys1bk0">'
								
								# counts number of total paragraphs
								numPgh = line.scan(/<p class="css-exrw3m evys1bk0">/).length
							
							elsif line.include? '<p class="story-body-text story-content"'
								bodyIndicator = '<p class="story-body-text story-content"'
								
								# counts number of total paragraphs
								numPgh = line.scan(/<p class="story-body-text story-content"/).length
							elsif line.include? '<p class="css-1byx4j2">'
								bodyIndicator = '<p class="css-1byx4j2">'
								
								# counts number of total paragraphs
								# puts "entering undigitized article"
								numPgh = line.scan(/<p class="css-1byx4j2">/).length
							end
							
							#puts ''
							#puts "#{numPgh} paragraph(s) in this line "
							#puts ''
							
							# substring you're looking at for the body
							findBody = line
							
							# loop through body begin to end 18 times total
							# add each iteration starting from the previous end
							# update lastPart to begin after new bodyBegin
							# clean extraneous formatting from each loop
							totalBody = ''
							
							myCount = 0
							
							# ERROR:  `-': no implicit conversion of Fixnum into Array
							for j in 0..(numPgh - 1) do
								# index of where text body begins
								bodyBegin = findBody.index(bodyIndicator)
								
								# index of where the text body ends
								lastPart = findBody[bodyBegin..-1]
								
								# ERROR: nil - 1 + bodyBegin
								if lastPart.index('</p>') == nil
									#puts lastPart
									
									if lastPart.include? '<!-- -->'
										bodyEnd = lastPart.index('<!-- -->') - 1 + bodyBegin
									elsif lastPart.include? '<br />'
										bodyEnd = lastPart.index('<br />') - 1 + bodyBegin
										#puts lastPart
										#puts "nil lastPart.index('</p>')"
									elsif lastPart.include? '</div>'
										bodyEnd = lastPart.index('</div>') - 1 + bodyBegin
									end
								# most paragraphs end in </p>
								else
									bodyEnd = lastPart.index('</p>') - 1 + bodyBegin
								end
								
								# check body begin and end
								#puts "Body Begin: #{bodyBegin}\tBodyEnd: #{bodyEnd}"
								
								# find this body
								body = findBody[bodyBegin..bodyEnd]
								
								# print unclean body
								#puts ''
								#puts "Unclean body: #{body}"
								#puts ''
								
								# clean this body
								# remove stuff between < >
								# replace &#x27; with '
								
								# array of things to remove
								toRemove = Array.new
								# make sure the array is clear
								toRemove.clear
								
								# remove things between < >
								# create an array of all the instances where body[i] == '<'
								arrayLeft = (0... body.length).find_all {|i| body[i] == '<'}
			
								# create an array of all the instances where body[i] == '>'
								arrayRight = (0... body.length).find_all {|i| body[i] == '>'}
								
								i = 0
			
								# for however long the arrayRight is
								arrayRight.length.times do
									# substring beginning at left brace and ending at right brace in line
									#puts "Array left: #{arrayLeft.at(i)}\tArray Right: #{arrayRight.at(i)}"
									inBraces = body[arrayLeft.at(i)..arrayRight.at(i)]
				
									# add inBraces to array of strings to remove
									toRemove.push(inBraces)
				
									# iterate counter
									i += 1
								end
								
								# replace everything in < > with ' '
								# for however long toRemove is
								m = 0
			
								toRemove.length.times do
									# if toRemove.at(i) is in body
									if body.include? toRemove.at(m)
										# slice! toRemove.at(i) from body
										body.sub!(toRemove.at(m), ' ')
									end
				
									# increment iterator
									m += 1
								end
								
								# remove &#____;
								if body.include? ('&#')
									#puts "Need to replace characters!"
									
									body.gsub!("&#x27;", "'")
									body.gsub!("&#8217;", "'")
									body.gsub!('&#8220;', '"')
									body.gsub!('&#8221;', '"')
								end
								
								body.gsub!("&quot;", '"')
								
								# print this body
								#puts "Clean body #{myCount}: #{body}"
								#puts ''
								# save this whole body into totalBody
								totalBody = totalBody + body + ' '
								
								# update findBody to start after bodyEnd
								#findBody = findBody[bodyEnd..-1]
								findBody.slice!(0..bodyBegin)
								#findBody.slice!(0..bodyEnd)
								
								#puts findBody
								myCount += 1
								
							end # end of for loop going through every paragraph
							
							#puts "\tBody: #{totalBody}"
							#puts ''
							
							# ERROR = incompatible character encodings: ASCII-8BIT and UTF-8
							myText = myText + totalBody.force_encoding(Encoding::UTF_8)
							
						
						end # end of body if statement
					
				##########################################################################
					
					end # end of f.each_line do |line|
					
				##########################################################################
				
				# write to CSV
				
				if myText == ''
					myText = 'THIS TEXT HAS NOT BEEN DIGITIZED'
					digitized = false
				else
					digitized = true
				end
				
				#puts "\tBody: #{myText}"
				#puts ''
				
				#puts "number #{myCount}"
				# add URL, author, date, year, title, and text to csvRow
				csvRow = Array.new
				csvRow = [currUrl, myAuthor, myDate, myYear, myTitle, myText, digitized]
				
				csvRow.map
					# do something
				#end
				
				csvRow.each do |info|
					puts info
				end
				
				puts ''
				
				#puts currUrl
				#puts "\tAuthor: #{myAuthor}"
				#puts "\tmyDate: #{myDate}"
				#puts "\tmyYear: #{myYear}"
				#puts "\tmyTitle: #{myTitle}"
				#puts "\tmyText: #{myText}"
				
				# escape all commas
				myAuthor.gsub!(',', '\,')
				myDate.gsub!(',', '\,')
				myTitle.gsub!(',', '\,')
				myText.gsub!(',', '\,')
				
				# write to CSV
				CSV.open("/Users/marisajohnson/Desktop/RubyProjects/myCSV.csv", "a") do |csv|
					csv << csvRow
				end
					
				# send myAuthor/myDate/myYear/.../ values to CSV file
				#if myAuthor.include? ('Huxtable')
					# author is Ada Louise Huxtable
					
					# write a formatted sring, A1 notation
					
					
					
				#end
					
				end # end of begin/rescue/end
				myCount += 1
			
			# don't print header
			else
				next
			end # if statement to only work w/ strings that contain 'https'
		end # end of parse text function
		
		#puts "I counted #{myCount} urls"
		
		# write to file
		# File.open("out.txt", 'w') {|file| file.write("WRITE YOUR STUFF HERE")}
	
		# MUST DO TAB DELIMITED CSV
		# write cleaned text to a CSV file
		#CSV.open("cleanLinks.csv", "w") do |csv|
			#csv << [ article text ]
		#end
			
		# increment iterator
		#iterator += 1
		
	end
end

if __FILE__ == $0
	# create a text to parse and print
	myFile = VoyantReader.new
	myFile.parse_text
	
end








