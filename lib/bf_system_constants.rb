#Constant values should be meaningful because our API users will be setting these in their requests.
class Enumeration
  def Enumeration.add_item(key,value)
    @hash ||= {}
    @hash[key]=value
  end

  def Enumeration.const_missing(key)
    @hash[key]
  end

  def Enumeration.each
    @hash.each {|key,value| yield(key,value)}
  end

  def Enumeration.values
    @hash.values || []
  end

  def Enumeration.keys
    @hash.keys || []
  end

  def Enumeration.[](key)
    @hash[key]
  end
end

MAX_FAFT_TEAMS_ORGANISING = 10

COMPETITION_LEAGUE_ID = 10000

class ExceptionErrorCodes < Enumeration 
  self.add_item(:TEAM_INVITE_CONFLICT, 1000)
end

class TeamConfigKeyEnum < Enumeration
  self.add_item(:KEY, 'team_config')
  self.add_item(:AUTOMATED_REMINDER_SETTINGS, 'automated_reminder_settings')
  self.add_item(:AUTOMATED_REMINDER_SCHEDULED_HOUR, 'automated_reminder_scheduled_hour')
  self.add_item(:AUTOMATED_REMINDER_SCHEDULED_MINUTE, 'automated_reminder_scheduled_minute')
end

DEFAULT_TEAM_CONFIG = {
  TeamConfigKeyEnum::AUTOMATED_REMINDER_SETTINGS => [1, 3],
  TeamConfigKeyEnum::AUTOMATED_REMINDER_SCHEDULED_HOUR => 13,
  TeamConfigKeyEnum::AUTOMATED_REMINDER_SCHEDULED_MINUTE => 0,
}

class LeagueConfigKeyEnum < Enumeration
  self.add_item(:KEY, 'league_config')
  self.add_item(:PUBLIC_TEAM_PROFILES, 'public_team_profiles')
  self.add_item(:ORGANISER_CAN_CREATE_EVENTS, 'organiser_can_create_events')
  self.add_item(:NOTIFY_UNAVAILABLE_PLAYERS, 'notify_unavailable_players')
  self.add_item(:MANAGE_RESPONSES, 'manage_responses')
  self.add_item(:AUTOMATED_REMINDER_SETTINGS, 'automated_reminder_settings')
  self.add_item(:AUTOMATED_REMINDER_SCHEDULED_HOUR, 'automated_reminder_scheduled_hour')
  self.add_item(:AUTOMATED_REMINDER_SCHEDULED_MINUTE, 'automated_reminder_scheduled_minute')
  self.add_item(:LEAGUE_MANAGED_ROSTER, 'league_managed_roster')
end

DEFAULT_LEAGUE_CONFIG = {
  LeagueConfigKeyEnum::PUBLIC_TEAM_PROFILES => true,
  LeagueConfigKeyEnum::ORGANISER_CAN_CREATE_EVENTS => true,
  LeagueConfigKeyEnum::NOTIFY_UNAVAILABLE_PLAYERS => true,
  LeagueConfigKeyEnum::MANAGE_RESPONSES => true,
  LeagueConfigKeyEnum::AUTOMATED_REMINDER_SETTINGS => [1, 3],
  LeagueConfigKeyEnum::AUTOMATED_REMINDER_SCHEDULED_HOUR => 13,
  LeagueConfigKeyEnum::AUTOMATED_REMINDER_SCHEDULED_MINUTE => 0,
  LeagueConfigKeyEnum::LEAGUE_MANAGED_ROSTER => false
}

# ***** IF YOU UPDATE THIS YOU MUST UPDATE IT IN THE DIFFER TOO (differ_constants.rb)!!! TS ****
class AgeGroupEnum < Enumeration
  self.add_item(:UNDER_9, 9)
  self.add_item(:UNDER_10, 10)
  self.add_item(:UNDER_11, 11)
  self.add_item(:UNDER_12, 12)
  self.add_item(:UNDER_13, 13)
  self.add_item(:UNDER_14, 14)
  self.add_item(:UNDER_15, 15)
  self.add_item(:UNDER_16, 16)
  self.add_item(:UNDER_17, 17)
  self.add_item(:UNDER_18, 18)
  self.add_item(:UNDER_19, 19)
  self.add_item(:ADULT, 99)
