<<%@ page contentType="text/html;charset=UTF-8"  %>
<!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/html">
  <head>
      <title>Volunteer Portal - Atlas of Living Australia</title>
      <meta name="layout" content="${grailsApplication.config.ala.skin}"/>
      <link rel="stylesheet" href="${resource(dir:'css',file:'vp.css')}" />
      <script type="text/javascript" src="https://www.google.com/jsapi"></script>

      <script type="text/javascript">
    // Load the Visualization API and the piechart package.
          google.load('visualization', '1.0', {'packages':['corechart']});

        $(document).ready(function(e) {
          $("#btnTranscriptionsByMonth").click(function(e) {
            $.ajax("${createLink(controller:'ajax', action:'statsTranscriptionsByMonth')}").done(function(data) {
              // Create the data table.
              var table = new google.visualization.DataTable();
              table.addColumn('string', 'Month');
              table.addColumn('number', 'Transcriptions');
              for (key in data) {
                var value = data[key]
                table.addRow([value.month, value.count])
              }

              // Set chart options
              var options = {
                  'title':'Transcriptions by month',
                  width:972, height:400,
                  backgroundColor: '#F5F2E3',
                  vAxis: {title: "Transcriptions"},
                  hAxis: {title: "Month"}
              };

              // Instantiate and draw our chart, passing in some options.
              var chart = new google.visualization.ColumnChart(document.getElementById('chart_div')).draw(table, options);

            })

          });
        });

      </script>

  </head>
  <body class="sublevel sub-site volunteerportal">

    <cl:navbar selected="" />

    <header id="page-header">
      <div class="inner">
        <cl:messages />
        <nav id="breadcrumb">
          <ol>
            <li><a href="${createLink(uri: '/')}"><g:message code="default.home.label"/></a></li>
            <li class="last"><g:message code="default.stats.label" default="Stats" /></li>
          </ol>
        </nav>
        <h1>Volunteer Portal Statistics</h1>
      </div>
    </header>
    <div>
      <div class="inner">
        <button id="btnTranscriptionsByMonth">Transcriptions by month</button>
        <div id="chart_div" style="margin-top: 10px;"></div>
    </div>
  </body>
</html>