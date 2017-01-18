function load_insights_data_major(major_data) {
    $("#insights-company-major").highcharts({
        chart: {
            plotBackgroundColor: null,
            plotBorderWidth: null,
            plotShadow: false
        },
        title: {
            text: 'Major Insights'
        },
        tooltip: {
            pointFormat: '{series.name}: <b>{point.percentage:.1f}%</b>'
        },
        plotOptions: {
            pie: {
                allowPointSelect: true,
                cursor: 'pointer',
                dataLabels: {
                    enabled: true,
                    format: '<b>{point.name}</b>: {point.percentage:.1f} %',
                    style: {
                        color: (Highcharts.theme && Highcharts.theme.contrastTextColor) || 'black'
                    }
                }
            }
        },
        series: [{
            type: 'pie',
            name: 'Major ',
            data: major_data
        }]
    });
};

function load_insights_data_skills(skills_data) {
    $("#insights-company-skills").highcharts({
        chart: {
            plotBackgroundColor: null,
            plotBorderWidth: null,
            plotShadow: false
        },
        title: {
            text: 'Skill Insights'
        },
        tooltip: {
            pointFormat: '{series.name}: <b>{point.percentage:.1f}%</b>'
        },
        plotOptions: {
            pie: {
                allowPointSelect: true,
                cursor: 'pointer',
                dataLabels: {
                    enabled: true,
                    format: '<b>{point.name}</b>: {point.percentage:.1f} %',
                    style: {
                        color: (Highcharts.theme && Highcharts.theme.contrastTextColor) || 'black'
                    }
                }
            }
        },
        series: [{
            type: 'pie',
            name: 'Skill ',
            data: skills_data
        }]
    });
};

function load_insights_data_interview_experience(experience_data) {
    $("#insights-company-interview-experience").highcharts({
        chart: {
            plotBackgroundColor: null,
            plotBorderWidth: null,
            plotShadow: false
        },
        title: {
            text: 'Interview Experience'
        },
        tooltip: {
            pointFormat: '{series.name}: <b>{point.percentage:.1f}%</b>'
        },
        plotOptions: {
            pie: {
                allowPointSelect: true,
                cursor: 'pointer',
                dataLabels: {
                    enabled: true,
                    format: '<b>{point.name}</b>: {point.percentage:.1f} %',
                    style: {
                        color: (Highcharts.theme && Highcharts.theme.contrastTextColor) || 'black'
                    }
                }
            }
        },
        series: [{
            type: 'pie',
            name: 'Interview Experience ',
            data: experience_data
        }]
    });
};

function load_insights_data_Hiring_sources(sources_data) {
    $("#insights-company-hiring-sources").highcharts({
        chart: {
            plotBackgroundColor: null,
            plotBorderWidth: null,
            plotShadow: false
        },
        title: {
            text: 'Hiring Sources'
        },
        tooltip: {
            pointFormat: '{series.name}: <b>{point.percentage:.1f}%</b>'
        },
        plotOptions: {
            pie: {
                allowPointSelect: true,
                cursor: 'pointer',
                dataLabels: {
                    enabled: true,
                    format: '<b>{point.name}</b>: {point.percentage:.1f} %',
                    style: {
                        color: (Highcharts.theme && Highcharts.theme.contrastTextColor) || 'black'
                    }
                }
            }
        },
        series: [{
            type: 'pie',
            name: 'Hiring Source',
            data: sources_data
        }]
    });
};

function load_insights_data_major_year (major_year_data) {
    $("#insights-company-hiring-trend").highcharts({
        chart: {
            type: "spline"
        },
        title: {
            text: "Hiring Count"
        },
        xAxis: {
            type: 'datetime',
            dateTimeLabelFormats: { // don't display the year
                year: '%Y'
            },
            title: {
                text: 'Year'
            }
        },
        yAxis: {
            title: {
                text: 'Hiring count'
            },
            min: 0
        },
        tooltip: {
            headerFormat: '<b>{series.name}</b><br>',
            pointFormat: '{point.x:%Y}: {point.y:.2f}'
        },
        series: major_year_data
    });
};

function toggleTable(obj, table_id) {
    // check if the rows are
    var rows = $('#'+table_id).find("tr:gt(5)");
    var hidden = rows.first().css('display') == 'none';
    if(hidden) {
        // make the obj collapsible
        var chevron = $(obj).find("i");
        chevron.toggleClass("icon-chevron-down");
        chevron.toggleClass("icon-chevron-up");
        $(obj).find("span").text("less");
    } else {
        // make the obj collapsible
        var chevron = $(obj).find("i");
        chevron.toggleClass("icon-chevron-up");
        chevron.toggleClass("icon-chevron-down");
        $(obj).find("span").text("more");
    }
    rows.toggle();
};