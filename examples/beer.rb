# encoding: utf-8


get '/beer/:key' do |key| 

  if ['r', 'rnd', 'rand', 'random'].include?( key )
    # special key for random beer
    # NB: use .first (otherwise will get ActiveRelation not Model)
    ## todo/check - already "fixed" in activerecord-utils ??
    beer = Beer.rnd.first
  else
    beer = Beer.find_by_key!( key )
  end

  ## beer.as_json_v2
end


get '/brewery/:key' do |key|

  if ['r', 'rnd', 'rand', 'random'].include?( key )
    # special key for random brewery
    # NB: use .first (otherwise will get ActiveRelation not Model)
    ## todo/check - already "fixed" in activerecord-utils ??
    brewery = Brewery.rnd.first
  else
    brewery = Brewery.find_by_key!( key )
  end

  ## brewery.as_json_v2
end

