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

function loadOverviewSummary(tenantId, month, year) {

  // Summary Data
  $.get('/api/v1/reports/overview/summary?tenant_id=' + tenantId, function(data) {

    $("#total-users").data('value', data.this_period.total_users);
    $("#total-users-admins").data('value', data.this_period.total_users_admins);
    $("#club_activations").data('value', data.this_period.club_activations);
    $("#total_events").data('value', data.this_period.total_events);
    $("#user_engagement").data('value', data.this_period.user_engagement);

    // Total users change
    tuc = ((data.this_period.total_users - data.last_period.total_users) / data.last_period.total_users) * 100;
    tuc = formatNumber(tuc)
    $("#total-users-last-period").html(tuc);

    // Total events change
    tec = ((data.this_period.total_events - data.last_period.total_events) / data.last_period.total_events) * 100;
    tec = formatNumber(tec)
    $("#total-events-last-period").html(tec);

    // Club Activations change
    cac = ((data.this_period.club_activations - data.last_period.club_activations) / data.last_period.club_activations) * 100;
    cac = formatNumber(cac)
    $("#club-activations-last-period").html(cac);

    $('.animate-number').each(function() {
      $(this).animateNumbers($(this).data("value"), true, parseInt($(this).data("animationDuration")));
    });
  });
}

function loadDashboardCharts(tenantId, month, year) {

  var monthNames = ["January", "February", "March", "April", "May", "June",
    "July", "August", "September", "October", "November", "December"
  ];

  // Players Signed-up
  $.get('/api/v1/reports/users/activated?tenant_id=' + tenantId + '&start_date=2014-05-01&type=line', function(json) {
    window.rugbyPlayersChart = new Morris.Line({
      element: 'chart-rugbyplayers',
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
      ykeys: ['users', 'registered'],
      labels: ['Total', 'Activated']
    });
  });

  // Events Total
  $.get('/api/v1/reports/events/total?tenant_id=' + tenantId + '&start_date=2014-05-01&type=line', function(json) {
    window.rugbyPlayersChart = new Morris.Line({
      element: 'chart-events-total',
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
      ykeys: ['events'],
      labels: ['created']
    });
  });

  // TB Clubs Total
  $.get('/api/v1/reports/clubs/total?tenant_id=' + tenantId + '&start_date=2014-05-01&type=line', function(json) {
    window.rugbyPlayersChart = new Morris.Line({
      element: 'chart-tb-clubs-total',
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
      ykeys: ['clubs', 'active'],
      labels: ['Total', 'Active']
    });
  });

  // Gender Donut
  $.get('/api/v1/reports/users/by_gender?tenant_id=' + tenantId + '&start_date=2014-04-01&unit=alltime&type=donut', function(data) {
    var genderDonut = new Morris.Donut({
      element: 'gender-donut',
      data: data,
      colors: [colorBlue, colorPurple, colorGrey]
    });
  });

  // New Existing Donut
  $.get('/api/v1/reports/users/by_experience?tenant_id=' + tenantId + '&type=donut', function(data) {
    var newexistingDonut = new Morris.Donut({
      element: 'new-existing-donut',
      data: data,
      colors: [colorGreen, colorOrange, colorGrey]
    });
  });

  // New Exisiting Change
  $.get('/api/v1/reports/users/by_experience?tenant_id=' + tenantId, function(data) {

    existing_change = data.this_period.existing - data.last_period.existing;
    existing_change_pc =  existing_change / data.last_period.existing * 100;
    existing_change_pc = formatNumber(existing_change_pc);

    new_change = data.this_period.new_to_rugby - data.last_period.new_to_rugby;
    new_change_pc = new_change / data.last_period.new_to_rugby * 100;
    new_change_pc = formatNumber(new_change_pc);


    $("#existing-change").html(existing_change);
    $("#existing-change-pc").html(existing_change_pc);

    $("#new-change").html(new_change);
    $("#new-change-pc").html(new_change_pc);
  });

}

