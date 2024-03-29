<%@ page defaultCodec="none" %>
<%@ page contentType="text/html;charset=UTF-8" %>
<!DOCTYPE html>
<html lang="en" xmlns="http://www.w3.org/1999/xhtml" xmlns:v="urn:schemas-microsoft-com:vml" xmlns:o="urn:schemas-microsoft-com:office:office">
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width">
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta name="x-apple-disable-message-reformatting">
    <title></title>
    <meta name="robots" content="noindex, follow">
</head>
<body width="100%" style="margin: 0; padding: 0 !important; mso-line-height-rule: exactly; background-color: #f1f1f1;">
    <p>
        This message was automatically generated by <g:message code="default.application.name"/>. Please do not reply to this message directly.
    </p>
    <p>
        This message is to notify that your <g:message code="institution.label"/> application has been submitted:
    </p>
    <table>
        <tr>
            <th>Name:</th>
            <td>${institutionName}</td>
        </tr>
        <tr>
            <th>Contact Name:</th>
            <td>${contactName}</td>
        </tr>
        <tr>
            <th>Contact Email:</th>
            <td>${contactEmail}</td>
        </tr>
        <tr>
            <th>Contact Phone:</th>
            <td>${contactPhone}</td>
        </tr>
    </table>
    <p>
        Thank you for submitting your application. The <g:message code="default.application.name"/> Admin team will
        review and respond if and when your application has been reviewed.
    </p>
    <p>
        If you have any further questions, you can email the <g:message code="default.application.name"/> Admin team
        <a href="mailto:${returnEmail}">here</a>.
    </p>
</body>
</html>



