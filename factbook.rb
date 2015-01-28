require 'rubygems'
require 'nokogiri'
require 'nyaplot'
require 'open-uri'

BASE_CIA_URL = "https://www.cia.gov/library/publications/the-world-factbook"

# get list of countries in url
hash_country ={}
LIST_URL = "#{BASE_CIA_URL}/print/textversion.html"
page = Nokogiri::HTML(open(LIST_URL))
lines = page.css('span.category a')
lines.each{|line|  hash_country[line.text] = line['href'][2..-1] }

# initialize hashes
hash_region = {}
hash_coor = {}
hash_popu = {}
hash_internet = {}

# categorize countries in region, record coordinates information, population, and internet user
def parse_region(hash_country, hash_region,hash_coor,hash_popu, hash_internet)
  hash_country.each do |key|
    unless key[0] =~ /World/
      page = Nokogiri::HTML(open("#{BASE_CIA_URL}#{key[1]}"))
      data = page.css('table td div#field.category a')
      data.each do |item|
        if item.text =~ /Map references/
          location0 = item.parent.parent.parent.next_element
          hash_region[key[0]] = location0.css("td div.category_data").text.strip
        elsif item.text =~ /Population:/
          location1 = item.parent.parent.parent.next_element
          hash_popu[key[0]] = location1.css("td#data div.category_data").text.match(/\d+,?(\d+)?,?(\d+)?,?(\d+)/)[0].gsub(",",'')
        elsif item.text =~ /Geographic coordinates/
          location2 = item.parent.parent.parent.next_element
          if location2.css("td div.category_data")
            hash_coor[key[0]] = location2.css("td div.category_data").text.strip        
          else 
            hash_coor[key[0]] = location2.css("td#data div.category").text.strip
          end
        elsif item.text =~ /Internet users:/
          location3 = item.parent.parent.parent.next_element
          hash_internet[key[0]] = location3.css("td#data div.category_data").text.strip
        end
      end
    end
  end
end

parse_region(hash_country, hash_region,hash_coor,hash_popu, hash_internet)



# get country, url_book, region info from XML
hash_xml ={}

def parse_xml(hash_xml)
  page = Nokogiri::XML(open("#{BASE_CIA_URL}/wfbExt/sourceXML.xml"))
  page.css('country').each {|node| hash_xml[node['name']] = [node['fips'], node['Region']] if node['name']!=nil}
  # mapping correct url
  hash_xml.map {|item| item[1][0] = "/geos/countrytemplate_#{item[1][0].downcase}.html"}
end
parse_xml(hash_xml)
#puts hash_xml

def compare_xml(hash_xml,hash_region)
  print "\n"
  puts "Now checking map reference accuracy."
  flagf = 0
  flagt = 0
  # hash_region.map {|item| puts "#{item[0]}: Correct" or puts "#{item[0]}: Wrong! #{item[1]} should be #{hash_xml[item[0]][1]}"  if item[1] == hash_xml[item[0]][1]}
  
  hash_region.each do |item|
    if hash_xml[item[0]] == nil
      puts "#{item[0]}: #{item[1]} not show up in XML"
      flagf = flagf + 1
    elsif item[1] == hash_xml[item[0]][1]
      puts "#{item[0]}: Correct" 
      flagt = flagt +1
    else
      puts "#{item[0]}: Wrong! #{item[1]} => #{hash_xml[item[0]][1]}" 
      flagf = flagf + 1
    end 
  end
  puts "#{flagf} mismatches found, other #{flagt} regions are correct"
  print "\n"
end

compare_xml(hash_xml,hash_region)


# earth quake
target_region = "South America"
soa = hash_region.map{|key| key[0] if key[1] == target_region}.compact.uniq

def parse_earthquake(hash_country,soa)
  puts "List countries in south america that are prone to earthquake."
  target_url =[]
  soa.each do |country|
    # puts country
    hash_country.map {|key| target_url << key if key[0] == country }.compact.uniq
  end
# puts target_url

# identifier: flag
  target_url.each do |key|
    puts "#{key[0]}"
    flag = false
    page = Nokogiri::HTML(open("#{BASE_CIA_URL}#{key[1]}")) 
    data = page.css('table tr td#data div.category_data')
    data.each do |content|
      if content.text =~ /earthquake/
        puts content.text 
        flag = true
      end
    end
    data = page.css('table tr td#data div.category')  
    data.each do |content|
      if content.text =~ /earthquake/
        puts content.text 
        flag = true
      end
    end
    puts "earthquake detected: #{flag}"+"\n"
  end
  
  print "\n"
