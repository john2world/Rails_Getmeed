function load_insights_data_profileviews(public_profile_views_data) {
    $("#insights-profileviews-trend").highcharts({
        chart: {
            type: "spline"
        },
        title: {
            text: "Profile Views"
        },
        xAxis: {
            type: 'datetime',
            dateTimeLabelFormats: { // don't display the year
                month: '%e. %b',
                year: '%b'
            },
            title: {
                text: 'Date'
            }
        },
        yAxis: {
            title: {
                text: 'No. of views'
            },
            min: 0
        },
        tooltip: {
            headerFormat: '<b>{series.name}</b><br>',
            pointFormat: '{point.x:%e. %b}: {point.y:.2f}'
        },
        series: [
            {
                name: 'Public Profile Views',
                data: public_profile_views_data
            }
        ]
    });
};

function load_insights_data_profileviews_companies(company_profile_views_data) {
    $("#insights-profileviews-company").highcharts({
        chart: {
            plotBackgroundColor: null,
            plotBorderWidth: null,
            plotShadow: false
        },
        title: {
            text: ''
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
            name: 'Company ',
            data: company_profile_views_data
        }]
    });
};

function load_insights_data_resume_contributions(resume_contributions_data) {
    Highcharts.getOptions().plotOptions.pie.colors = (function () {
        var colors = [],
            base = Highcharts.getOptions().colors[0],
            i

        for (i = 0; i < 10; i++) {
            // Start out with a darkened base color (negative brighten), and end
            // up with a much brighter color
            colors.push(Highcharts.Color(base).brighten((i - 3) / 7).get());
        }
        return colors;
    }());
    $("#insights-score-contributions").highcharts({
        chart: {
            plotBackgroundColor: null,
            plotBorderWidth: null,
            plotShadow: false
        },
        title: {
            text: 'Contributions to your Resume Score'
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
                },
                legend: {
                    labelFormatter: function() {
                        this.name.css("font-size", "1.1rem");
                    }                  
                }
            }
        },
        series: [{
            type: 'pie',
            name: 'Contribution ',
            data: resume_contributions_data
        }]
    });
};

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

$(function() {
    $('a[href*=#]:not([href=#])').click(function() {
        if (location.pathname.replace(/^\//,'') == this.pathname.replace(/^\//,'') && location.hostname == this.hostname) {
            var target = $(this.hash);
            target = target.length ? target : $('[name=' + this.hash.slice(1) +']');
            if (target.length) {
                $('html,body').animate({
                    scrollTop: target.offset().top
                }, 1000);
                return false;
            }
        }
    });
});

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