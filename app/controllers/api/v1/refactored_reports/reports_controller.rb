class Api::V1::RefactoredReports::ReportsController < Api::V1::ApplicationController
  @@valid_units = [:alltime, :month, :week]

  RFU_START_OF_TIME = Date.new(2014,05,01)

  def summary
    authorize! :create, Team

    this_month_date = Date.today.at_end_of_month
    last_month_date = (Date.today - 1.month).at_end_of_month

    data = {
      this_period: {
        total_users: total_users(this_month_date),
      },
      last_period: {
        total_users: total_users(last_month_date),
      }
    }

    respond_with data
  end

  def chart
    authorize! :create, Team

    start_date = RFU_START_OF_TIME.at_end_of_month
    end_date = Date.today.at_end_of_month

    teams = Team.where(tenant_id: 2) # o2 touch, obvs

    members = teams.map(&:members)
    members.flatten!
    members.uniq!    

    data = []
    date = start_date
    while date <= end_date do
      data << {
        month: date.strftime("%Y-%m-%d"),
        users: members.select{ |m| m.created_at <= date }.count
      }
      date += 1.month
    end

    respond_with data
  end

  private

  def total_users(end_date=nil) 
    teams = Team.where(tenant_id: 2) # o2 touch, obvs

    members = teams.map(&:members)
    members.flatten!
    members.uniq!
    members.reject{ |p| p.created_at > end_date } unless end_date.nil?

    members.count
  end
end