end

parse_earthquake(hash_country,soa)


# Europe elevation
target_region = "Europe"
eur = hash_region.map{|key| key[0] if key[1] == target_region}.compact.uniq
hash_elevation = {}

def parse_elevation(hash_country,eur,hash_elevation)
  puts "list countries in Europe with lowest elevation."
  target_url =[]
  eur.each do |country|
    hash_country.map {|key| target_url << key if key[0] == country }.compact.uniq
  end
  
  target_url.each do |key|
    page = Nokogiri::HTML(open("#{BASE_CIA_URL}#{key[1]}"))
    data = page.css('table td div#field.category a')
    data.each do |item|
      if item.text =~ /Elevation/
        location = item.parent.parent.parent.next_element
        elevation = location.css("div.category span.category_data").text.match(/-?\d+,?(\d+)?/)[0].sub(",",'')
        hash_elevation[key[0]] = elevation
        #hash_region[key[0]] = location.css("td div.category_data").text.strip
      end
    end
  end
  hash_elevation = hash_elevation.sort_by {|country, value|value.to_f}
  hash_elevation.map {|country| puts "#{country[0]}: #{country[1]}"}
  print "\n"
end

parse_elevation(hash_country,eur,hash_elevation)


# list countries in southeastern hemisphere
# S, E for southeastern, N E for northeastern etc.
hemisphere = "southeastern"
def parse_hemisphere(hash_coor, hemisphere)
  puts "List countries in #{hemisphere} hemisphere."
  hash_hemisphere ={}
  hash_hemisphere["northeastern"]=["N","E"]
  hash_hemisphere["southeastern"]=["S","E"]
  hash_hemisphere["northwestern"]=["N","W"]
  hash_hemisphere["southwestern"]=["S","W"]
  array_hemisphere = hash_hemisphere[hemisphere.downcase]
  i=0
  hash_coor.each do |key|
    temp = key[1].match(/\d+ \d+ (.*), \d+ \d+ (.*)/)
    unless temp == nil
      if temp[1] == array_hemisphere[0]
        if temp[2] == array_hemisphere[1]
          i = i+1
          puts "#{key[0]}: #{key[1]}"
        end
      end      
    end
  end
  puts "In total: #{i} countries"
  print "\n"
end

parse_hemisphere(hash_coor, hemisphere)


# List countries in Asia with >10 political parties
# find keyword Asia, can be changed to Europe etc.
asia = hash_region.map{|key| key[0] if key[1] =~ /Asia/}.compact.uniq
hash_political = {}
# set threshold
threshold = 10

def parse_political(hash_political,asia,hash_country, threshold)
  puts "list countries in asia with more than #{threshold} political parties."
  target_url =[]
  asia.each do |country|
    hash_country.map {|key| target_url << key if key[0] == country }.compact.uniq
  end
  
  target_url.each do |key|
    flag = 0
    page = Nokogiri::HTML(open("#{BASE_CIA_URL}#{key[1]}"))
    data = page.css('table td div#field.category a')
    data.each do |item|
      if item.text =~ /parties/
        location = item.parent.parent.parent.next_element
        location.css("div.category_data").map { |part| flag = flag + 1 unless part.text.length<10 or part.text =~ /there are/}
        hash_political[key[0]] = flag
        if flag>=threshold
          puts "#{key[0]} has #{flag} political parties."
        end
      end
    end
  end
  print "\n"
end

parse_political(hash_political,asia,hash_country, threshold)


# Find top N countries with highest electricity consumption per capita
# get electricity consumption
hash_elec = {}
hash_avrelec = {}
top = 5
def parse_elec(hash_elec,hash_popu, hash_avrelec,top)  
  puts ""
  page = Nokogiri::HTML(open("#{BASE_CIA_URL}/rankorder/2233rank.html"))
  data = page.css('table tr td td.region a strong')
  data.map {|item| hash_elec[item.text.strip] = item.parent.parent.next_element.css('div').text.strip.gsub(",",'')}
  
  # caluclate electricity consumption per capita
  hash_elec.map {|item| hash_avrelec[item[0]] = item[1].to_f/hash_popu[item[0]].to_f }
  hash_avrelec = hash_avrelec.sort_by {|country, value| value.to_f}.reverse
  puts hash_avrelec.to_a[0...top]
  print "\n"
end

parse_elec(hash_elec,hash_popu, hash_avrelec,top)


