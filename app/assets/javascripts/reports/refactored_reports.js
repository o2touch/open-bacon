var colorGrey = "rgb(128,133,133)";

var colorBlue = "rgb(114,147,203)";
var colorPurple = "rgb(144,103,167)";
var colorGreen = "rgb(132,186,91)";
var colorOrange = "rgb(255,151,76)";
var colorMaroon = "rgb(171,104,87)";
var colorBeige = "rgb(204,194,16)";
var colorRed = "rgb(211,94,96)";

/* Helper method to convert a string to a date object */
function convertStringsToDateObjects(data, i) {
  $.map(data, function(row) {
    row[i] = new Date(row[i]);
    return row;
  });
}

function loadRefactoredOverviewSummary(tenantId, month, year) {

  // Summary Data
  $.get('/api/v1/refactored_reports/summary?tenant_id=' + tenantId, function(data) {

    $("#total-users").data('value', data.this_period.total_users);

    // Total users change
    tuc = ((data.this_period.total_users - data.last_period.total_users) / data.last_period.total_users) * 100;
    tuc = formatNumber(tuc)
    $("#total-users-last-period").html(tuc);

    $('.animate-number').each(function() {
      $(this).animateNumbers($(this).data("value"), true, parseInt($(this).data("animationDuration")));
    });
  });
}

function loadRefactoredDashboardCharts(tenantId, month, year) {

  var monthNames = ["January", "February", "March", "April", "May", "June",
    "July", "August", "September", "October", "November", "December"
  ];

  // Players Signed-up
  $.get('/api/v1/refactored_reports/chart?tenant_id=' + tenantId + '&start_date=2014-05-01&type=line', function(json) {
    window.rugbyPlayersChart = new Morris.Line({
      element: 'chart-users',
      data: json,
      lineColors: ["#333", "#f35957", "#736086"],
      xkey: 'month',
      dateFormat: function(x) {
        return monthNames[new Date(x).getMonth()];
      },
      xLabels: "month",
      xLabelFormat: function(x) {
        return monthNames[new Date(x).getMonth()];
      },
      ykeys: ['users'],
      labels: ['Total']
    });
  });
}
