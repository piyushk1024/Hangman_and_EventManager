require "csv"
require 'sunlight/congress'
require 'erb'
require 'date'
puts "EventManager Initialized!"

Sunlight::Congress.api_key = "e179a6973728c4dd3fb1204283aaccb5"

contents = CSV.open "../event_attendees.csv" , headers:true, header_converters: :symbol
template_letter = File.read "../form_letter.erb"
row = 0

def zipcode_cleaner(zipcode)
  zipcode.to_s.rjust(5, "0")[0..4]
end

def freq_times(date)
  hour = date.split()[1].split(":")[0].to_i
  m,d,y = date.split()[0].split("/")
  day = Date.new(y.to_i+2000,m.to_i,d.to_i).cwday()
  return hour,day
end

def legit_by_zipcode(zipcode)
  legislators = Sunlight::Congress::Legislator.by_zipcode(zipcode)
end

def phone_cleaner(phone)
  phone = phone.to_s
  if phone.length < 10
    phone = "NA"
  elsif phone.length == 11
    if phone[0] == '1'
      phone = phone[1..10]
    else
      phone = "NA"
    end
  else
    phone = "NA"
  end
end

def file_writer(id,form_letter)
  Dir.mkdir("../output") unless Dir.exists? "../output"
  filename = "../output/thanks#{id}.html"

  File.open(filename, 'w') do |file|
    file.puts form_letter
  end
end

erb_template = ERB.new template_letter
@hours = Hash.new()
@days = Hash.new()
(0..23).each {|x| @hours[x] = 0}
(1..7).each {|x| @days[x] = 0}

day_name = ["Monday","Tuesday","Wednesday","Thursday","Friday","Saturday","Sunday"]
#puts contents.count()
contents.each do |row|
  id = row[0]

  h,d = freq_times(row[:regdate])
  @hours[h] += 1
  @days[d] += 1

  name = row[:first_name]
  zipcode = zipcode_cleaner(row[:zipcode])
  legislators= legit_by_zipcode(zipcode)

  form_letter = erb_template.result(binding)
  file_writer(id,form_letter)
end

freq_hour = @hours.key(@hours.values.max)
freq_day = @days.key(@days.values.max)
puts "Most frequent hour is #{freq_hour}"
puts "Most frequent day is #{day_name[freq_day-1]}"
