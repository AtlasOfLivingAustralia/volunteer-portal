<tr>
    <td style="padding: 20px; font-family: sans-serif; font-size: 15px; line-height: 20px; color: #555555;">
        <h1 style="margin: 0 0 10px 0; font-family: sans-serif; font-size: 25px; line-height: 30px; color: #333333; font-weight: normal;"><%=subject%>></h1>
        <p style="margin: 0;">
            <%=raw(messageBody.encodeAsHTML().replace("\n", "<br>"))%>
        </p>
    </td>
</tr>