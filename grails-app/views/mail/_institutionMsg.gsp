
<tr>
    <td style="padding: 20px; font-family: sans-serif; font-size: 15px; line-height: 20px; color: #555555;">
        <h1 style="margin: 0 0 10px 0; font-family: sans-serif; font-size: 25px; line-height: 30px; color: #333333; font-weight: normal;">A message from ${institutionName}.</h1>
        <p style="margin: 0;">
            <%=messageBody%>
        </p>
    </td>
</tr>
<tr>
    <td style="padding-top: 10px; padding-bottom: 10px; font-family: sans-serif; font-size: 14px; line-height: 15px; text-align: center; color: #888888;">
        <!-- Sender information : BEGIN -->
        This communication has been sent by ${senderName}, representative of ${institutionName}, the views and opinions
        of whom do not represent those of the Australian Museum or the Atlas of Living Australia.
        <br><br>
        <g:if test="${institutionIncludeContact}">
            You can reply to this email to contact ${institutionContactName}, ${institutionName}.<br>
        </g:if>
        <g:else>
            This email was sent by the DigiVol System. Please do not reply to this email.
        </g:else>
        <br>
        If you do not want to receive these communications, please opt out using the link below.
        <br><br>
        <!-- Sender information : END -->
    </td>
</tr>