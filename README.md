##CIT 597 WebParser
	Zhi Li 
	Gem used: Nokogiri, nyaplot(for drawing scatter plot)
	Program file: factbook.rb hw2_EC.rb
	Test with RSpec: factbook_spec.rb

### Algorithm Used
> Algorithm used and answers to each task(followed in each section)

> Generally, in order not to rapidly access CIA website, I try to manage some of the calculation offline by first getting essential information all at a time page by page. From /print/textversion.html, I manage to create a mapping between country name and corresponding urls in hash_country. Then everytime I look for information regarding specific countries, I could always go through this hash to find out the exact urls. Using the url mapping, I manage to go through every country's page and locate the region/population/coordinates information, then store the mapping information in hashes for further use. Take region as an example, the algorithm used is quite direct, when I go through every page, first locate label "Map references", then go to the next element(upper parent's) to get the region information. More general information could also be fetch in this process, just few lines of code will suffice. 
	
1. List countries in South America that are prone to earthquakes.
	I try to first get the list of countries within south america by region, then get the reflinks of each country. However, it seems that CIA is using flash and I could not simply get each country's url. However, using the two hashes created, I could cross reference region, hash_country to look for corresponding url and parse information related to earthquake. The program could detect "earthquake" keyword, print out the related paragraph, and give related country a T/F label.
	Results are given as follows(countries prone to earthquakes): Argentina, Chile, Colombia, Ecuador, Peru.
	
2. List the country in Europe with the lowest elevation
	First, get country list in Europe with url. Then, there are two ways to do this. One is use https://www.cia.gov/library/publications/the-world-factbook/fields/2020.html, which contains all the elevation information within. Another is find elevation information within each country's page. I choose the latter one, and use similar locating method as hash_region is established.(First find elevation label, then find the next element) .match() method in regex is used to strim the number value out, which is stored in hash_elevation with country name and related lowest elevation.
	Results: European Union, Netherlands, Denmark have the lowest elevation of -7 m.
	
3. List countries in the southeastern hemisphere
	It's quite a tricky question, the answer can be really different depending on how one defines "southeastern hemisphere". In my opinion, I use the equator to separate south/north hemisphere, and eastern hemisphere is east of the Prime Meridian and west of 180 degrees in longitude. Thus, I use the coordinates information of each country to decide whether they are in southeastern hemisphere or not. This piece of information will be parsed during the second loop of getting each country's region. For countries such as France that has more than more coordinates, I simply pick the first one and load into local database. Function parse_hemisphere will print out southeastern countries with coordinates, also the total number of qualified countries.
	Results: 
```	Angola: 12 30 S, 18 30 E
```
	Antarctica: 90 00 S, 0 00 E
	Ashmore and Cartier Islands: 12 14 S, 123 05 E
	Australia: 27 00 S, 133 00 E
	Botswana: 22 00 S, 24 00 E
	Bouvet Island: 54 26 S, 3 24 E
	Burundi: 3 30 S, 30 00 E
	Christmas Island: 10 30 S, 105 40 E
	Cocos (Keeling) Islands: 12 30 S, 96 50 E
	Comoros: 12 10 S, 44 15 E
	Congo, Republic of the: 1 00 S, 15 00 E
	Coral Sea Islands: 18 00 S, 152 00 E
	Fiji: 18 00 S, 175 00 E
	Gabon: 1 00 S, 11 45 E
	Heard Island and McDonald Islands: 53 06 S, 72 31 E
	Indian Ocean: 20 00 S, 80 00 E
	Indonesia: 5 00 S, 120 00 E
	Lesotho: 29 30 S, 28 30 E
	Madagascar: 20 00 S, 47 00 E
	Malawi: 13 30 S, 34 00 E
	Mauritius: 20 17 S, 57 33 E
	Mozambique: 18 15 S, 35 00 E
	Namibia: 22 00 S, 17 00 E
	Nauru: 0 32 S, 166 55 E
	New Caledonia: 21 30 S, 165 30 E
	New Zealand: 41 00 S, 174 00 E
	Norfolk Island: 29 02 S, 167 57 E
	Papua New Guinea: 6 00 S, 147 00 E
	Rwanda: 2 00 S, 30 00 E
	Seychelles: 4 35 S, 55 40 E
	Solomon Islands: 8 00 S, 159 00 E
	South Africa: 29 00 S, 24 00 E
	Swaziland: 26 30 S, 31 30 E
	Tanzania: 6 00 S, 35 00 E
	Timor-Leste: 8 50 S, 125 55 E
	Tuvalu: 8 00 S, 178 00 E
	Vanuatu: 16 00 S, 167 00 E
	Zambia: 15 00 S, 30 00 E
	Zimbabwe: 20 00 S, 30 00 E
	
	in Total: 39 countries
	
