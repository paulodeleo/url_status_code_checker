# Usage from irb: 
# load 'status_code_checker.rb'
require 'csv'
require 'net/http'

# Counts how many lines were already processed
# TODO: check if file does not exists
csv_out_line_count = File.foreach("urls_with_status_code_checked.csv").inject(0) {|c, line| c+1}
# Opens origin csv file
origin = CSV.open("urls_for_status_code_checker.csv", :col_sep => ';')
puts "Skipping to line #{csv_out_line_count}" if csv_out_line_count > 0
# Reads each line from origin...
origin.each_with_index do |row, i|
	# Skips the amount of lines already processed
	next if i < csv_out_line_count
	
	puts "##{i}: #{row.inspect}"
	# Opening result file for appending
	result = CSV.open("urls_with_status_code_checked.csv", "a", :col_sep => ';')
	begin
		# The url is at the second column of the csv. Get it and store the response code
		request = Net::HTTP.get_response(URI.parse(row[1])) 
		http_code = request.code
	rescue URI::InvalidURIError
		# Sometimes the url is invalid (special chars in slug-like names)
		http_code = "invalid_url"
	ensure
		# Replicate the same csv row to the result file, adding a new column for the response code
		result << [row[0], row[1], http_code]
		result.close # Write the file every time a line is added. Guarantees resuming
	end
	# Wait 2 seconds between requests makes the server happy
	sleep(2)
end

origin.close