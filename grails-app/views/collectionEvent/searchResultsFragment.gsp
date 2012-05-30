<g:if test="${collectionEvents}">
<table>
  <g:each in="${collectionEvents}" var="event" status="i">
    <g:set var="rowclass" value="${i % 2 == 0 ? 'even' : 'odd'}"/>
    <tr class="${rowclass}">
      <td>${i+1}.</td>
      <td><b>${event.eventDate}</b></td>
      <td><b>${event.collector}</b></td>
      <td style="text-align: right">
        ${event.state}
        <g:if test="${event.state && event.country}">
          <span>, </span>
        </g:if>
        ${event.country}
      </td>
      <td rowspan="2" style="vertical-align: middle;"><button>Select</button></td>
    </tr>
    <tr class="${rowclass}">
      <td></td>
      <td colspan="2">${event.locality}</td>
      <td style="text-align: right">[${event.longitude}, ${event.latitude}]</td>
    </tr>
  </g:each>
</table>
</g:if>
<g:else>
  <span>There are no matching collection events.</span>
</g:else>