function loadParticipationCharts(tenantId, month, year) {
  selectedDate = year + "-" + month + "-01";
  unit = "month";

  $(".green").css('background-color', colorGreen);
  $(".blue").css('background-color', colorBlue);
  $(".red").css('background-color', colorRed);
  $(".purple").css('background-color', colorPurple);

  // Summary Data
  $.get('/api/v1/reports/participation/summary?tenant_id=' + tenantId + '&unit=' + unit + '&start_date=' + selectedDate, function(data) {

    $("#total-players").data('value', data.this_period.total_players);
    tpc = ((data.this_period.total_players / data.last_period.total_players) - 1) * 100;
    tpc = formatNumber(tpc)
    $("#total-players-last-period").html(tpc);
    
    $("#new_to_rugby").data('value', data.this_period.new_to_rugby);
    ntrc = ((data.this_period.new_to_rugby / data.last_period.new_to_rugby) - 1) * 100;
    ntrc = formatNumber(ntrc)
    $("#new_to_rugby_last_period").html(ntrc);

    $("#total_frequent").data('value', data.this_period.total_frequent);
    tfc = ((data.this_period.total_frequent / data.last_period.total_frequent) - 1) * 100;
    tfc = formatNumber(tfc)
    $("#total_frequent_last_period").html(tfc);

    $("#total_infrequent").data('value', data.this_period.total_infrequent);
    tifc = ((data.this_period.total_infrequent / data.last_period.total_infrequent) - 1) * 100;
    tifc = formatNumber(tifc)
    $("#total_infrequent_last_period").html(tifc);

    $('.animate-number').each(function() {
      $(this).animateNumbers($(this).data("value"), true, parseInt($(this).data("animationDuration")));
    });

  });

  // Gender Donut
  $.get('/api/v1/reports/participation/gender?tenant_id=' + tenantId + '&unit=' + unit + '&start_date=' + selectedDate + '&type=donut', function(data) {
    var genderDonut = new Morris.Donut({
      element: 'gender-donut',
      data: data,
      colors: [colorBlue, colorPurple, colorGrey]
    });
  });

  // New Existing Donut
  $.get('/api/v1/reports/participation/experience?tenant_id=' + tenantId + '&unit=' + unit + '&start_date=' + selectedDate + '&type=donut', function(data) {
    var newexistingDonut = new Morris.Donut({
      element: 'new-existing-donut',
      data: data,
      colors: [colorGreen, colorOrange, colorGrey]
    });
  });

  // Source Donut
  $.get('/api/v1/reports/participation/source?tenant_id=' + tenantId + '&unit=' + unit + '&start_date=' + selectedDate + '&type=donut', function(data) {
    var sourceDonut = new Morris.Donut({
      element: 'source-donut',
      data: data,
      colors: [colorMaroon, colorBeige, colorRed, colorGrey]
    });
  });

  // Frequency Donut
  $.get('/api/v1/reports/participation/frequency?tenant_id=' + tenantId + '&unit=' + unit + '&start_date=' + selectedDate + '&type=donut', function(data) {

    donutData = [{
      label: 'Once',
      value: data[0].once
    }, {
      label: 'Twice',
      value: data[0].twice
    }, {
      label: 'Thrice',
      value: data[0].thrice
    }];

    var anotherDonut = new Morris.Donut({
      element: 'frequency-donut',
      data: donutData,
      colors: [colorMaroon, colorBeige, colorRed, colorGrey]
    });
  });

  // Gender Stacked
  $.get('/api/v1/reports/participation/gender?tenant_id=' + tenantId + '&unit=week&start_date=' + selectedDate + '&type=stacked_chart', function(data) {
    console.log(data);
    initGenderStackedChart(data);
  });

  // Source Stacked
  $.get('/api/v1/reports/participation/source?tenant_id=' + tenantId + '&unit=week&start_date=' + selectedDate + '&type=stacked_chart', function(data) {
    initSourceStackedChart(data);
  });

  // Frequency Line
  // $.get('/api/v1/reports/participation/frequency?tenant_id=' + tenantId + '&unit=' + unit + '&start_date=' + selectedDate + '&type=line', function(json) {

  //  convertStringsToDateObjects(json.data, 0);

  //  $("#chart-participation").html("");

  //  var frequencyChart = new Morris.Line({
  //    element: 'chart-participation',
  //    data: json.data,
  //    xkey: 'xKey',
  //    ykeys: ['yKey1', 'yKey2', 'yKey3'],
  //    labels: json.labels
  //  });
  // });
}

/* LOAD GENDER STACKED CHART */
function initGenderStackedChart(data) {

  convertStringsToDateObjects(data.male, 0);
  convertStringsToDateObjects(data.female, 0);

  min_date = data.male[0][0];
  max_date = data.male[(data.male.length - 1)][0];

  var chart_data = [{
    label: "Male",
    data: data.male,
    bars: {
      show: true,
      barWidth: 12 * 24 * 60 * 60 * 300,
      fill: true,
      lineWidth: 0,
      order: 0,
      fillColor: colorBlue
    },
    color: colorBlue
  }, {
    label: "Female",
    data: data.female,
    bars: {
      show: true,
      barWidth: 12 * 24 * 60 * 60 * 300,
      fill: true,
      lineWidth: 0,
      order: 0,
      fillColor: colorPurple
    },
    color: colorPurple
  }];

  var stackedChart1 = $.plot($('#chart-stacked-gender'), chart_data, {
    grid: {
      hoverable: false,
      clickable: false,
      borderWidth: 1,
      borderColor: '#f0f0f0',
      labelMargin: 8

    },
    xaxis: {
      min: (min_date).getTime(),
      max: (max_date).getTime(),
      mode: "time",
      timeformat: "%e",

      tickSize: [6, "day"],
      tickFormatter: function(val, axis) {
        var d = new Date(val);
        return d.getUTCDate() + "/" + (d.getUTCMonth() + 1);
      },
      monthNames: ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"],
      tickLength: 5, // hide gridlines

      axisLabel: 'Month',
      axisLabelUseCanvas: true,
      axisLabelFontSizePixels: 12,
      axisLabelFontFamily: 'Verdana, Arial, Helvetica, Tahoma, sans-serif',
      axisLabelPadding: 5
    },
    legend: {
      show: true,
      container: "#stacked-gender-legend"
    },
    stack: true
  });
}