4. List countries in asia with more than 10 political parties
	Similar algorithm in elevation part is implemented here. At first, in order to count number of parties under "Political parties" label, I store every table data with "div.category_data" label in an array, then use array.length to get the number of parties. However, this seems not good enough for places such as Hong Kong, where error counts happen. Thus, I introduce in a length parameter to distinguish words such as "note"/whitespace with party information. Also, for countries like Albania, I think alliance of party also plays an important part in the political world, and it additionally counts as one party. Nevertheless, this program is not intelligent enough to identify number within each line, for example "eight other parties" under current algorithm yield only one count.
	Comment: special case for India, on text format page, india has 18 political parties, but on https://www.cia.gov/library/publications/the-world-factbook/fields/2118.html, it shows 21. I use the text version as standard input. Similar cases happen in Macau, Kazakhstan etc.
	Result:
	Hong Kong has 16 political parties.
	India has 18 political parties.
	Kazakhstan has 12 political parties.
	Macau has 10 political parties.
	Malaysia has 18 political parties.
	Maldives has 18 political parties.
	Nepal has 36 political parties.
	Pakistan has 22 political parties.
	Thailand has 11 political parties.
	
5. List the top 5 countries that have the largest electricity consumption per capital
	Population information is parsed during region specification, but for electricity consumption, this webpage https://www.cia.gov/library/publications/the-world-factbook/rankorder/2233rank.html gives a figure in full amount, without "billion"/"million", which is much easier to use. In parse_elec funtion, I use hash_elec and hash_popu to calculate electricity consumption per capita, the top five countries are listed as follows. 
	Result:
	Iceland 			51477.88797929466
	Liechtenstein		36747.81809830041
	Norway				25599.757426946995
	Kuwait				17330.064452553986
	Finland				16108.652414284992
	