end
# ***** IF YOU UPDATE THIS YOU MUST UPDATE IT IN THE DIFFER TOO (differ_constants.rb)!!! TS ****

class ColourEnum < Enumeration
  self.add_item(:BLACK, "333333")
  self.add_item(:RED, "CC3543")
  self.add_item(:ORANGE, "E0652D")
  self.add_item(:YELLOW, "FAB800")
  self.add_item(:GREEN, "2ABD7A")
  self.add_item(:BLUE, "4FADE3")
end

class DefaultColourEnum < Enumeration
  self.add_item(:DEFAULT_1, ColourEnum::BLUE)
  self.add_item(:DEFAULT_2, ColourEnum::RED)
  self.add_item(:FAFT_DEFAULT_1, "333333") 
  self.add_item(:FAFT_DEFAULT_2, "DDDDDD")
end


# ***** IF YOU UPDATE THIS YOU MUST UPDATE IT IN THE DIFFER TOO (differ_constants.rb)!!! TS ****
class EventStatusEnum < Enumeration
  self.add_item(:NORMAL, 0)
  self.add_item(:CANCELLED, 1)
  self.add_item(:DELETED, 2)
  self.add_item(:POSTPONED, 3)
  self.add_item(:RESCHEDULED, 4)
  self.add_item(:ABANDONED, 5)
  self.add_item(:VOID, 6)
end
# ***** IF YOU UPDATE THIS YOU MUST UPDATE IT IN THE DIFFER TOO (differ_constants.rb)!!! TS ****

class EditModeEnum < Enumeration
  self.add_item(:NO_EDITS, 0)
  self.add_item(:EDITS, 1)
  self.add_item(:PUBLISHING, 2)
end

class FormatEnum < Enumeration
  self.add_item(:HTML, "html")
  self.add_item(:JSON, "json")
  self.add_item(:TEXT, "text")
end

class GameTypeEnum < Enumeration
  self.add_item(:GAME, 0)
  self.add_item(:PRACTICE, 1)
  self.add_item(:EVENT, 2)
end

# TODO SR - These should already defined somewhere within rails.
class HTTPResponseCodeEnum < Enumeration
  self.add_item(:UNPROCESSABLE_ENTITY, 422)
  self.add_item(:UNAUTHORISED, 401)
  self.add_item(:REDIRECT, 302)
  self.add_item(:OK, 200)
  self.add_item(:NO_HEADER, 204)
  self.add_item(:BAD_REQUEST, 400)
  self.add_item(:FUCK, 500)
end

# Use AvailabilityEnum in favour of this. TS
class InviteResponseEnum < Enumeration
  self.add_item(:NOT_RESPONDED, 2)
  self.add_item(:AVAILABLE, 1)
  self.add_item(:UNAVAILABLE, 0)
end

class AvailabilityEnum < Enumeration
  self.add_item(:NOT_RESPONDED, 2)
  self.add_item(:AVAILABLE, 1)
  self.add_item(:UNAVAILABLE, 0)
end

class IPEnum < Enumeration
  self.add_item(:LOCALHOST, "127.0.0.1")
end

class KissMetricsEnum < Enumeration
  self.add_item(:REGISTERED_USER, "Signed Up")
end

class MobilePlatformEnum < Enumeration
  self.add_item(:IOS, "iOS")
  self.add_item(:ANDROID, "Android")
end

# ***** IF YOU UPDATE THIS YOU MUST UPDATE IT IN THE DIFFER TOO (differ_constants.rb)!!! TS ****
class PointsAdjustmentTypeEnum < Enumeration
  self.add_item(:POINTS, "points")
  self.add_item(:GOALS_FOR, "goals for")
  self.add_item(:GOALS_AGAINST, "goals against")
  self.add_item(:PLAYED, "played")
  self.add_item(:DRAWN, "drawn/tied")
  self.add_item(:WON, "won")
  self.add_item(:LOST, "lost")