/* LOAD SOURCE STACKD CHART */
function initSourceStackedChart(data) {

  convertStringsToDateObjects(data.web, 0);
  convertStringsToDateObjects(data.operator, 0);

  var min_date = data.web[0][0];
  var max_date = data.web[(data.web.length - 1)][0];

  var data2 = [{
      label: "Web/Mobile",
      data: data.web,
      bars: {
        show: true,
        barWidth: 3 * 24 * 60 * 60 * 1000,
        align: "left",
        fill: true,
        lineWidth: 0,
        order: 0,
        fillColor: colorMaroon
      },
      color: colorMaroon
    }, {
      label: "Operator",
      data: data.operator,
      bars: {
        show: true,
        barWidth: 3 * 24 * 60 * 60 * 1000,
        align: "left",
        fill: true,
        lineWidth: 0,
        order: 0,
        fillColor: colorBeige
      },
      color: colorBeige
    }

  ];

  $.plot($('#chart-stacked-source'), data2, {
    grid: {
      hoverable: false,
      clickable: false,
      borderWidth: 1,
      borderColor: '#f0f0f0',
      labelMargin: 8
    },
    xaxis: {
      min: (min_date).getTime(),
      max: (max_date).getTime(),
      mode: "time",
      timeformat: "%e",
      tickSize: [6, "day"],
      tickFormatter: function(val, axis) {
        var d = new Date(val);
        return d.getUTCDate() + "/" + (d.getUTCMonth() + 1);
      },
      monthNames: ["Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec"],
      tickLength: 0, // hide gridlines
      axisLabel: 'Month',
      axisLabelUseCanvas: true,
      axisLabelFontSizePixels: 12,
      axisLabelFontFamily: 'Verdana, Arial, Helvetica, Tahoma, sans-serif',
      axisLabelPadding: 5
    },
    legend: {
      show: true,
      container: "#stacked-source-legend"
    },
    stack: true
  });
}

//Ricksaw Chart Sample 
function loadRicksawChart() {
  var seriesData = [
    [],
    [],
    []
  ];
  var random = new Rickshaw.Fixtures.RandomData(50);

  for (var i = 0; i < 50; i++) {
    random.addData(seriesData);
  }

  rick = new Rickshaw.Graph({
    element: document.querySelector("#chart-ricksaw"),
    height: 200,
    renderer: 'area',
    series: [{
      data: seriesData[0],
      color: '#736086',
      name: 'Existing Players'
    }, {
      data: seriesData[1],
      color: '#f8a4a3',
      name: 'New to Rugby'
    }, {
      data: seriesData[2],
      color: '#eceff1',
      name: 'All'
    }]
  });
  var hoverDetail = new Rickshaw.Graph.HoverDetail({
    graph: rick
  });

  random.addData(seriesData);
  rick.update();

  var ticksTreatment = 'glow';

  var xAxis = new Rickshaw.Graph.Axis.Time({
    graph: rick,
    ticksTreatment: ticksTreatment,
    timeFixture: new Rickshaw.Fixtures.Time.Local()
  });

  xAxis.render();

  var yAxis = new Rickshaw.Graph.Axis.Y({
    graph: rick,
    tickFormat: Rickshaw.Fixtures.Number.formatKMBT,
    ticksTreatment: ticksTreatment
  });

  var legend = new Rickshaw.Graph.Legend({
    graph: rick,
    element: document.getElementById('legend')
  });

  yAxis.render();

  var shelving = new Rickshaw.Graph.Behavior.Series.Toggle({
    graph: rick,
    legend: legend
  });

  var order = new Rickshaw.Graph.Behavior.Series.Order({
    graph: rick,
    legend: legend
  });

  var highlighter = new Rickshaw.Graph.Behavior.Series.Highlight({
    graph: rick,
    legend: legend
  });
}

function formatNumber(num){
  num = Number((num).toFixed(0))
  return isFinite(num) ? num + "%": "n/a"
}