class Api::V1::SearchController < Api::V1::ApplicationController
	skip_before_filter :authenticate_user!, only: [:show]
	skip_authorization_check only: [:show]

	def show
		q = params[:q]
		render json: { data: [] } and return if q.blank?

		raise InvalidParameter.new("unprocessable type parameter") if params[:type] != "team"

		# TODO: This should obvs be moved outside of this controller...
		# The tire DSL wasn't complete enough for what we needed, so using ES DSL
		# 	 directly. Query does a bit of ngram magic, and a bit of fuzzy magic.
		#    A match on the team name is required, matches on league/div names
		#    just give more points.
		query = {
		  "bool"=> {
		     "must"=> [
		        {
		           "bool"=> {
		              "should"=> [
		                 {
		                    "match"=> {
		                       "name.full"=> {
		                          "boost"=> 10,
		                          "query"=> "#{q}"
		                       }
		                    }
		                 },
		                 {
		                    "match"=> {
		                       "name.full"=> {
		                          "boost"=> 2,
		                          "query"=> "#{q}",
		                          "fuzziness"=> 0.65,
		                          "prefix_length"=> 2
		                       }
		                    }
		                 },
		                 {
		                    "match"=> {
		                       "name.partial_front"=> {
		                          "boost"=> 2,
		                          "query"=> "#{q}",
		                          "fuzziness"=> 0.65,
		                          "prefix_length"=> 2
		                       }
		                    }
		                 }
		              ]
		           }
		        }
		     ],
		     "should"=> [
		        {
		           "match"=> {
		              "division_name.full"=> {
		                 "boost"=> 2,
		                 "query"=> "#{q}",
		                 "fuzziness"=> 0.75,
		                 "prefix_length"=> 2
		              }
		           }
		        },
		        {
		           "match"=> {
		              "division_name.partial_front"=> {
		                 "boost"=> 1,
		                 "query"=> "#{q}",
		                 "fuzziness"=> 0.75,
		                 "prefix_length"=> 2
		              }
		           }
		        },
		        {
		           "match"=> {
		              "league_name.full"=> {
		                 "boost"=> 2,
		                 "query"=> "#{q}",
		                 "fuzziness"=> 0.75,
		                 "prefix_length"=> 2
		              }
		           }
		        },
		        {
		           "match"=> {
		              "league_name.partial_front"=> {
		                 "boost"=> 1,
		                 "query"=> "#{q}",
		                 "fuzziness"=> 0.75,
		                 "prefix_length"=> 2
		              }
		           }
		        }
		     ]
		  }
		}

		page_size = 10
		page = params[:page].to_i || 1
		page = 1 if page < 1
		search = Tire.search('faft-teams', from: page_size * (page-1), size: page_size, query: query)
		#Rails.logger.debug(search.to_json)

		data = []
		search.results.each do |r|
			data << { 
			 	id: r['id'],
			 	type: r['type'],
			 	name: r['name'],
			 	division_name: r['division_name'],
			 	division_season_id: r['division_id'], # ds faft_id
			 	league_name: r['league_name'],
				profile_picture_thumb_url: '/assets/profile_pic/team/generic_team_thumb.png'
			 	#_score: r['_score']
			 }
		end
		response = { data: data }

		urls = page_urls(search.results, q)
		response[:prev] = urls[:prev] if urls.has_key? :prev
		response[:next] = urls[:next] if urls.has_key? :next

		render json: response
	end

	private
	def page_urls(results, q)
		url = request.original_url.split('?')
		base_url = "#{url[0]}?type=team&q=#{q}&page="

		urls = {}
		urls[:prev] = "#{base_url}#{results.previous_page}" unless results.previous_page.nil?
		urls[:next] = "#{base_url}#{results.next_page}" unless results.next_page.nil?

		urls
	end
end