end
# ***** IF YOU UPDATE THIS YOU MUST UPDATE IT IN THE DIFFER TOO (differ_constants.rb)!!! TS ****

class PointsStrategyEnum < Enumeration
  self.add_item(:AUTOMATIC, "automatic")
  self.add_item(:MANUAL, "manual")
  # could add sports etc. here.
end

class PolyRoleEnum < Enumeration
  self.add_item(:PLAYER, 1)
  self.add_item(:ORGANISER, 2)
  self.add_item(:PARENT, 3)
  self.add_item(:FOLLOWER, 4)
end

# This used to be NIStatusEnum, but I have generalised it (ie. changed it's name)
#  so that it can be used for any kind of queue status tracking, as it seems to 
#  be a more common task... TS
class QueueItemStatusEnum < Enumeration
  self.add_item(:DONE, 0)   # done motherfucker!
  self.add_item(:PROCESSING, 1) # being processed
  self.add_item(:QUEUED, 2)     # waiting to be processed
  self.add_item(:WAITING, 3)    # waiting to be queued (ie. for come criterion to be fullfilled)
  self.add_item(:FILTERED, 4)   # decided not to process before starting to process
  self.add_item(:REJECTED, 5)   # decided not to continue during processing
  self.add_item(:ERRORED, 9)    # should be processed, but can't for some reason (will be retried)
end

class VerbEnum < Enumeration
  self.add_item(:CREATED, "created")
  self.add_item(:DESTROYED, "destroyed")
  self.add_item(:POSTPONED, "postponed")
  self.add_item(:RESCHEDULED, "rescheduled")
end

class RoleEnum < Enumeration
  #Seeded into roles
  self.add_item(:INVITED, "Invited")
  self.add_item(:REGISTERED, "Registered")
  self.add_item(:NO_LOGIN, "No Login")
  self.add_item(:JUNIOR, "Junior")
  self.add_item(:ADMIN, "Admin")
  self.add_item(:FAFT_ROBOT, "FAFT Robot")
end

# ***** IF YOU UPDATE THIS YOU MUST UPDATE IT IN THE DIFFER TOO (differ_constants.rb)!!! TS ****
class ScoringSystemEnum < Enumeration
  self.add_item(:SOCCER, "Soccer")
  self.add_item(:FOOTBALL, "Football")
  self.add_item(:ONE_DAY_CRICKET, "OneDayCricket")
  self.add_item(:GENERIC, "Generic")
end
# ***** IF YOU UPDATE THIS YOU MUST UPDATE IT IN THE DIFFER TOO (differ_constants.rb)!!! TS ****

