# TODO: split this up into separate controllers, and make it nicer. TS
class Api::V1::Reports::ReportsController < Api::V1::ApplicationController
	@@valid_units = [:alltime, :month, :week]

	def overview_summary
		# authorize
		# TODO: ******************************** not dummy ting
		authorize! :create, Team

		this_month_date = Date.today.at_end_of_month
		this_month = RfuMetrics::cache.overview_summary(this_month_date, false)

		last_month_date = (Date.today - 1.month).at_end_of_month
		last_month = RfuMetrics::cache.overview_summary(last_month_date, false)

    data = {
    	this_period: {
    		total_users: this_month[:total_users],
    		total_users_admins: this_month[:total_users_admins],
    		club_activations: this_month[:club_activations],
    		total_events: this_month[:total_events],
    		user_engagement: this_month[:user_engagement]
  		},
    	last_period: {
    		total_users: last_month[:total_users],
    		total_users_admins: last_month[:total_users_admins],
    		club_activations: last_month[:club_activations],
    		total_events: last_month[:total_events],
    	}
    }

    respond_with data
	end

	def users_activated
		tenant = get_tenant(params[:tenant_id])
		# authorize
		# TODO: ******************************** not dummy ting
		authorize! :create, Team

		chart = params[:type]
		raise InvalidParameter.new("invalid chart") unless %w(line).include? chart

		start_date = parse_date(params[:start_date])
		end_date = Date.today.at_beginning_of_month
		
		data = []

		(start_date..end_date).each do |d|
			next if d != d.at_beginning_of_month

			total_users = RfuMetrics.cache.total_players(d.at_end_of_month, false)
			registered_players = RfuMetrics.cache.total_users_activated(d.at_end_of_month, false)

			data << {
				month: d.strftime("%Y-%m-%d"),
				users: total_users.size,
				registered: registered_players.size
			}
		end

		respond_with data
	end

	def users_by_gender
		tenant = get_tenant(params[:tenant_id])
		# authorize
		# TODO: ******************************** not dummy ting
		authorize! :create, Team

		chart = "donut"
		start_date = parse_date(params[:start_date])

		data = RfuMetrics::cache.total_users_by_gender(start_date, false)
		chart_data = self.send("mash_to_#{chart}", data, start_date)

		respond_with chart_data
	end

	def users_by_experience
		tenant = get_tenant(params[:tenant_id])
		# authorize
		# TODO: ******************************** not dummy ting
		authorize! :create, Team

		if params[:type]=="donut"
			chart = "donut"

			until_date = params[:until_date].nil? ? Date.today : parse_date(params[:until_date])

			data = RfuMetrics::cache.total_users_by_experience(until_date, false)
			data = self.send("mash_to_#{chart}", data, until_date)
		else

			this_period = Date.today.at_end_of_month
			this_period_data = RfuMetrics::cache.total_users_by_experience(this_period, false)

			last_period = (Date.today.at_end_of_month - 1.month).at_end_of_month
			last_period_data = RfuMetrics::cache.total_users_by_experience(last_period, false)

			data = {
				this_period: this_period_data,
				last_period: last_period_data
			}
		end

		respond_with data
	end

	def events_total
		tenant = get_tenant(params[:tenant_id])
		# authorize
		# TODO: ******************************** not dummy ting
		authorize! :create, Team

		chart = params[:type]
		raise InvalidParameter.new("invalid chart") unless %w(line).include? chart

		start_date = parse_date(params[:start_date])
		end_date = Date.today.at_beginning_of_month
		
		data = []

		(start_date..end_date).each do |d|
			next if d != d.at_beginning_of_month

			events = MitooMetrics::Events.created
	    events.tenant_id = tenant.id
	    total_events = events.in_period(Date.new(2014,4,1), d.at_end_of_month)

			data << {
				month: d.strftime("%Y-%m-%d"),
				events: total_events.size
			}
		end

		respond_with data
	end

	def clubs_total
		tenant = get_tenant(params[:tenant_id])
		# authorize
		# TODO: ******************************** not dummy ting
		authorize! :create, Team

		chart = params[:type]
		raise InvalidParameter.new("invalid chart") unless %w(line).include? chart

		start_date = parse_date(params[:start_date])
		end_date = Date.today.at_beginning_of_month
		
		data = []

		(start_date..end_date).each do |d|
			next if d != d.at_beginning_of_month

			teams = MitooMetrics::Teams.created
	    teams.tenant_id = tenant.id
	    total_teams = teams.in_period(Date.new(2014,4,1), d.at_end_of_month)

	    active_teams = MitooMetrics::Teams.active
	    active_teams.tenant_id = tenant.id
	    total_active_teams = active_teams.in_period(Date.new(2014,4,1), d.at_end_of_month)

			data << {
				month: d.strftime("%Y-%m-%d"),
				clubs: total_teams.size,
				active: total_active_teams.size
			}
		end

		respond_with data
	end

	def participation_summary
		# grab tenant
		tenant = get_tenant(params[:tenant_id])

		# authorize
		# TODO: ******************************** not dummy ting
		authorize! :create, Team

		# get params
		unit = get_unit(params[:unit])
		start_date = parse_date(params[:start_date])

		puts "#{tenant.id} #{unit} #{start_date}"

		# get data
		this_period_data = Metrics::ParticipationAnalysis.summary(tenant.id, unit, start_date)
		last_period_data = Metrics::ParticipationAnalysis.summary(tenant.id, unit, start_date - 1.month)

    data = {
    	this_period: this_period_data,
    	last_period: last_period_data
    }

		respond_with data
	end

	def participation_split
		tenant = get_tenant(params[:tenant_id])
		# TODO: ******************************** not dummy ting
		authorize! :create, Team

		split = request.original_url.split('?')[0].split('/')[-1]
		# actually it has to be, because it's from the route, innit.
		raise ActiveRecord::RecordNotFound.new unless %w(gender experience source).include? split

		chart = params[:type]
		raise InvalidParameter.new("invalid chart") unless %w(donut line stacked_chart).include? chart

		unit = get_unit(params[:unit])
		start_date = parse_date(params[:start_date])

		if unit == :month
			data = Metrics::ParticipationAnalysis.send("by_#{split}", tenant.id, unit, start_date)
			chart_data = self.send("mash_to_#{chart}", data, start_date)
		elsif unit == :week && chart == "stacked_chart"

			chart_data = {}

			(start_date..start_date.at_end_of_month).each do |date|
				next if date != date.at_beginning_of_week
				data = Metrics::ParticipationAnalysis.send("by_#{split}", tenant.id, unit, date)
				data.each do |k, v|
					chart_data[k] = [] if chart_data[k].nil?
					chart_data[k] << [date, v]
				end
			end
		end
		
		respond_with chart_data
	end

	def participation_frequency
		tenant = get_tenant(params[:tenant_id])
		# authorize
		# TODO: ******************************** not dummy ting
		authorize! :create, Team

		chart = params[:type]
		raise InvalidParameter.new("invalid chart") unless %w(donut line stacked_chart).include? chart

		unit = get_unit(params[:unit])
		start_date = parse_date(params[:start_date])
		data = Metrics::ParticipationAnalysis.by_frequency(tenant.id, unit, start_date)

		return_data = data

		if chart != "donut"
			return_data = self.send("mash_to_#{chart}", data, start_date)
		end

		respond_with return_data
	end

	def engagement_summary
		# grab tenant
		tenant = get_tenant(params[:tenant_id])

		# authorize
		# TODO: ******************************** not dummy ting
		authorize! :create, Team

		# get params
		unit = get_unit(params[:unit])
		start_date = parse_date(params[:start_date])

		# get data
		data = Metrics::EngagementAnalysis.summary(tenant.id, unit, start_date)

		respond_with data
	end


	private

	def mash_to_donut(data, date)
		mashed = []
		data.each do |k, v|
			mashed << { label: k.to_s, value: v}
		end
		mashed
	end

	def mash_to_line(data, date)
		mashed = { labels: [], data: []}
		data.each do |h|
			new_h = {}
			i = 0
			h.each do |k, v|
				new_h[:xKey] = v if i == 0
				new_h["yKey#{i}".to_sym] = v unless i == 0
				mashed[:labels] << k unless i == 0 || mashed[:labels].include?(k)
				i += 1
			end
			mashed[:data] << new_h
		end
		mashed
	end

	def mash_to_stacked_chart(data, date)
		mashed = {}
		data.each do |k, v|
			mashed[k] = [[date, v]]
		end
		mashed
	end

	def get_unit(unit_string)
		begin
			unit = unit_string.to_sym
			raise InvalidParameter.new("invalid unit") unless @@valid_units.include? unit
			unit
		rescue
			raise InvalidParameter.new("invalid unit")
		end
	end

	def get_tenant(tenant_id)
		begin
			LandLord.new(tenant_id).tenant
		rescue
			raise InvalidParameter.new("invalid tenant_id")
		end
	end

	def parse_date(date)
		begin
			Date.strptime(date, '%Y-%m-%d')
		rescue
			raise InvalidParameter.new("invalid start_date")
		end
	end
end