require_relative 'vcr_setup'
require 'simplecov'
SimpleCov.start
require_relative 'factbook'

RSpec.describe Factbook do
  factbook = Factbook.new
  
  describe '#parse_country' do
    it 'should return a hash_country with {country: url} parsed from list_url' do
      hash_country ={}
      VCR.use_cassette('parse_country_url') do
        expect(factbook.parse_country(hash_country).size).to be > 1
      end
    end
  end

  describe '#parse_xml' do
    it 'returns hashes with name of country => url' do
      hash = {}
      VCR.use_cassette('parse_xml_from_sourceXML') do
        expect(factbook.parse_xml(hash)).to include("Afghanistan"=> a_collection_containing_exactly(a_string_matching(/af.html/), a_string_matching(/Asia/)))
      end
    end
  end

  describe '#compare_xml' do
    it 'compares the difference between two hashes and printout mismatches' do
      hash_region = {China: "East Asia"}
      hash_xml = { China: ["cn.html", "Asia"] }
      expect(factbook.compare_xml(hash_xml, hash_region)).to match(/1 mismatches found/)
    end

    it 'compares the difference between two hashes and printout Correct if corresponding values equal' do
      hash_region = {China: "Asia"}
      hash_xml = { China: ["cn.html", "Asia"] }
      expect(factbook.compare_xml(hash_xml, hash_region)).to match(/other 1 regions are correct/)
    end

    it 'compares the difference between two hashes and printout not show up if value in hash_region not show up in hash_xml' do
      hash_region = {India: "Asia"}
      hash_xml = { China: ["cn.html", "Asia"] }
      expect(factbook.compare_xml(hash_xml, hash_region)).to match(/1 mismatches found/)
    end

  end

  describe '#parse_region' do
    hash_country = {}
    VCR.use_cassette('parse_country_url') do
      hash_country = factbook.parse_country(hash_country)
    end
    
    hash_region = {}
    hash_coor = {}
    hash_popu = {}
    hash_internet = {}
    
    VCR.use_cassette('parse_region_coor_popu_internet') do
      factbook.parse_region(hash_country, hash_region,hash_coor,hash_popu, hash_internet)
    end
    
    it 'uses partial url stored in hash_country to parse map reference and store in hash_region' do
      expect(hash_region).to include("Afghanistan"=>"Asia")
    end

    it 'uses partial url stored in hash_country to parse population' do
      expect(hash_popu).to include("Afghanistan" => "31108077")
    end

    it 'uses partial url stored in hash_country to parse geographic coordinates' do
      expect(hash_coor).to include( "Afghanistan"=> a_string_matching(/33 00/))
    end

    it 'uses partial url stored in hash_country to parse number of internet users' do
      expect(hash_internet).to include("Afghanistan"=> a_string_matching(/1 million/))
    end
  end

  describe '#parse_earthquake' do

    it 'will list countries in south america that are prone to earthquake' do
      hash_country = {}
      VCR.use_cassette('parse_country_url') do
        hash_country = factbook.parse_country(hash_country)
      end
    
      hash_region = {}
      hash_coor = {}
      hash_popu = {}
      hash_internet = {}
    
      VCR.use_cassette('parse_region_coor_popu_internet') do
        factbook.parse_region(hash_country, hash_region,hash_coor,hash_popu, hash_internet)
      end
      
      target_region = "South America"
      soa = hash_region.map{|key| key[0] if key[1] == target_region}.compact.uniq
      # soa = ["Argentina"]
      # hash_country = {"Argentina"=>"/geos/countrytemplate_ar.html"}
      VCR.use_cassette('parse_earthquake_soa') do
        expect(factbook.parse_earthquake(hash_country,soa)).to include("Argentina")
      end
    end

  end

  describe '#parse_elevation' do
    it 'will list countries in Europe with lowest elevation' do
      hash_elevation = {}
      eur = ["Germany"]
      hash_country={"Germany"=>"/geos/countrytemplate_gm.html"}
      VCR.use_cassette('parse_elevation_germany') do
        expect(factbook.parse_elevation(hash_country,eur,hash_elevation)).to include(a_string_matching(/Germany/))
      end
    end

  end

  describe '#parse_hemisphere' do
    it 'will List countries in southeastern hemisphere' do
      hash_country = {"Australia"=>"/geos/countrytemplate_as.html"}
      hash_region = {}
      hash_coor = {}
      hash_popu = {}
      hash_internet = {}
      VCR.use_cassette('parse_region_coor_popu_internet') do
        factbook.parse_region(hash_country, hash_region,hash_coor,hash_popu, hash_internet)
      end
      hemisphere = "southeastern"
      VCR.use_cassette('parse_hemisphere_aus') do
        expect(factbook.parse_hemisphere(hash_coor, hemisphere)).to match(/1 countries/)
      end
    end
  end

  describe '#parse_political' do
    it 'will list countries in asia with more than #{threshold} political parties.' do
      asia = ["India"]
      hash_political = {}
      hash_country = {"India"=>"/geos/countrytemplate_in.html"}
      threshold = 10
      VCR.use_cassette('parse_political_party_India') do
        expect(factbook.parse_political(hash_political,asia,hash_country, threshold)).to include("India")
      end
    end
  end

  describe '#parse_elec' do
    it 'will find top 5 countries with highest electricity consumption per capita' do
      hash_elec = {}
      hash_avrelec = {}
      hash_popu= {}
      top = 5
      VCR.use_cassette('parse_electricity_per_capita_without_population_info') do
        expect(factbook.parse_elec(hash_elec,hash_popu, hash_avrelec,top).length).to eq(5)
      end
    end
  end

  describe '#parse_religion' do
    it 'will list country with religion, which covers >80% population or <50% population' do
      above = 80
      below = 50
      hash_religion = {}
      VCR.use_cassette('parse_religion_majority_and_minority') do
        expect(factbook.parse_religion(hash_religion, above, below).reduce(true){|all,one| all= all and false if (one[1]>below and one[1]<above) }).to be nil
      end
    end
  end

  describe '#parse_lock' do
    it 'should find countries that are landlocked' do
      hash_lock ={}
      hash_bound = {}
      VCR.use_cassette('parse_countries_or_regions_get_landlocked') do
        expect(factbook.parse_lock(hash_lock, hash_bound).length).to be > 1
      end
    end
  end

  describe '#parse_internet' do
    it 'will list the top 5 countries with the most percentage of users connected to internet' do
      hash_internetpercent = {}
      hash_internet = {"China"=>"389 million", "Indo"=>"1 billion", "Happy"=>"null", "Joy"=>"1"}
      hash_popu = {"China"=>"1349585838","Indo"=>"2333233200", "Happy"=>"2000000","Joy"=>"241"}
      VCR.use_cassette('parse_internet_user_coverage') do
        expect(factbook.parse_internet(hash_internet,hash_popu, hash_internetpercent)).to include(a_string_matching("China"))
      end
    end
  end

  describe '#draw_scatterplot' do
    it 'will draw a scatterplot based on hash_internetpercent and hash_avrelec' do
      hash_internetpercent={"China"=>50, "Indo"=>20, "NULL"=>nil}
      hash_avrelec={"China"=>100, "India"=> 80}
      expect(factbook.draw_scatterplot(hash_internetpercent, hash_avrelec)).to match "plot stored"
    end
  end
end