# ***** IF YOU UPDATE THIS YOU MUST UPDATE IT IN THE DIFFER TOO (differ_constants.rb)!!! TS ****
class SportsEnum < Enumeration
  # A
  self.add_item(:AMERICAN_FOOTBALL, "Football (American)")
  self.add_item(:AUSSIE_RULES_FOOTBALL, "Aussie Rules Football")
  self.add_item(:ATHLETICS, "Athletics")
  # B
  self.add_item(:BASKETBALL, "Basketball")
  self.add_item(:BASEBALL, "Baseball")
  self.add_item(:BOWLING, "Bowling")
  # C
  self.add_item(:CRICKET, "Cricket")
  self.add_item(:CYCLING, "Cycling")
  self.add_item(:CURLING, "Curling")
  self.add_item(:CHEERLEADING, "Cheerleading")
  # D
  self.add_item(:DODGEBALL, "Dodgeball")
  # E
  self.add_item(:EQUESTRIAN, "Equestrian")
  # F
  # G
  self.add_item(:GAELIC_FOOTBALL, "Gaelic Football")
  self.add_item(:GOLF, "Golf")
  # H
  self.add_item(:HOCKEY, "Hockey")
  self.add_item(:HURLING, "Hurling")
  self.add_item(:HANDBALL, "Handball")
  # I
  self.add_item(:ICE_HOCKEY, "Ice Hockey")
  # J
  # K
  self.add_item(:KORFBALL, "Korfball")
  self.add_item(:KICKBALL, "Kickball")
  # L
  self.add_item(:LASER_TAG, "Laser Tag")
  self.add_item(:LACROSSE, "Lacrosse")
  # M
  # N
  self.add_item(:NETBALL, "Netball")
  # O
  self.add_item(:OTHER, "Other")
  # P
  self.add_item(:PAINTBALL, "Paintball")
  # Q
  # R
  self.add_item(:ROWING, "Rowing")
  self.add_item(:RUGBY, "Rugby")
  self.add_item(:RUNNING, "Running")
  self.add_item(:ROLLER_DERBY, "Roller Derby")
  # S
  self.add_item(:SOCCER, "Football (Soccer)")
  self.add_item(:SWIMMING, "Swimming")
  self.add_item(:SOFTBALL, "Softball")
  self.add_item(:SURFING, "Surfing")
  self.add_item(:SPEEDWAY, "Speedway")
  self.add_item(:SWIMMING, "Swimming")
  # T
  self.add_item(:TENNIS, "Tennis")
  # U
  self.add_item(:ULTIMATE_FRISBEE, "Ultimate Frisbee")
  # V
  self.add_item(:VOLLEYBALL, "Volleyball")
  # W
  self.add_item(:WATER_POLO, "Water Polo")
  # X
  # Y
  # Z
end
# ***** IF YOU UPDATE THIS YOU MUST UPDATE IT IN THE DIFFER TOO (differ_constants.rb)!!! TS ****

class TeamDSRoleEnum < Enumeration
  self.add_item(:MEMBER, 1)
  self.add_item(:PENDING, 2)
  self.add_item(:REJECTED, 3)
  self.add_item(:DELETED, 4)
end

class TenantEnum < Enumeration
  self.add_item(:MITOO, 1)
  self.add_item(:O2_TOUCH, 2)
  self.add_item(:SOCCER_SIXES, 3)
  self.add_item(:ALIEN, 4)
end

class TenantNameEnum < Enumeration
  self.add_item(:MITOO, "mitoo")
  self.add_item(:O2_TOUCH, "o2_touch")
  self.add_item(:SOCCER_SIXES, "soccer_sixes")
  self.add_item(:ALIEN, "alien")
end

class TenantEnum < Enumeration
  self.add_item(:MITOO_ID, 1)
  self.add_item(:O2_TOUCH_ID, 2)
  self.add_item(:SOCCER_SIXES_ID, 3)
  self.add_item(:ALIEN_ID, 4)
end

class TimeEnum < Enumeration
  self.add_item(:TOMMOROW, 1.day.from_now)
  self.add_item(:YESTERDAY, 1.day.ago)
  self.add_item(:NOW, Time.now)
  self.add_item(:NEXT_MONTH, 1.month.from_now)
  self.add_item(:LAST_MONTH, 1.month.ago)
  self.add_item(:END_OF_THIS_WEEK, Time.now.end_of_week)
  self.add_item(:END_OF_NEXT_WEEK, 1.week.from_now.end_of_week)
end

class TimeZoneEnum < Enumeration
  self.add_item(-12, 'Etc/GMT+12')
  self.add_item(-11, 'Pacific/Pago_Pago')
#  self.add_item(-10, 'America/Adak'),
  self.add_item(-10, 'Pacific/Honolulu')
  self.add_item(-9.5, 'Pacific/Marquesas')
  self.add_item(-9, 'Pacific/Gambier')
#  self.add_item(-9, 'America/Anchorage')
  self.add_item(-8, 'America/Los_Angeles')
