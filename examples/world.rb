# encoding: utf-8


get '/countries' do
  ## todo: add tags too??

  data = []
  Country.by_key.each do |country|
    data << { key:      country.key,
              title:    country.title,
              code:     country.code,
              pop:      country.pop,
              area:     country.area,
              synonyms: country.synonyms }
  end # each country
  data
end


get '/cities' do
  ## add virtual column like kind for metro, metro|city, city, district
  ## todo add region.title if present  

  data = []
  City.by_key.each do |city|
    data << { key:      city.key,
              title:    city.title,
              code:     city.code,
              pop:      city.pop,
              popm:     city.popm,
              area:     city.area,
              synonyms: city.synonyms,
              country:  city.country.title }
  end # each city
  data
end


get '/tag/:slug' do |slug|   # e.g. /tag/north_america
  data = []
  tag = Tag.find_by_slug!( slug )
  tag.countries.each do |country|
    data << { key:      country.key,
              title:    country.title,
              code:     country.code,
              pop:      country.pop,
              area:     country.area,
              synonyms: country.synonyms }
  end # each country
  data
end

