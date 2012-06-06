<g:if test="${collectionEvents}">
<table id="results_table">
  <g:each in="${collectionEvents}" var="event" status="i">
    <g:set var="rowclass" value="${i % 2 == 0 ? 'even' : 'odd'}"/>
    <tr class="${rowclass}">

      <td><div id="collection_event_${i}" class="marker_details" lat="${event.latitude}" lng="${event.longitude}" locality="${event.locality}">${i+1}.</div></td>
      <td><b>${event.eventDate}</b></td>
      <td><b>${event.collector}</b></td>
      <td style="text-align: right">
        ${event.state}
        <g:if test="${event.state && event.country}">
          <span>, </span>
        </g:if>
        ${event.country}
      </td>
      <td style="vertical-align: middle;">
        <button class="select_event_button" eventId="${event.id}" title="Use all of the information from this collection event">Select&nbsp;event</button>
      </td>
    </tr>
    <tr class="${rowclass}">
      <td></td>
      <td colspan="2">${event.locality}</td>
      <td style="text-align: right">[${event.latitude}, ${event.longitude}]</td>
      <td style="vertical-align: middle;">
        <button class="select_location_button" eventId="${event.id}" title="Use just the locality information from this collection event">Select&nbsp;location</button>
      </td>

    </tr>
  </g:each>
</table>
</g:if>
<g:else>
  <span>There are no matching collection events.</span>
</g:else>

<script type="text/javascript">

  $(".select_event_button").click(function(e) {
    e.preventDefault();
    alert("Selected event!");
  });

  $(".select_location_button").click(function(e) {
    e.preventDefault();
    alert("Selected location!");
  });

  $(".marker_details").each(function(e) {

    var elementId = this.id

     if (event_map) {
        event_map.addMarker({
          lat: $(this).attr('lat'),
          lng: $(this).attr('lng'),
          title: $(this).attr('locality'),
          mouseover: function(e, y) {

            $('#' + elementId).parent().parent().css("background", "orange");
            $('#' + elementId).parent().parent().next().css("background", "orange");

            var container = $('#search_results');
            var scrollTo = $('#'+ elementId);
            container.scrollTop(
                scrollTo.offset().top - container.offset().top + container.scrollTop() - 20
            );

          },
          mouseout: function(e, y) {
            $('#' + elementId).parent().parent().css("background", "");
            $('#' + elementId).parent().parent().next().css("background", "");
          },
          click: function(e) {
//            alert('You clicked in this marker ' + elementId);
          }
        });

        event_map.fitZoom();
     }
  });

</script>

<style type="text/css">
  .select_event_button, .select_location_button {
    width: 100%;
  }
</style>