#  self.add_item(-8, 'Pacific/Pitcairn')
#  self.add_item(-7, 'America/Phoenix')
  self.add_item(-7, 'America/Denver')
#  self.add_item(-6, 'America/Guatemala')
  self.add_item(-6, 'America/Chicago')
#  self.add_item(-6, 'Pacific/Easter')
#  self.add_item(-5, 'America/Bogota')
  self.add_item(-5, 'America/New_York')
#  self.add_item(-4.5, 'America/Caracas')
#  self.add_item(-4.5, 'America/Halifax')
  self.add_item(-4.5, 'America/Santo_Domingo')
  self.add_item(-4, 'America/Asuncion')
  self.add_item(-3.5, 'America/St_Johns')
#  self.add_item(-3, 'America/Godthab')
  self.add_item(-3, 'America/Argentina/Buenos_Aires')
#  self.add_item(-3, 'America/Montevideo')
#  self.add_item(-2, 'America/Noronha')
  self.add_item(-2, 'Etc/GMT+2')
  self.add_item(-1, 'Atlantic/Azores')
#  self.add_item(-1, 'Atlantic/Cape_Verde')
  self.add_item(0, 'Etc/UTC')
#  self.add_item(0, 'Europe/London')
  self.add_item(1, 'Europe/Berlin')
#  self.add_item(1, 'Africa/Lagos')
#  self.add_item(1, 'Africa/Windhoek')
#  self.add_item(2, 'Asia/Beirut')
  self.add_item(2, 'Africa/Johannesburg')
  self.add_item(3, 'Europe/Moscow')
#  self.add_item(3, 'Asia/Baghdad')
  self.add_item(3.5, 'Asia/Tehran')
  self.add_item(4, 'Asia/Dubai')
#  self.add_item(4, 'Asia/Yerevan')
  self.add_item(4.5, 'Asia/Kabul')
#  self.add_item(5, 'Asia/Yekaterinburg')
  self.add_item(5, 'Asia/Karachi')
  self.add_item(5.5, 'Asia/Kolkata')
  self.add_item(5.75, 'Asia/Kathmandu')
#  self.add_item(6, 'Asia/Dhaka')
  self.add_item(6, 'Asia/Omsk')
  self.add_item(6.5, 'Asia/Rangoon')
#  self.add_item(7, 'Asia/Krasnoyarsk')
  self.add_item(7, 'Asia/Jakarta')
  self.add_item(8, 'Asia/Shanghai')
#  self.add_item(8, 'Asia/Irkutsk')
  self.add_item(8.75, 'Australia/Eucla')
#  self.add_item(8.75, 'Australia/Eucla')
#  self.add_item(9, 'Asia/Yakutsk')
  self.add_item(9, 'Asia/Tokyo')
  self.add_item(9.5, 'Australia/Darwin')
#  self.add_item(9.5, 'Australia/Adelaide')
  self.add_item(10, 'Australia/Brisbane')
#  self.add_item(10, 'Asia/Vladivostok')
#  self.add_item(10, 'Australia/Sydney')
  self.add_item(10.5, 'Australia/Lord_Howe')
#  self.add_item(11, 'Asia/Kamchatka')
  self.add_item(11, 'Pacific/Noumea')
  self.add_item(11.5, 'Pacific/Norfolk')
  self.add_item(12, 'Pacific/Auckland')
#
#  self.add_item(12, 'Pacific/Tarawa')
  self.add_item(12.75, 'Pacific/Chatham')
#  self.add_item(13, 'Pacific/Tongatapu')
  self.add_item(13, 'Pacific/Apia')
  self.add_item(14, 'Pacific/Kiritimati')
end

class TransactionItemStatusEnum < Enumeration
  self.add_item(:PROCESSED, 0)
  self.add_item(:IGNORED_NOT_IN_BF, 1)
  self.add_item(:IGNORED_NO_MODEL_UPDATES, 2)
  self.add_item(:IGNORED_ID_IS_NULL, 3)
end