# list countries with religion, which covers >80% population or <50% population
hash_religion = {}
above = 80
below = 50
def parse_religion(hash_religion, above, below)
  puts "religion"  
  page = Nokogiri::HTML(open("#{BASE_CIA_URL}/fields/2122.html"))
  data = page.css('table tr td tr td.fl_region a')
  data.map {|item| hash_religion[item.text.strip] = item.parent.next_element.text.strip.gsub("\n",'')}
  hash_religion.each do |item|
    if item[1] =~ /dominant/
      puts " #{item[0]};  #{item[1]}"
    elsif !(item[1] =~ /\d/)
      puts " #{item[0]};  Unclear"
    else
      if item[1].match(/\d+.?(\d+)?%/)[0].to_f >= above
        if item[1] =~ /,/
          puts " #{item[0]};  #{item[1].slice(0...(item[1].index(',')))}"
        else
          puts " #{item[0]};  #{item[1]}"
        end
      elsif item[1].match(/\d+.?(\d+)?%/)[0].to_f <= below
        temp = item[1]
        if temp =~ /note:/
          puts " #{item[0]};  #{temp.slice(0...(temp.index("note:"))).strip}"
        else
          puts " #{item[0]};  #{temp}"
        end
      end
    end
  end  
  print "\n"
end
 
parse_religion(hash_religion, above, below)

# landlock
hash_lock ={}
hash_bound = {}
def parse_lock(hash_lock, hash_bound)
  # get landlock label
  page = Nokogiri::HTML(open("#{BASE_CIA_URL}/fields/2060.html"))
  data = page.css('table tr td tr td.fl_region a')
  data.map {|item| hash_lock[item.text.strip] = item.parent.next_element.text.strip.gsub("\n",'') if item.parent.next_element.text =~ /landlock/}
  # check boundary
  page = Nokogiri::HTML(open("#{BASE_CIA_URL}/fields/2096.html"))
  data = page.css('table tr td tr td.fl_region a')
  data.map {|item| hash_bound[item.text.strip] = item.parent.next_element.text.strip.gsub("\n",'')}  
  hash_lock.each do |item|
    temp  = hash_bound[item[0]]
    # extract boundary countries
    item[1] = (temp.slice((temp.index('countries:')+10)..-1).gsub(/(\d+),(\d+)/,'').gsub(/\d/,'').gsub(/(m|km)/,'')+",").split(",")
    # puts "#{item[0]}, number of adjacent:#{item[1].length}"
    if item[1].length == 1
      puts "#{item[0]} Entirely landlocked by: #{item[1][0].strip}"
    end
  end
  print "\n"
end
parse_lock(hash_lock, hash_bound)

hash_internetpercent = {}
def parse_internet(hash_internet,hash_popu, hash_internetpercent)  
  hash_internet.each do |country|
    if country[1] =~ /million/
      hash_internetpercent[country[0]] = country[1].match(/(\d+).?(\d+)?/)[0].to_f * (10 ** 6) / hash_popu[country[0]].to_f
    elsif country[1] =~ /billion/
      hash_internetpercent[country[0]] = country[1].match(/(\d+).?(\d+)?/)[0].to_f  * (10 ** 9) / hash_popu[country[0]].to_f
    elsif country[1].match(/\d/) == nil
      puts "#{country[0]} has no internet users."
    else
      hash_internetpercent[country[0]] = country[1].match(/(\d+),?(\d+)?/)[0].gsub(",","").to_f / hash_popu[country[0]].to_f
    end
  end
  hash_internetpercent = hash_internetpercent.sort_by {|country,value| value.to_f}.reverse
  hash_internetpercent[0..4].map {|country| puts "#{country[0]}: #{(country[1] * 100).round(2)}%" }
  print "\n"
end

parse_internet(hash_internet,hash_popu, hash_internetpercent)  

def draw_scatterplot(hash_internetpercent, hash_avrelec)
  plot_x, plot_y = [],[]
  hash_internetpercent.each_with_index do |country,index|
    if country[1] == nil
      plot_x << 0
    else
      plot_x << country[1].round(3) 
    end
    
    if hash_avrelec[country[0]] == nil
      plot_y << 0
    else 
      plot_y << hash_avrelec[country[0]].round(3) 
    end
    # puts "#{country[0]}:"
    # puts "Internet Coverage: #{plot_x[index]}; Electricity per capita: #{plot_y[index]}"
  end
  
  # draw scatter plot
  plot_y.map {|item,index| item = Math.log(item) if item!=0}
  plot = Nyaplot::Plot.new
  sc = plot.add(:scatter, plot_x, plot_y)
  plot.export_html
  
end
draw_scatterplot(hash_internetpercent, hash_avrelec)