6. List countries along with their dominant religion(if above 80%) or all religion(if max below 50%)
	This webpage is really helpful when conducting the task: https://www.cia.gov/library/publications/the-world-factbook/fields/2122.html.
	Algorithm is similar to that of the 5th task, difference is that this task requires a bunch of condition checks, such as whether contents contain percentiles, or just simply description like "predominant". Also, to make the output clear, condition check such as whether contents has a comma as slice tail indicator needs to be confirmed. Details are more of concern, since the percentile could be either "80.1%" or "80%" in format, thus when I try to match the digit, a precise and reasonable regex is confirmed couple of times to make sure it works. Last, the year information is remained because sometimes time indeed makes difference.
	
	Result(in alphabetical order):
	    Afghanistan  Sunni Muslim 80%
	    Algeria  Muslim (official; predominantly Sunni) 99%, other (includes Christian and Jewish)
	    American Samoa  Christian Congregationalist 50%, Roman Catholic 20%, Protestant and other 30%
	    Andorra  Roman Catholic (predominant)
	    Angola  indigenous beliefs 47%, Roman Catholic 38%, Protestant 15% (1998 est.)
	    Anguilla  Protestant 83.1% (Anglican 29%
	    Argentina  nominally Roman Catholic 92% (less than 20% practicing)
	    Armenia  Armenian Apostolic 92.6%
	    Australia  Protestant 28.8% (Anglican 17.1%, Uniting Church 5.0%, Presbyterian and Reformed 2.8%, Baptist, 1.6%, Lutheran 1.2%, Pentecostal 1.1%), Catholic 25.3%, Eastern Orthodox 2.6%, other Christian 4.5%, Buddhist 2.5%, Muslim 2.2%, Hindu 1.3%, other 8.4%, unspecified 2.2%, none 22.3%
	    Azerbaijan  Muslim 93.4%
	    Bangladesh  Muslim 89.5%
	    Belarus  Eastern Orthodox 80%
	    Belize  Roman Catholic 39.3%, Pentacostal 8.3%, Seventh Day Adventist 5.3%, Anglican 4.5%, Mennonite 3.7%, Baptist 3.5%, Methodist 2.8%, Nazarene 2.8%, Jehovah's Witnesses 1.6%, other 9.9% (includes Baha'i Faith, Buddhism, Hinduism, Islam, and Mormon), other (unknown) 3.1%, none 15.2% (2010 census)
	    Benin  Catholic 27.1%, Muslim 24.4%, Vodoun 17.3%, Protestant 10.4% (Celestial 5%, Methodist 3.2%, other Protestant 2.2%), other Christian 5.3%, other 15.5% (2002 census)
	    Bermuda  Protestant 46.1% (Anglican 15.8%, African Methodist Episcopal 8.6%, Seventh Day Adventist 6.7, Pentecostal 3.5%, Methodist 2.7%, Presbyterian 2.0 %, Church of God 1.6%, Baptist 1.2%, Salvation Army 1.1%, Bretheren 1.0%, other Protestant 2.0%), Roman Catholic 14.5%, Jehovah's Witness 1.3%, other Christian 9.1%, Muslim 1%, other 3.9%, none 17.8%, unspecified 6.2% (2010 est.)
	    Bolivia  Roman Catholic 95%
	    Bosnia and Herzegovina  Muslim 40%, Orthodox 31%, Roman Catholic 15%, other 14%
	    British Virgin Islands  Protestant 84% (Methodist 33%
	    Burma  Buddhist 89%
	    Cambodia  Buddhist (official) 96.9%
	    Cameroon  indigenous beliefs 40%, Christian 40%, Muslim 20%
	    Canada  Catholic 40.6% (includes Roman Catholic 38.8%, Orthodox 1.6%, other Catholic .2%), Protestant 20.3% (includes United Church 6.1%, Anglican 5%, Baptist 1.9%, Lutheran 1.5%, Pentecostal 1.5%, Presbyterian 1.4%, other Protestant 2.9%), other Christian 6.3%, Muslim 3.2%, Hindu 1.5%, Sikh 1.4%, Buddhist 1.1%, Jewish 1%, other 0.6%, none 23.9% (2011 est.)
	    Central African Republic  indigenous beliefs 35%, Protestant 25%, Roman Catholic 25%, Muslim 15%
	    China  Buddhist 18.2%, Christian 5.1%, Muslim 1.8%, folk religion 21.9%, Hindu
	    Christmas Island  Buddhist 36%, Muslim 25%, Christian 18%, other 21% (1997)
	    Cocos (Keeling) Islands  Sunni Muslim 80%
	    Colombia  Roman Catholic 90%
	    Comoros  Sunni Muslim 98%
	    Congo, Democratic Republic of the  Roman Catholic 50%, Protestant 20%, Kimbanguist 10%, Muslim 10%, other (includes syncretic sects and indigenous beliefs) 10%
	    Congo, Republic of the  Roman Catholic 33.1%, Awakening Churches/Christian Revival 22.3%, Protestant 19.9%, Salutiste 2.2%, Muslim 1.6%, Kimbanguiste 1.5%, other 8.1%, none 11.3% (2010 est.)
	    Cote d'Ivoire  Muslim 38.6%, Christian 32.8%, indigenous 11.9%, none 16.7% (2008 est.)
	    Croatia  Roman Catholic 86.3%
	    Cuba  nominally Roman Catholic 85%
	    Czech Republic  Roman Catholic 10.4%, Protestant (includes Czech Brethren and Hussite) 1.1%, other and unspecified 54%, none 34.5% (2011 est.)
	    Denmark  Evangelical Lutheran (official) 80%
	    Djibouti  Muslim 94%
	    Dominican Republic  Roman Catholic 95%
	    Ecuador  Roman Catholic 95%
	    Egypt  Muslim (predominantly Sunni) 90%, Christian (majority Coptic Orthodox, other Christians include Armenian Apostolic, Catholic, Maronite, Orthodox, and Anglican) 10% (2012 est.)
	    Equatorial Guinea  nominally Christian and predominantly Roman Catholic, pagan practices
	    Eritrea;  Unclear
	    Estonia  Lutheran 9.9%, Orthodox 16.2%, other Christian (including Methodist, Seventh-Day Adventist, Roman Catholic, Pentecostal) 2.2%, other 0.9%, none 54.1%, unspecified 16.7% (2011 est.)
	    Ethiopia  Ethiopian Orthodox 43.5%, Muslim 33.9%, Protestant 18.5%, traditional 2.7%, Catholic 0.7%, other 0.6% (2007 est.)
	    European Union;  Unclear
	    Faroe Islands  Evangelical Lutheran 83.8%
	    Fiji  Protestant 45% (Methodist 34.6%, Assembly of God 5.7%, Seventh Day Adventist 3.9%, and Anglican 0.8%), Hindu 27.9%, other Christian 10.4%, Roman Catholic 9.1%, Muslim 6.3%, Sikh 0.3%, other 0.3%, none 0.8% (2007 est.)
	    France  Roman Catholic 83%-88%
	    Gambia, The  Muslim 90%
	    Gaza Strip  Muslim 98.0 - 99.0% (predominantly Sunni), Christian               note: dismantlement of Israeli settlements was completed in September 2005; Gaza has had no Jewish population since then (2012 est.)
	    Georgia  Orthodox Christian (official) 83.9%
	    Germany  Protestant 34%, Roman Catholic 34%, Muslim 3.7%, unaffiliated or other 28.3%
	    Greece  Greek Orthodox (official) 98%
	    Greenland;  Unclear
	    Guam  Roman Catholic 85%
	    Guatemala;  Unclear
	    Guernsey;  Unclear
	    Guinea  Muslim 85%
	    Guinea-Bissau  Muslim 50%, indigenous beliefs 40%, Christian 10%
	    Guyana  Protestant 30.5% (Pentecostal 16.9%, Anglican 6.9%, Seventh Day Adventist 5%, Methodist 1.7%), Hindu 28.4%, Roman Catholic 8.1%, Muslim 7.2%, Jehovah's Witnesses 1.1%, other Christian 17.7%, other 1.9%, none 4.3%, unspecified 0.9% (2002 est.)
	    Haiti  Roman Catholic 80%
	    Holy See (Vatican City);  Unclear
	    Honduras  Roman Catholic 97%
	    Hong Kong  eclectic mixture of local religions 90%
	    Hungary  Roman Catholic 37.2%, Calvinist 11.6%, Lutheran 2.2%, Greek Catholic 1.8%, other 1.9%, none 18.2%, unspecified 27.2% (2011 est.)
	    India  Hindu 80.5%
	    Indonesia  Muslim 87.2%
	    Iran  Muslim (official) 99.4% (Shia 90-95%
	    Iraq  Muslim (official) 99% (Shia 60%-65%
	    Ireland  Roman Catholic 84.7%
	    Isle of Man;  Unclear
	    Italy  Christian 80% (overwhelmingly Roman Catholic with very small groups of Jehovah's Witnesses and Protestants)
	    Japan  Shintoism 83.9%
	    Jersey;  Unclear
	    Jordan  Muslim 97.2% (official; predominantly Sunni), Christian 2.2% (majority Greek Orthodox, but some Greek and Roman Catholics, Syrian Orthodox, Coptic Orthodox, Armenian Orthodox, and Protestant denominations), Buddhist 0.4%, Hindu 0.1%, Jewish
	    Kenya  Christian 82.5% (Protestant 47.4%
	    Korea, North;  Unclear
	    Korea, South  Christian 31.6% (Protestant 24%, Roman Catholic 7.6%), Buddhist 24.2%, other or unknown 0.9%, none 43.3% (2010 survey)
	    Kosovo;  Unclear
	    Latvia  Lutheran 19.6%, Orthodox 15.3%, other Christian 1%, other 0.4%, unspecified 63.7% (2006)
	    Lesotho  Christian 80%
	    Liberia  Christian 85.6%
	    Libya  Muslim (official; virtually all Sunni) 96.6%
	    Luxembourg  Roman Catholic 87%
	    Macau  Buddhist 50%, Roman Catholic 15%, none or other 35% (1997 est.)
	    Malawi  Christian 82.6%
	    Maldives;  Unclear
	    Mali  Muslim 94.8%
	    Malta  Roman Catholic (official) more than 90% (2011 est.)
	    Mauritania  Muslim (official) 100%
	    Mauritius  Hindu 48.5%, Roman Catholic 26.3%, Muslim 17.3%, other Christian 6.4%, other 0.6%, none 0.7%, unspecified 0.1% (2011 est.)
	    Mexico  Roman Catholic 82.7%
	    Moldova  Orthodox 93.3%
	    Monaco  Roman Catholic 90% (official)
	    Morocco  Muslim 99% (official; virtually all Sunni
	    Mozambique  Roman Catholic 28.4%, Muslim 17.9%, Zionist Christian 15.5%, Protestant 12.2% (includes Pentecostal 10.9% and Anglican 1.3%), other 6.7%, none 18.7%, unspecified 0.7% (2007 est.)
	    Namibia  Christian 80% to 90% (at least 50% Lutheran)
	    Nepal  Hindu 81.3%
	    Netherlands  Roman Catholic 28%, Protestant 19% (includes Dutch Reformed 9%, Protestant Church of The Netherlands, 7%, Calvinist 3%), other 11% (includes about 5% Muslim and lesser numbers of Hindu, Buddhist, Jehovah's Witness, and Orthodox), none 42% (2009 est.)
	    New Zealand  Christian 44.3% (Catholic 11.6%, Anglican 10.8%, Presbyterian and Congregational 7.8%, Methodist, 2.4%, Pentecostal 1.8%, other 9.9%), Hindu 2.1%, Buddhist 1.4%, Maori Christian 1.3%, Islam 1.1%, other religion 1.4% (includes Judaism, Spiritualism and New Age religions, Baha'i, Asian religions other than Buddhism), no religion 38.5%, not stated or unidentified 8.2%, objected to answering 4.1%
	    Niger  Muslim 80%
	    Nigeria  Muslim 50%, Christian 40%, indigenous beliefs 10%
	    Norfolk Island  Protestant 49.6% (Anglican 31.8%, Uniting Church in Australia 10.6%, Seventh-Day Adventist 3.2%), Roman Catholic 11.7%, other 8.6%, none 23.5%, unspecified 6.6% (2011 est.)
	    Northern Mariana Islands;  Unclear
	    Norway  Church of Norway (Evangelical Lutheran - official) 82.1%
	    Oman  Muslim (official; majority are Ibadhi
	    Pakistan  Muslim (official) 96.4% (Sunni 85-90%
	    Palau  Roman Catholic 49.4%, Protestant 30.9% (includes Protestant (general) 23.1%, Seventh Day Adventist 5.3%, and other Protestant 2.5%), Modekngei 8.7% (indigenous to Palau), Jehovah's Witnesses 1.1%, other 8.8%, none or unspecified 1.1% (2005 est.)
	    Panama  Roman Catholic 85%
	    Papua New Guinea  Roman Catholic 27%, Protestant 69.4% (Evangelical Lutheran 19.5%, United Church 11.5%, Seventh-Day Adventist 10%, Pentecostal 8.6%, Evangelical Alliance 5.2%, Anglican 3.2%, Baptist 2.5%, other Protestant 8.9%), Baha'i 0.3%, indigenous beliefs and other 3.3% (2000 census)
	    Paraguay  Roman Catholic 89.6%
	    Peru  Roman Catholic 81.3%
	    Philippines  Catholic 82.9% (Roman Catholic 80.9%
	    Pitcairn Islands  Seventh-Day Adventist 100%
	    Poland  Catholic 87.2% (includes Roman Catholic 86.9% and Greek Catholic
	    Portugal  Roman Catholic 81%
	    Puerto Rico  Roman Catholic 85%
	    Romania  Eastern Orthodox (including all sub-denominations) 81.9%
	    Russia  Russian Orthodox 15-20%, Muslim 10-15%, other Christian 2% (2006 est.)
	    Rwanda  Roman Catholic 49.5%, Protestant 39.4% (includes Adventist 12.2% and other Protestant 27.2%), other Christian 4.5%, Muslim 1.8%, animist 0.1%, other 0.6%, none 3.6% (2001), unspecified 0.5% (2002 est.)
	    Saint Barthelemy;  Unclear
	    Saint Helena, Ascension, and Tristan da Cunha;  Unclear
	    Saint Kitts and Nevis;  Unclear
	    Saint Martin;  Unclear
	    Saint Pierre and Miquelon  Roman Catholic 99%
	    San Marino;  Unclear
	    Saudi Arabia  Muslim (official; citizens are 85-90% Sunni and 10-15% Shia)
	    Senegal  Muslim 94% (most adhere to one of the four main Sufi brotherhoods)
	    Serbia  Serbian Orthodox 84.6%
	    Singapore  Buddhist 33.9%, Muslim 14.3%, Taoist 11.3%, Catholic 7.1%, Hindu 5.2%, other Christian 11%, other 0.7%, none 16.4% (2010 est.)
	    Sint Maarten  Roman Catholic 39%, Protestant 44.8% (Pentecostal 11.6%, Seventh-Day Adventist 6.2%, other Protestant 27%), none 6.7%, other 5.4%, Jewish 3.4%, not reported 0.7% (2001 census)
	    Somalia;  Unclear
	    South Africa  Protestant 36.6% (Zionist Christian 11.1%, Pentecostal/Charismatic 8.2%, Methodist 6.8%, Dutch Reformed 6.7%, Anglican 3.8%), Catholic 7.1%, Muslim 1.5%, other Christian 36%, other 2.3%, unspecified 1.4%, none 15.1% (2001 census)
	    South Sudan;  Unclear
	    Spain  Roman Catholic 94%
	    Sudan;  Unclear
	    Suriname  Hindu 27.4%, Protestant 25.2% (predominantly Moravian), Roman Catholic 22.8%, Muslim 19.6%, indigenous beliefs 5%
	    Swaziland  Zionist 40% (a blend of Christianity and indigenous ancestral worship), Roman Catholic 20%, Muslim 10%, other (includes Anglican, Baha'i, Methodist, Mormon, Jewish) 30%
	    Sweden  Lutheran 87%
	    Switzerland  Roman Catholic 38.2%, Protestant 26.9%, Muslim 4.9%, other Christian 5.7%, other 1.6%, none 21.4%, unspecified 1.3% (2012 est.)
	    Syria  Muslim 87% (official; includes Sunni 74% and Alawi
	    Taiwan  mixture of Buddhist and Taoist 93%
	    Tajikistan  Sunni Muslim 85%
	    Tanzania  mainland - Christian 30%, Muslim 35%, indigenous beliefs 35%; Zanzibar - more than 99% Muslim
	    Thailand  Buddhist (official) 93.6%
	    Timor-Leste  Roman Catholic 96.9%
	    Togo  Christian 29%, Muslim 20%, indigenous beliefs 51%
	    Trinidad and Tobago  Protestant 32.1% (Pentecostal/Evangelical/Full Gospel 12%, Baptist 6.9%, Anglican 5.7%, Seventh-Day Adventist 4.1%, Presbyterian/Congretational 2.5, other Protestant .9), Roman Catholic 21.6%, Hindu 18.2%, Muslim 5%, Jehovah's Witness 1.5%, other 8.4%, none 2.2%, unspecified 11.1% (2011 est.)
	    Tunisia  Muslim (official; Sunni) 99.1%
	    Turkey  Muslim 99.8% (mostly Sunni)
	    Turkmenistan  Muslim 89%
	    Tuvalu  Protestant 98.4% (Church of Tuvalu (Congregationalist) 97%
	    Uganda  Roman Catholic 41.9%, Protestant 42% (Anglican 35.9%, Pentecostal 4.6%, Seventh-Day Adventist 1.5%), Muslim 12.1%, other 3.1%, none 0.9% (2002 census)
	    Ukraine  Orthodox (includes Ukrainian Autocephalous Orthodox (UAOC), Ukrainian Orthodox - Kyiv Patriarchate (UOC-KP), Ukrainian Orthodox - Moscow Patriarchate (UOC-MP), Ukrainian Greek Catholic, Roman Catholic, Protestant, Muslim, Jewish
	    Uruguay  Roman Catholic 47.1%, non-Catholic Christians 11.1%, nondenominational 23.2%, Jewish 0.3%, atheist or agnostic 17.2%, other 1.1% (2006)
	    Uzbekistan  Muslim 88% (mostly Sunni)
	    Venezuela  nominally Roman Catholic 96%
	    Vietnam  Buddhist 9.3%, Catholic 6.7%, Hoa Hao 1.5%, Cao Dai 1.1%, Protestant 0.5%, Muslim 0.1%, none 80.8% (1999 census)
	    Wallis and Futuna  Roman Catholic 99%
	    West Bank  Muslim 80.0 - 85.0% (predominantly Sunni), Jewish 12.0 - 14.0%, Christian 1.0 - 2.5% (mainly Greek Orthodox), other, unaffiliated, unspecified               note: the proportion of Christians continues to fall mainly as a result of the growth of the Muslim population but also because of the migration and the declining birth rate of the Christian population (2012 est.)
	    Western Sahara;  Unclear
	    World  Christian 33.39% (of which Roman Catholic 16.85%, Protestant 6.15%, Orthodox 3.96%, Anglican 1.26%), Muslim 22.74%, Hindu 13.8%, Buddhist 6.77%, Sikh 0.35%, Jewish 0.22%, Baha'i 0.11%, other religions 10.95%, non-religious 9.66%, atheists 2.01% (2010 est.)
	    Yemen  Muslim 99.1% (official; virtually all are citizens
	    Zimbabwe  syncretic (part Christian, part indigenous beliefs) 50%, Christian 25%, indigenous beliefs 24%, Muslim and other 1%
	
7. List any country that is entirely landlocked by another country
	Based on the definition of landlocked country, I first check coastline information listed on page https://www.cia.gov/library/publications/the-world-factbook/fields/2060.html. It will show whether a country has coastline. If not, landlock will appear, if so, distance will appear. After picking countries with "landlock" label, I make a second search on page https://www.cia.gov/library/publications/the-world-factbook/fields/2096.html, which provides detail information about land boundaries, thus adjacent countries could be found. My strategy is try to get the essential information at one time, then process most of data offline. To check accuracy, I first output landlocked country with number of adjacent countries, and it turns out pretty good. Some of results are here:
	Afghanistan, number of adjacent:6
	Andorra, number of adjacent:2
	Armenia, number of adjacent:4
	Austria, number of adjacent:8
	Azerbaijan, number of adjacent:5
	Belarus, number of adjacent:5
	Bhutan, number of adjacent:2
	Bolivia, number of adjacent:5
	Botswana, number of adjacent:4
	Burkina Faso, number of adjacent:6
	Burundi, number of adjacent:3
	Central African Republic, number of adjacent:6
	Chad, number of adjacent:6
	Czech Republic, number of adjacent:4
	Ethiopia, number of adjacent:6
	Holy See (Vatican City), number of adjacent:1
	Holy See (Vatican City) Entirely landlocked: Italy
	
	Then I'm certain this algorithm works, and carry on to find landlocked countries with only one adjacent country.
	Result:
	Holy See (Vatican City) Entirely landlocked by: Italy
	Lesotho Entirely landlocked by: South Africa
	San Marino Entirely landlocked by: Italy
	
	Three countries suffice this requirement.
	

	
8. (Wild Card) List the top 5 countries that have the largest percentage of internet users. 
	I try to come up with a question that is at a similar level of Q5, using the figure of population and internet users in each country. Both information are parsed during the first round of parsing through each page. Calculation and sorting is done in function parse_internet. It's interesting to find out that there are actually countires/regions don't have internet users, and that Iceland and Norway(in Northern Europe) have the largest percentage in internet users.
	
	Results:
	American Samoa has no internet users.
	Curacao has no internet users.
	Sint Maarten has no internet users.
	Iceland: 95.66%
	Norway: 93.82%
	Falkland Islands (Islas Malvinas): 92.36%
	Sweden: 92.09%
	Niue: 89.5%
	
	After doing all these, a weird idea just come up to me that, what's the possible relationship between electricity consumption per capital and internet user percentage? Since the two sections of data are somehow "normalized" by dividing population, I really want to see if there's any relationship between. Also, I would like to try drawing a cross section 2D scatter plot in ruby. I found a gem called nyaplot, and try to use it to draw a scatter plot and visualize data. Simply type gem install nyaplot will install this gem to pc. 
	To use nyaplot to draw scatter plot, first define two array plot_x, plot_y, then type the following scripts.
    
	plot = Nyaplot::Plot.new
    sc = plot.add(:scatter, plot_x, plot_y)
    plot.export_html
	
	It'll generate an html page containing the plot within the same directory as ruby file. The result does not show significant relevance, but as internet population percentage goes up, electricity per capital indeed slightly raises. (I turn the y-axis to log mode) It's fun trying to visualize figures and find relevance in between. Although scatter plot is the very basic in plotting analysis, it's always interesting to test in a new language.
		

### Extra Credit
1. The ruby program is stored as hw2_EC.rb

> Algorithm: 
> In order to find as many countries as possible within a 10*10 degrees square, my brief mechanism is to first form a hash containing the mapping information of countries to their coordinates(including those with multiple territories, which bring in more difficulties).	Several steps: locate country name, decide whether the text contain multiple coordinates, use regex to match the information, parse down and store in hash_point. Here for coordinates, the precision is 1. X-Y axis is built up by defining equator as x-axis, 0 degree longitude as y-axis, N+ S- W- E+. 
> Then, I manage to map all the coordinates information into a 180*360 dimension matrix (in array form). Thus each node of the matrix will contain the counts of different coordinates(some node may contain more than 1 count). The next step is to sum up every 10 * 10 matrices within the matrix and store the sum value in the position of [0,0] in each 10*10 small matrix. 
> Simply using array.each_with_index.max, I could find the largest value/count, then trace back to its boundary coordinates in longitude and latitude. Finally, the program will output the maximum number of countries found, along with each country within the boundary and its coordinates.

	 Results:
	 Longitude: 70 W ~ 60 W;  Latitude: 8 N ~ 18 N
	 $$$$$$$$$$$$$$$$$$$$$$$$$$$$
	 $$$$ Results as follows $$$$
	 $$$$$$$$$$$$$$$$$$$$$$$$$$$$
	 Longitude: -70~-60  Latitude:8~18
	 Max number of countries: 18.
	 Anguilla at [-64, 18]
	 Antigua and Barbuda at [-62, 17]
	 Aruba at [-70, 12]
	 Barbados at [-60, 13]
	 British Virgin Islands at [-65, 18]
	 Curacao at [-69, 12]
	 Dominica at [-62, 15]
	 Grenada at [-62, 12]
	 Montserrat at [-63, 16]
	 Puerto Rico at [-67, 18]
	 Saint Barthelemy at [-63, 17]
	 Saint Kitts and Nevis at [-63, 17]
	 Saint Lucia at [-61, 13]
	 Saint Martin at [-64, 18]
	 Saint Vincent and the Grenadines at [-62, 13]
	 Trinidad and Tobago at [-61, 11]
	 Venezuela at [-66, 8]
	 Virgin Islands at [-65, 18]
	 
	 One thing to make certain is that for degree between 170 E and 170 W, there are scarecely any countries found, and that's somehow why the international date line is there. Using the program written, by modifying the value of lon_lowlmt, lon_uplmt, lat_lowlmt and lat_uplmt, you can list every country within the boundary you set.
	 Longitude: 170 E ~ 180 E;  Latitude: 90 S ~ 90 N
	 Max number of countries: 4.
	 Fiji at [175, -18]
	 Kiribati at [173, 1]
	 New Zealand at [174, -41]
	 Tuvalu at [178, -8]
	 
	 Longitude: 180 W ~ 170 W;  Latitude: 90 S ~ 90 N
	 Max number of countries: 9.
	 American Samoa at [-170, -15]
	 Howland Island at [-177, 0]
	 Johnston Atoll at [-170, 16]
	 Midway Islands at [-178, 28]
	 Niue at [-170, -20]
	 Samoa at [-173, -14]
	 Tokelau at [-172, -9]
	 Tonga at [-175, -20]
	 Wallis and Futuna at [-177, -14]
	 
	 Thus, the number of all countries within 170E ~ 170W (90S ~ 90N) is 13, far smaller than the maximum count we find above between Longitude: 70 W ~ 60 W;  Latitude: 8 N ~ 18 N. Therefore, the algorithm generates a thorough result.
	
	
2. I'd have come up with similar parsing and calculation tasks, but that'd be similar tasks like above. However, just as I mentioned in the beginning, CIA is using shockware flash in region pages such as https://www.cia.gov/library/publications/the-world-factbook/wfbExt/region_afr.html, which is totally not cool, making it complex to go over "Map Reference" label of each country. Thus, my question would be: 

Q: how to parse information from *.swf embedded in the html page?
	A: After some time googling this topic, I figure out a way to get contents of *.swf file embedded in html quickly. I use firebug in Firefox to view source info and monitor interaction between browser and website, nokogiri gem and Ruby language is used to parse information from XML file. The following steps might seem a little bit tricky, but it definitely works.
	First let's say open the webpage https://www.cia.gov/library/publications/the-world-factbook/wfbExt/region_afr.html, which lists every country in Africa within the "annoying" flash. Then, let's enable firebug, open Net monitor, and look through the list that contains every file you've cached to load the html page. Under "all" catelogue, you should see a bunch of jpg, js, xml etc., also you should see GET afr.swf. The flash file is 176.3 kb, it's mapping the region information and country name in visual form. Let's look further, right click the link and choose open in a new tab, a new webpage of https://www.cia.gov/library/publications/the-world-factbook/wfbExt/afr.swf will occur. Now we continue to use firebug to check what file the browser is currently using, and under HTML catalogue we could definitely find GET sourceXML.xml. That's the exact thing connected to afr.swf, and is also the central mapping bank for all region flash files. Right click on the link to open in a new tab, then we have a clear list of Country Name, mapping url(abbr.), and region specification as follows.
	
	<country>
		<country name="Afghanistan" fips="AF" Region="South Asia"/>
		<country name="Akrotiri" fips="AX" Region="Europe"/>
		<country name="Albania" fips="AL" Region="Europe"/>
		<country name="Algeria" fips="AG" Region="Africa"/>
		<country name="American Samoa" fips="AQ" Region="Oceania"/>
		<country name="Andorra" fips="AN" Region="Europe"/>
		<country name="Angola" fips="AO" Region="Africa"/>
		<country name="Anguilla" fips="AV" Region="Central America"/>
		<country name="Antarctica" fips="AY" Region="Antarctica"/>
		<country name="Antigua and Barbuda" fips="AC" Region="Central America"/>
		<country name="Argentina" fips="AR" Region="South America"/>
		<country name="Armenia" fips="AM" Region="Middle East"/>
		<country name="Aruba" fips="AA" Region="Central America"/>
		<country name="Ashmore and Cartier Islands" fips="AT" Region="Oceania"/>
		<country name="Australia" fips="AS" Region="Oceania"/>
		<country name="Austria" fips="AU" Region="Europe"/>
		<country name="Azerbaijan" fips="AJ" Region="Middle East"/>
		<country name="Bahamas, The" fips="BF" Region="Central America"/>
		<country name="Bahrain" fips="BA" Region="Middle East"/>
		<country name="Baker Island" fips="FQ" Region="Oceania"/>
		<country name="Bangladesh" fips="BG" Region="South Asia"/>
		...

	If you look through each country's webpage url, take Afghanistan as an example, you'll find that for normal version we have https://www.cia.gov/library/publications/the-world-factbook/geos/af.html, for text version we have https://www.cia.gov/library/publications/the-world-factbook/geos/countrytemplate_af.html. They are all formatted in a similar fashion, with prefix + abbreviation, and a command in ruby will do the rest. Therefore, this xml file will provide essential mapping of country/region/url. This is the xml file link: https://www.cia.gov/library/publications/the-world-factbook/wfbExt/sourceXML.xml
	My next move is to combine this into my program at the beginning, using ruby with nokogiri to parse the region information and compare it with the mapping I get from "Map reference label" page by page. I wrote two methods (parse_xml and compare_xml) to first get mapping information from XML file using nokogiri and ruby, then use xml file as a standard reference to check the accuracy of region info defined by map reference.
	The results are as follows.(Here only unmatched definition is listed)

	Afghanistan: Asia => South Asia
	Anguilla: Central America and the Caribbean => Central America
	Antarctica: Antarctic Region => Antarctica
	Antigua and Barbuda: Central America and the Caribbean => Central America
	Arctic Ocean:Arctic not show up in XML
	Aruba: Central America and the Caribbean => Central America
	Atlantic Ocean:Political Map of the World not show up in XML
	Bahamas, The: Central America and the Caribbean => Central America
	Bangladesh: Asia => South Asia
	Barbados: Central America and the Caribbean => Central America
	Belize: Central America and the Caribbean => Central America
	Bhutan: Asia => South Asia
	Bouvet Island: Antarctic Region => Antarctica
	British Indian Ocean Territory: Political Map of the World => South Asia
	British Virgin Islands: Central America and the Caribbean => Central America
	Brunei: Southeast Asia => East Asia
	Burma: Southeast Asia => East Asia
	Cambodia: Southeast Asia => East Asia
	Cayman Islands: Central America and the Caribbean => Central America
	China: Asia => East Asia
	Clipperton Island: Political Map of the World => North America
	Costa Rica: Central America and the Caribbean => Central America
	Cuba: Central America and the Caribbean => Central America
	Curacao: Central America and the Caribbean => Central America
	Dominica: Central America and the Caribbean => Central America
	Dominican Republic: Central America and the Caribbean => Central America
	El Salvador: Central America and the Caribbean => Central America
	France:  => Europe
	French Southern and Antarctic Lands: Antarctic Region => Antarctica
	Grenada: Central America and the Caribbean => Central America
	Guatemala: Central America and the Caribbean => Central America
	Haiti: Central America and the Caribbean => Central America
	Heard Island and McDonald Islands:Antarctic Region not show up in XML
	Honduras: Central America and the Caribbean => Central America
	Hong Kong: Southeast Asia => East Asia
	India: Asia => South Asia
	Indian Ocean:Political Map of the World not show up in XML
	Indonesia: Southeast Asia => East Asia
	Jamaica: Central America and the Caribbean => Central America
	Japan: Asia => East Asia
	Kazakhstan: Asia => Central Asia
	Korea, North: Asia => East Asia
	Korea, South: Asia => East Asia
	Kyrgyzstan: Asia => Central Asia
	Laos: Southeast Asia => East Asia
	Macau: Southeast Asia => East Asia
	Malaysia: Southeast Asia => East Asia
	Maldives: Asia => South Asia
	Mongolia: Asia => East Asia
	Montserrat: Central America and the Caribbean => Central America
	Navassa Island: Central America and the Caribbean => Central America
	Nepal: Asia => South Asia
	Nicaragua: Central America and the Caribbean => Central America
	Pacific Ocean:Political Map of the World not show up in XML
	Pakistan: Asia => South Asia
	Panama: Central America and the Caribbean => Central America
	Paracel Islands: Southeast Asia => East Asia
	Philippines: Southeast Asia => East Asia
	Puerto Rico: Central America and the Caribbean => Central America
	Russia: Asia => Central Asia
	Saint Barthelemy: Central America and the Caribbean => Central America
	Saint Helena, Ascension, and Tristan da Cunha:Africa not show up in XML
	Saint Kitts and Nevis: Central America and the Caribbean => Central America
	Saint Lucia: Central America and the Caribbean => Central America
	Saint Martin: Central America and the Caribbean => Central America
	Saint Vincent and the Grenadines: Central America and the Caribbean => Central America
	Singapore: Southeast Asia => East Asia
	Sint Maarten: Central America and the Caribbean => Central America
	Southern Ocean:Antarctic Region not show up in XML
	Spratly Islands: Southeast Asia => East Asia
	Sri Lanka: Asia => South Asia
	Taiwan: Southeast Asia => East Asia
	Tajikistan: Asia => Central Asia
	Thailand: Southeast Asia => East Asia
	Timor-Leste: Southeast Asia => East Asia
	Trinidad and Tobago: Central America and the Caribbean => Central America
	Turkmenistan: Asia => Central Asia
	Turks and Caicos Islands: Central America and the Caribbean => Central America
	Uzbekistan: Asia => Central Asia
	Vietnam: Southeast Asia => East Asia
	Virgin Islands: Central America and the Caribbean => Central America
	
	In total 82 mistaches are found, other 185 regions are correct
	It turns out that using the xml to parse region and url information use just 0.29s, however, going through every country's home page will take more than 50 seconds. Finding appropriate reference source is indeed helpful :) The XML contains more accurate region information.
