{
  :en => {
    :time => {
      :formats => {
        :full => lambda { |time, _| "%H:%M | %A, #{time.day.ordinalize} %B %Y" }
      }
    }
  }
}