class UserIdEnum < Enumeration
  self.add_item(:FAFT_ROBOT, 1)
  self.add_item(:TIM, 6623)
  self.add_item(:JONNY_BRAP, 8325)
end

# This is actually used for both invitations, and registrations
class UserInvitationTypeEnum < Enumeration
  #Persisted into users.invited_by_source
  self.add_item(:NORMAL, "NORMAL") # A new team org signs up via the signup form
  self.add_item(:USER, "USER") # User signup, do nothing interesting
  self.add_item(:FACEBOOK, "FACEBOOK") # A dickhead click login with fb, but don't got no account
  self.add_item(:EVENT, "TEAMMEMBER") #An organiser adds a user to an event
  self.add_item(:TEAM_PROFILE, "TEAMPROFILE") #An organiser adds a user to the team via the teams profile page
  self.add_item(:LINKED_PARENT_JUNIOR, "JUNIOR") #An organiser adds a junior user to the team via the teams profile page
  self.add_item(:CONFIRM_USER, "CONFIRM_USER")
  self.add_item(:TEAM_FOLLOW, "TEAMFOLLOW")
  self.add_item(:JOIN_EVENT, "EVENT") # user joins via event (ie. o2 touch)
  self.add_item(:EVENT_CHECKIN, "EVENT_CHECK_IN") # add a user, and check them into an event
  self.add_item(:TEAM_OPEN_INVITE_LINK, "TEAMOPENINVITELINK")
  self.add_item(:USER_CLAIM_LEAGUE, "USERCLAIMLEAGUE") # a user joins by claiming a league
end

class FieldValidation < Enumeration
  self.add_item(:MAXIMUM_MESSAGE_LENGTH, 4000)
  self.add_item(:MINIMUM_MESSAGE_LENGTH, 1)
end

class MessageGroups < Enumeration
  self.add_item(:ALL, 0)
  self.add_item(:AVAILABLE, 1)
  self.add_item(:AWAITING, 2)
  self.add_item(:UNAVAILABLE, 3)
end  


#####
# NOTIFICATION SETTINGS/GROUPS
#####

class NotificationGroupsEnum < Enumeration
  self.add_item(:NOTIFICATIONS_ENABLED, :notifications_enabled)
  self.add_item(:MESSAGING_AVAILABILITY, :group_messaging_availability)
  self.add_item(:TEAM_GAMES, :group_team_games)
  self.add_item(:TEAM_RESULTS, :group_team_results)
  self.add_item(:LEAGUE_RESULTS, :group_league_results)
  self.add_item(:OPPOSITION_INFO, :group_opposition_info)
  self.add_item(:TEAM_MEMBER_UPDATES, :group_opposition_info)
end

NOTIFICATION_GROUP_DEFAULTS = {
  NotificationGroupsEnum::NOTIFICATIONS_ENABLED => true,
  NotificationGroupsEnum::MESSAGING_AVAILABILITY => true,
  NotificationGroupsEnum::TEAM_GAMES => true,
  NotificationGroupsEnum::TEAM_RESULTS => true
}

NOTIFICATION_GROUPS = {
  NotificationGroupsEnum::NOTIFICATIONS_ENABLED => true,
  NotificationGroupsEnum::MESSAGING_AVAILABILITY => [
    :team_message_created,
    :event_message_created,
    :division_message_created
  ],
  NotificationGroupsEnum::TEAM_GAMES => [
    :event_created,
    :event_updated,
    :event_cancelled,
    :event_activated,
    :event_postponed,
    :event_rescheduled,
    :weekly_event_schedule,
    :weekly_next_game
  ],
  NotificationGroupsEnum::TEAM_RESULTS => [
    :result_created,
    :result_updated
  ],
  NotificationGroupsEnum::LEAGUE_RESULTS => [
    :division_result_created,
    :division_result_updated
  ],
  # These do not exist yet
  NotificationGroupsEnum::OPPOSITION_INFO => [],
  NotificationGroupsEnum::TEAM_MEMBER_UPDATES => [],
}