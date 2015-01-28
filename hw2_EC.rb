require 'rubygems'
require 'nokogiri'
require 'open-uri'
require 'matrix'


BASE_CIA_URL = "https://www.cia.gov/library/publications/the-world-factbook"


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
end

#compare_xml(hash_xml,hash_region)

hash_point = {}
hash_ptext = {}
def parse_coor(hash_xml,hash_point,hash_ptext)
  page = Nokogiri::HTML(open("#{BASE_CIA_URL}/fields/2011.html"))
  data = page.css('table tr td tr td.fl_region a')
  data.each do |node| 
    coor = node.parent.next_element
    hash_ptext[node.text.strip] = coor.text.strip.gsub("\n",'')
    if coor.text =~ /:/
      # puts "#{node.text.strip}"
      temp = coor.text.gsub("E","E;").gsub("W","W;").split(";")
      temp_array = []
      temp.each do |key|
        # in case E in the middle of words make a bad influence
        unless key.strip.gsub(/\W/,'') == "" or !(key =~ /\d/)
          str = key.slice((key.index(':')+1)..-1).strip.gsub(/\W/,'')        

          split = str.match(/(\d+)(\D)(\d+)(\D)/)[0..4]
          
          if split[2] == "N" 
            split[1] = split[1].to_i * 1/100 #/10 for 0.1 precision
          else
            split[1] = split[1].to_i * -1/100
          end
        
          if split[4] == "W"
            split[3] = split[3].to_i * -1/100 #/10 for 0.1 precision
          else
            split[3] = split[3].to_i * 1/100 #/10 for 0.1 precision
          end
        
          temp_array << [split[3],split[1]]
        end
      end
      hash_point[node.text.strip] = temp_array
      # puts "#{node.text.strip}  #{temp_array}"

    else
      # puts "#{node.text.strip}"
      split = coor.text.gsub(/\W/,'').match(/(\d+)(\D)(\d+)(\D)/)[0..4]
      if split[2] == "N" 
        split[1] = split[1].to_i * 1/100 #/10 for 0.1 precision
      else
        split[1] = split[1].to_i * -1/100
      end
      
      if split[4] == "W"
        split[3] = split[3].to_i * -1/100 #/10 for 0.1 precision
      else
        split[3] = split[3].to_i * 1/100 #/10 for 0.1 precision
      end
      hash_point[node.text.strip] = [split[3],split[1]]
      # puts "#{[split[3],split[1]]}"

    end
  end 
end

parse_coor(hash_xml,hash_point,hash_ptext)



def find_optimum(hash_point)
  hash_matrix = {}
  # change coordinates, input to matrix
  hash_point.each do |item|
    if item[1][0].class == Array
      temp_array = []
      item[1].map {|key| temp_array << [key[1]*-1 + 90 , key[0]+180]}
      hash_matrix[item[0]]= temp_array
    else
      hash_matrix[item[0]]= [item[1][1]*-1 + 90 , item[1][0]+180]
    end
  end
  # puts hash_matrix
  
  # input to matrix
  matrix = Array.new(181) {Array.new(361){0}}
  
  hash_matrix.each do |item|
    if item[1][0].class == Array
      item[1].each do |key| 
        # m_temp = *matrix
        # m_temp[key[0]][key[1]] = 1
        # matrix = Matrix[*m_temp]
        matrix[key[0]][key[1]] = matrix[key[0]][key[1]] + 1
      end
    else
      # m_temp = *matrix
      # m_temp[item[1][0]][item[1][1]] = 1
      # matrix = Matrix[*m_temp] 
      matrix[item[1][0]][item[1][1]] = matrix[item[1][0]][item[1][1]] + 1
    end      
  end
  
  # go through matrix
  # change to array... didn't find sufficient matrix sum, so sad

  sum = Array.new(181) {Array.new(351){0}}
  r_sum =Array.new(181) {Array.new(351){0}}
  rowmax = Array.new(181){[]}
  findmax = Array.new(171){0}
  matrix.each_with_index do |row,xindex|
    
    # calculate i~ i+10 row
    # puts "Now #{xindex} row"
    for j in 0..350
      # puts "#{row[j..j+10]}"
      r_sum[xindex][j] = row[j..j+10].reduce(:+)
      # puts "#{r_sum[xindex][j]} , #{j}"
    end  
  end
  
  # matrix.each_with_index do |row,xindex|
  for xindex in 0..matrix.length
    unless xindex > 170
      i  = xindex
      for i in xindex..xindex+9
        for j in 0..350
          sum[xindex][j]= r_sum[i][j] + sum[xindex][j]
        end
      end
      rowmax[xindex] = sum[xindex].each_with_index.max
      # puts "Row: #{xindex}  #{sum[xindex].each_with_index.max}"
    end    
  end
  
  rowmax.each_with_index {|row,index| findmax[index] = row[0]}
  findmax = findmax[0..170]
  
  temp = findmax.each_with_index.max
  
  # record the position in matrix that reach the maximum counts
  maxpos = [temp[1], rowmax[temp[1]][1]]

  lon_lowlmt, lon_uplmt = maxpos[1]-180, maxpos[1]-170
  lat_lowlmt, lat_uplmt = 80-maxpos[0], 90 - maxpos[0]
  
  # lon_lowlmt =  -180
  # lon_uplmt = -170
  # lat_lowlmt = -90
  # lat_uplmt = 90
  
  # display range
  if lon_lowlmt < 0
    dis_lon1 = (lon_lowlmt * -1).to_s + " W" 
  else
    dis_lon1 = lon_lowlmt.to_s + " E" 
  end
  
  if lon_uplmt < 0
    dis_lon2 = (lon_uplmt * -1).to_s + " W"  
  else
    dis_lon2 = lon_uplmt.to_s + " E" 
  end
  
  if lat_lowlmt < 0
    dis_lat1 = (lat_lowlmt * -1).to_s + " S"
  else
    dis_lat1 = lat_lowlmt.to_s + " N"
  end
  if lat_uplmt < 0
    dis_lat2 = (lat_uplmt * -1).to_s + " S"
  else
    dis_lat2 = lat_uplmt.to_s + " N"
  end
  
  puts "Longitude: #{dis_lon1} ~ #{dis_lon2};  Latitude: #{dis_lat1} ~ #{dis_lat2}"
  puts "$$$$$$$$$$$$$$$$$$$$$$$$$$$$"
  puts "$$$$ Results as follows $$$$"
  puts "$$$$$$$$$$$$$$$$$$$$$$$$$$$$"
  puts "Longitude: #{lon_lowlmt}~#{lon_uplmt}  Latitude:#{lat_lowlmt}~#{lat_uplmt}"

  
  # printout countries within the 10*10 region
  result = []
  hash_point.each do |country|
    if country[1][0].class == Array
      country[1][0].map {|item|  result << country if (lon_lowlmt..lon_uplmt).member?(item[1][0])  and (lat_lowlmt..lat_uplmt).member?(item[1][1])}
      
    else
      if (lon_lowlmt..lon_uplmt).member?(country[1][0])  and (lat_lowlmt..lat_uplmt).member?(country[1][1])
        result << country
      end
    end
  end
  puts "Max number of countries: #{result.length}."
  result.map{|country| puts "#{country[0]} at #{country[1]}"}
end
find_optimum(hash_point)