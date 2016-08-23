# pattern = ///
#   ^\(?(\d{3})\)? # Capture area code, ignore optional parens
#   [-\s]?(\d{3})  # Capture prefix, ignore optional dash or space
#   -?(\d{4})      # Capture line-number, ignore optional dash
# ///
# [area_code, prefix, line] = "(555)123-4567".match(pattern)[1..3]
# => ['555', '123', '4567']