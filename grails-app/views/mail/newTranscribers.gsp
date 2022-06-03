<%@ page contentType="text/html"%>
<!DOCTYPE html>
<html lang="en" xmlns="http://www.w3.org/1999/xhtml" xmlns:v="urn:schemas-microsoft-com:vml" xmlns:o="urn:schemas-microsoft-com:office:office">
<head>
    <meta charset="utf-8"> <!-- utf-8 works for most cases -->
    <meta name="viewport" content="width=device-width"> <!-- Forcing initial-scale shouldn't be necessary -->
    <meta http-equiv="X-UA-Compatible" content="IE=edge"> <!-- Use the latest (edge) version of IE rendering engine -->
    <meta name="x-apple-disable-message-reformatting">  <!-- Disable auto-scale in iOS 10 Mail entirely -->
    <meta name="format-detection" content="telephone=no,address=no,email=no,date=no,url=no"> <!-- Tell iOS not to automatically link certain text strings. -->
    <title>New Transcribers</title>

    <!-- CSS Reset : BEGIN -->
    <style>

    /* What it does: Remove spaces around the email design added by some email clients. */
    /* Beware: It can remove the padding / margin and add a background color to the compose a reply window. */
    html,
    body {
        margin: 0 !important;
        padding: 0 !important;
        height: 100% !important;
        width: 100% !important;
    }

    /* What it does: Stops email clients resizing small text. */
    * {
        -ms-text-size-adjust: 100%;
        -webkit-text-size-adjust: 100%;
    }

    /* What it does: Centers email on Android 4.4 */
    div[style*="margin: 16px 0"] {
        margin: 0 !important;
    }

    /* What it does: Stops Outlook from adding extra spacing to tables. */
    table,
    td {
        mso-table-lspace: 0pt !important;
        mso-table-rspace: 0pt !important;
    }

    /* What it does: Fixes webkit padding issue. */
    table {
        border-spacing: 0 !important;
        border-collapse: collapse !important;
        table-layout: fixed !important;
        margin: 0 auto !important;
    }

    /* What it does: Uses a better rendering method when resizing images in IE. */
    img {
        -ms-interpolation-mode:bicubic;
    }

    /* What it does: Prevents Windows 10 Mail from underlining links despite inline CSS. Styles for underlined links should be inline. */
    a {
        text-decoration: none;
    }

    /* What it does: A work-around for email clients meddling in triggered links. */
    a[x-apple-data-detectors],  /* iOS */
    .unstyle-auto-detected-links a,
    .aBn {
        border-bottom: 0 !important;
        cursor: default !important;
        color: inherit !important;
        text-decoration: none !important;
        font-size: inherit !important;
        font-family: inherit !important;
        font-weight: inherit !important;
        line-height: inherit !important;
    }

    /* What it does: Prevents Gmail from displaying a download button on large, non-linked images. */
    .a6S {
        display: none !important;
        opacity: 0.01 !important;
    }

    /* What it does: Prevents Gmail from changing the text color in conversation threads. */
    .im {
        color: inherit !important;
    }

    /* If the above doesn't work, add a .g-img class to any image in question. */
    img.g-img + div {
        display: none !important;
    }

    /* What it does: Removes right gutter in Gmail iOS app: https://github.com/TedGoas/Cerberus/issues/89  */
    /* Create one of these media queries for each additional viewport size you'd like to fix */

    /* iPhone 4, 4S, 5, 5S, 5C, and 5SE */
    @media only screen and (min-device-width: 320px) and (max-device-width: 374px) {
        u ~ div .email-container {
            min-width: 320px !important;
        }
    }
    /* iPhone 6, 6S, 7, 8, and X */
    @media only screen and (min-device-width: 375px) and (max-device-width: 413px) {
        u ~ div .email-container {
            min-width: 375px !important;
        }
    }
    /* iPhone 6+, 7+, and 8+ */
    @media only screen and (min-device-width: 414px) {
        u ~ div .email-container {
            min-width: 414px !important;
        }
    }

    </style>

    <!-- Progressive Enhancements : BEGIN -->
    <style>

    /* What it does: Hover styles for buttons */
    .button-td,
    .button-a {
        transition: all 100ms ease-in;
    }
    .button-td-primary:hover,
    .button-a-primary:hover {
        background: #555555 !important;
        border-color: #555555 !important;
    }

    /* Media Queries */
    @media screen and (max-width: 600px) {

        /* What it does: Adjust typography on small screens to improve readability */
        .email-container p {
            font-size: 15px !important;
        }

    }

    </style>
    <!-- Progressive Enhancements : END -->
</head>

<body width="100%" style="margin: 0; padding: 0 !important; mso-line-height-rule: exactly; background-color: #ffffff;">
    <div style="width: 600px; max-width: 600px; margin: 0; text-align: left" class="email-container">
        <table align="left" role="presentation" cellspacing="0" cellpadding="0" border="0" width="600px" style="margin: auto;">
            <tr>
                <td style="padding: 10px 0;">
                    This message was automatically generated by <g:message code="default.application.name"/>. Please do not reply to this message directly.
                </td>
            </tr>
            <tr>
                <td style="padding: 10px 0;">
                    New User Digest: Users registered to DigiVol in the last ${threshold} day(s):
                </td>
            </tr>
            <tr>
                <td style="padding: 5px 0;">
                    <table role="presentation" cellspacing="0" cellpadding="0" border="0" width="600px">
                        <tr>
                            <th style="padding: 10px; font-family: sans-serif; font-size: 12px; line-height: 13px; color: #555555;">Name</th>
                            <th style="padding: 10px; font-family: sans-serif; font-size: 12px; line-height: 13px; color: #555555;">Date Registered</th>
                            <th style="padding: 10px; font-family: sans-serif; font-size: 12px; line-height: 13px; color: #555555;">No. Transcriptions</th>
                        </tr>
                        <g:each in="${newTranscribers}" var="newUser">
                        <tr>
                            <td style="padding: 10px; font-family: sans-serif; font-size: 12px; color: #555555;">
                                <g:link absolute="true" controller="user" action="show" id="${newUser.user.id}">${newUser.user.displayName}</g:link>
                            </td>
                            <td style="padding: 10px; font-family: sans-serif; font-size: 12px; color: #555555; text-align: center">
                                <g:formatDate format="yyyy-MM-dd HH:mm" date="${newUser.user.created}"/>
                            </td>
                            <td style="padding: 10px; font-family: sans-serif; font-size: 12px; color: #555555; text-align: right">
                                ${newUser.transcribeCount}
                            </td>
                        </tr>
                        </g:each>
                    </table>
                </td>
            </tr>
        </table>
    </div>
</body>
</html>