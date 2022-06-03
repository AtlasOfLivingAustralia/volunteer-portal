<!DOCTYPE html>
<html lang="en" xmlns="http://www.w3.org/1999/xhtml" xmlns:v="urn:schemas-microsoft-com:vml" xmlns:o="urn:schemas-microsoft-com:office:office">
<head>
    <meta charset="utf-8"> <!-- utf-8 works for most cases -->
    <meta name="viewport" content="width=device-width"> <!-- Forcing initial-scale shouldn't be necessary -->
    <meta http-equiv="X-UA-Compatible" content="IE=edge"> <!-- Use the latest (edge) version of IE rendering engine -->
    <meta name="x-apple-disable-message-reformatting">  <!-- Disable auto-scale in iOS 10 Mail entirely -->
    <meta name="format-detection" content="telephone=no,address=no,email=no,date=no,url=no"> <!-- Tell iOS not to automatically link certain text strings. -->
    <title>DigiVol - ${subject}</title> <!-- The title tag shows in email notifications, like Android 4.4. -->

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

    <!-- What it does: Makes background images in 72ppi Outlook render at correct size. -->
    <!--[if gte mso 9]>
    <xml>
        <o:OfficeDocumentSettings>
        <o:AllowPNG/>
        <o:PixelsPerInch>96</o:PixelsPerInch>
    </o:OfficeDocumentSettings>
    </xml>
    <![endif]-->

    <!-- CSS Reset : END -->

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
<!--
	The email background color (#222222) is defined in three places:
	1. body tag: for most email clients
	2. center tag: for Gmail and Inbox mobile apps and web versions of Gmail, GSuite, Inbox, Yahoo, AOL, Libero, Comcast, freenet, Mail.ru, Orange.fr
	3. mso conditional: For Windows 10 Mail
-->
<body width="100%" style="margin: 0; padding: 0 !important; mso-line-height-rule: exactly; background-color: #ffffff;">
<center style="width: 100%; background-color: #ffffff;">
    <!--[if mso | IE]>
    <table role="presentation" border="0" cellpadding="0" cellspacing="0" width="100%" style="background-color: #ffffff;">
    <tr>
    <td>
    <![endif]-->

    <!-- Visually Hidden Preheader Text : BEGIN -->
    <div style="display: none; font-size: 1px; line-height: 1px; max-height: 0px; max-width: 0px; opacity: 0; overflow: hidden; mso-hide: all; font-family: sans-serif;">
        ${inboxPreview}
    </div>
    <!-- Visually Hidden Preheader Text : END -->

    <!-- Create white space after the desired preview text so email clients don’t pull other distracting text into the inbox preview. Extend as necessary. -->
    <!-- Preview Text Spacing Hack : BEGIN -->
    <div style="display: none; font-size: 1px; line-height: 1px; max-height: 0px; max-width: 0px; opacity: 0; overflow: hidden; mso-hide: all; font-family: sans-serif;">
        &zwnj;&nbsp;&zwnj;&nbsp;&zwnj;&nbsp;&zwnj;&nbsp;&zwnj;&nbsp;&zwnj;&nbsp;&zwnj;&nbsp;&zwnj;&nbsp;&zwnj;&nbsp;&zwnj;&nbsp;&zwnj;&nbsp;&zwnj;&nbsp;&zwnj;&nbsp;&zwnj;&nbsp;&zwnj;&nbsp;&zwnj;&nbsp;&zwnj;&nbsp;&zwnj;&nbsp;
    </div>
    <!-- Preview Text Spacing Hack : END -->

    <!--
            Set the email width. Defined in two places:
            1. max-width for all clients except Desktop Windows Outlook, allowing the email to squish on narrow but never go wider than 600px.
            2. MSO tags for Desktop Windows Outlook enforce a 600px width.
        -->
    <div style="max-width: 800px; margin: 0 auto;" class="email-container">
        <!--[if mso]>
            <table align="center" role="presentation" cellspacing="0" cellpadding="0" border="0" width="800">
            <tr>
            <td>
            <![endif]-->

        <!-- Email Body : BEGIN -->
        <table align="center" role="presentation" cellspacing="0" cellpadding="0" border="0" width="100%" style="margin: auto;">

            <!-- Email Header : BEGIN -->
            <tr>
                <td style="padding: 20px 0; text-align: center">
                    <img src="${serverUrl}/assets/digivol-logo-email.png" width="400" alt="DigiVol" border="0" style="height: auto; background: #dddddd; font-family: sans-serif; font-size: 15px; line-height: 15px; color: #555555;">
                </td>
            </tr>
            <!-- Email Header : END -->

            <!-- 1 Column Text + Button : BEGIN -->
            <tr>
                <td style="background-color: #ffffff;">
                    <table role="presentation" cellspacing="0" cellpadding="0" border="0" width="100%">
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
                                This communication has been sent by ${senderName}, representative of ${institutionName}, the views and opinions of whom do not represent those of the Australian Museum or the Atlas of Living Australia.
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
                        <tr>
                            <td style="padding: 0 20px;">
                                <!-- Button : BEGIN -->
                                <table align="center" role="presentation" cellspacing="0" cellpadding="0" border="0" style="margin: auto;">
                                    <tr>
                                        <td class="button-td button-td-primary" style="border-radius: 4px; background: #222222;">
                                            <g:link controller="institution" action="index" id="${institutionId}"
                                                    absolute="true"
                                                    class="button-a button-a-primary"
                                                    style="background: #222222; border: 1px solid #000000; font-family: sans-serif; font-size: 15px; line-height: 15px; text-decoration: none; padding: 13px 17px; color: #ffffff; display: block; border-radius: 4px;">
                                                Visit DigiVol</g:link>
                                        </td>
                                    </tr>
                                </table>
                                <!-- Button : END -->
                            </td>
                        </tr>
                    </table>
                </td>
            </tr>
            <!-- 1 Column Text + Button : END -->

        </table>
        <!-- Email Body : END -->

        <!-- Email Footer : BEGIN -->
        <table align="center" role="presentation" cellspacing="0" cellpadding="0" border="0" width="100%" style="margin: auto;">
            <tr>
                <td style="padding: 20px; font-family: sans-serif; font-size: 12px; line-height: 15px; text-align: center; color: #888888;">
                    <div style="border-bottom:#ccc solid 2px">
                        <img bprder="0" height="1" src="spacer.gif" style="display:block;" width="1">
                    </div>
                </td>
            </tr>
            <tr>
                <td style="padding: 5px; font-family: sans-serif; font-size: 12px; line-height: 15px; color: #888888;">
                    <table role="presentation" cellspacing="0" cellpadding="0" border="0" style="margin: auto;">
                        <tr>
                            <td style="padding:10px 10px 10px 10px;" valign="top">
                                <div align="center">
                                    <img alt border="0" height="34" src="${serverUrl}/assets/digivol-logo-email.png" style="display:block" width="120">
                                </div>
                            </td>
                            <td style="padding:10px 10px 10px 10px;">
                                <div style="display:block; margin-bottom:10px;">
                                    DigiVol is a crowdsourced digitisation platform developed and operated by the
                                    Australian Museum in collaboration with the Atlas of Living Australia.
                                </div>
                            </td>
                        </tr>
                    </table>
                </td>
            </tr>
            <tr>
                <td style="padding: 5px; font-family: sans-serif; font-size: 12px; line-height: 15px; color: #888888;">
                    <table role="presentation" cellspacing="0" cellpadding="0" border="0" style="margin: auto;">
                        <tr>
                            <td style="padding:10px 10px 10px 10px;" valign="top">
                                <div align="center">
                                    <img alt border="0" height="70" src="${serverUrl}/assets/AM_RGB_logo.png" style="display:block" width="120">
                                </div>
                            </td>
                            <td style="padding:10px 10px 10px 10px;">
                                <div style="display:block; margin-bottom:10px;">
                                    For more than 190 years, the Australian Museum (AM) has been at the forefront of Australian
                                    scientific research, collection and education. The AM is a dynamic source of reliable
                                    scientific information and a touchstone for informed debate about some of the most pressing
                                    environmental and social challenges facing our region: the loss of biodiversity, a changing
                                    climate, and the search for cultural identity.
                                </div>
                            </td>
                        </tr>
                    </table>
                </td>
            </tr>
            <tr>
                <td style="padding: 5px; font-family: sans-serif; font-size: 12px; line-height: 15px; color: #888888;">
                    <table role="presentation" cellspacing="0" cellpadding="0" border="0" style="margin: auto;">
                        <tr>
                            <td style="padding:10px 10px 10px 10px;" valign="top">
                                <div align="center">
                                    <img alt border="0" height="52" src="${serverUrl}/assets/ala-logo.jpg" style="display:block" width="120">
                                </div>
                            </td>
                            <td style="padding:10px 10px 10px 10px;">
                                <div style="display:block; margin-bottom:10px;">
                                    The Atlas of Living Australia is a collaborative, digital, open infrastructure that
                                    pulls together Australian biodiversity data from multiple sources, making it accessible
                                    and reusable.
                                </div>
                            </td>
                        </tr>
                    </table>
                </td>
            </tr>
            <tr>
                <td style="padding: 5px; font-family: sans-serif; font-size: 12px; line-height: 15px; color: #888888;">
                    <table role="presentation" cellspacing="0" cellpadding="0" border="0" style="margin: auto;">
                        <tr>
                            <td style="padding:10px 10px 10px 10px;" valign="top">
                                <div align="center">
                                    <img alt border="0" height="53" src="${serverUrl}/assets/ncris-logo.png" style="display:block" width="120">
                                </div>
                            </td>
                            <td style="padding:0px 10px 10px 10px;">
                                <div style="display:block; margin-bottom:10px;margin-top:7px;">
                                    The Atlas of Living Australia is made possible by contributions from its many partners. It receives support through the Australian Government's National Collaborative Research Infrastructure Strategy (NCRIS) and is hosted by CSIRO.
                                </div>

                            </td>
                        </tr>
                    </table>
                </td>
            </tr>
            <tr>
                <td style="padding: 20px; font-family: sans-serif; font-size: 12px; line-height: 15px; text-align: center; color: #888888;">
                    <div style="border-bottom:#ccc solid 2px">
                        <img bprder="0" height="1" src="spacer.gif" style="display:block;" width="1">
                    </div>
                </td>
            </tr>

            <tr>
                <td style="padding-top: 10px; padding-bottom: 10px; font-family: sans-serif; font-size: 12px; line-height: 15px; text-align: left; color: #888888;">
                    <p style="margin: 10px;">The Atlas of Living Australia acknowledges Australia’s Traditional Owners and pays respect to the past and present Elders of the nation’s Aboriginal and Torres Strait Islander communities. We honour and celebrate the spiritual, cultural and customary connections of Traditional Owners to country and the biodiversity that forms part of that country.</p>
                </td>
            </tr>


        </table>
        <!-- Email Footer : END -->

        <!--[if mso]>
            </td>
            </tr>
            </table>
            <![endif]-->
    </div>

    <!-- Full Bleed Background Section : BEGIN -->
    <table role="presentation" cellspacing="0" cellpadding="0" border="0" width="100%" style="background-color: #d5502a;">
        <tr>
            <td>
                <div align="center" style="max-width: 600px; margin: auto;" class="email-container">
                    <!--[if mso]>
                        <table role="presentation" cellspacing="0" cellpadding="0" border="0" width="600" align="center">
                        <tr>
                        <td>
                        <![endif]-->
                    <table role="presentation" cellspacing="0" cellpadding="0" border="0" width="100%">
                        <tr>
                            <td style="padding: 20px; text-align: center; font-family: sans-serif; font-size: 12px; line-height: 20px; color: #ffffff;">
                                <img src="${serverUrl}/assets/cc-license-image.png" width="88" height="32" alt border="0"><br>
                                This content is licensed under a <strong>Creative Commons Attribution 3.0 Australia License</strong>.
                            </td>
                        </tr>
                        <tr>
                            <td style="padding: 10px; text-align: center; font-family: sans-serif; font-size: 11px; line-height: 20px; color: #bbbbbb;">
                                <p style="margin: 0;">
                                    This email was sent to ${recipientEmail}<br>
                                    <g:link controller="institutionMessage" action="optOut" absolute="true" params="${[id: recipient_id, refKey: refKey]}">
                                        Opt-out of institution communications
                                    </g:link>
                                </p>
                            </td>
                        </tr>
                    </table>
                    <!--[if mso]>
                        </td>
                        </tr>
                        </table>
                        <![endif]-->
                </div>
            </td>
        </tr>
    </table>
    <!-- Full Bleed Background Section : END -->

    <!--[if mso | IE]>
    </td>
    </tr>
    </table>
    <![endif]-->
</center>
</body>
</html>