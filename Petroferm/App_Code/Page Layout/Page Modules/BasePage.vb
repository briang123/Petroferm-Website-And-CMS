Imports Microsoft.VisualBasic

Public MustInherit Class BasePage
    Inherits System.Web.UI.Page

    Public IsPetrofermHomePage As Boolean = False
    Public IsBusinessHomePage As Boolean = False
    Public IsMarketHomePage As Boolean = False
    Public IsGeneralPage As Boolean = False
    Public IsProductPage As Boolean = False
    Public IsPassthroughPage As Boolean = False
    Public IsSearchPage As Boolean = False
    Public IsDocumentPage As Boolean = False
    Public IsSendInfoToPetrofermPage As Boolean = False
    Public CurrentPage As WebPage
    Public StyleObjects As New StringBuilder

    MustOverride Function BuildTopMenu(ByVal currentPage As WebPage) As Control
    MustOverride Function BuildHeaderRegion(ByVal currentPage As WebPage) As String
    MustOverride Function BuildBodyRegion(ByVal currentPage As WebPage) As Control


    Public ReadOnly Property CurrentPageId() As Integer
        Get
            Return CType(Request.QueryString("PageId"), Integer)
        End Get
    End Property

    Private Sub Page_LoadComplete(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.LoadComplete

        IsSearchPage = Me.Request.ServerVariables("PATH_INFO").ToString.ToUpper.IndexOf("SEARCH") > -1
        IsSendInfoToPetrofermPage = Me.Request.ServerVariables("PATH_INFO").ToString.ToUpper.IndexOf("CONTACT") > -1

        Select Case True
            Case IsSearchPage = False, IsSendInfoToPetrofermPage = False

                If Me.CurrentPageId <> 0 Then

                    currentPage = New WebPage(Me.CurrentPageId, WorkflowItem.LiveMode.Live)

                    If Date.Today >= currentPage.PublishDate And Date.Today <= currentPage.ExpireDate Then

                        Master.Page.Title = currentPage.PageTitle
                        Master.Page.Header.Controls.AddAt(0, BuildMetaTag("description", currentPage.MetaDescription))
                        Master.Page.Header.Controls.AddAt(0, BuildMetaTag("keywords", currentPage.MetaKeywords))

                        IsPetrofermHomePage = (currentPage.PageId = 1)
                        IsBusinessHomePage = (Services.GetNULLableString(currentPage.PageType).ToUpper = "BUSINESS HOME")
                        IsMarketHomePage = (Services.GetNULLableString(currentPage.PageType).ToUpper = "MARKET HOME")
                        IsGeneralPage = (Services.GetNULLableString(currentPage.PageType).ToUpper.StartsWith("GENERAL CONTENT") = True)
                        IsProductPage = (Services.GetNULLableString(currentPage.PageType).ToUpper.StartsWith("PRODUCT") = True)
                        IsPassthroughPage = (Services.GetNULLableString(currentPage.PageType).ToUpper = "PASSTHROUGH")
                        IsDocumentPage = (Services.GetNULLableString(currentPage.PageType).ToUpper = "DOCUMENT")
                    Else
                        'Response.Redirect("~/404.htm")
                    End If

                Else
                    'Response.Redirect("~/business.aspx?pageid=10")
                End If

        End Select

        'If IsSearchPage = False Then 'Or IsSendInfoToPetrofermPage = False Then

        '    If Me.CurrentPageId <> 0 Then

        '        currentPage = New WebPage(Me.CurrentPageId, WorkflowItem.LiveMode.Live)

        '        If Date.Today >= currentPage.PublishDate And Date.Today <= currentPage.ExpireDate Then

        '            Master.Page.Title = currentPage.PageTitle
        '            Master.Page.Header.Controls.AddAt(0, BuildMetaTag("description", currentPage.MetaDescription))
        '            Master.Page.Header.Controls.AddAt(0, BuildMetaTag("keywords", currentPage.MetaKeywords))

        '            IsPetrofermHomePage = (currentPage.PageId = 1)
        '            IsBusinessHomePage = (Services.GetNULLableString(currentPage.PageType).ToUpper = "BUSINESS HOME")
        '            IsMarketHomePage = (Services.GetNULLableString(currentPage.PageType).ToUpper = "MARKET HOME")
        '            IsGeneralPage = (Services.GetNULLableString(currentPage.PageType).ToUpper.StartsWith("GENERAL CONTENT") = True)
        '            IsProductPage = (Services.GetNULLableString(currentPage.PageType).ToUpper.StartsWith("PRODUCT") = True)
        '            IsPassthroughPage = (Services.GetNULLableString(currentPage.PageType).ToUpper = "PASSTHROUGH")
        '            IsDocumentPage = (Services.GetNULLableString(currentPage.PageType).ToUpper = "DOCUMENT")
        '        Else
        '            Response.Redirect("~/404.htm")
        '        End If

        '    Else
        '        Response.Redirect("~/business.aspx?pageid=10")
        '    End If

        'End If


    End Sub


#Region " HELPER PAGE FUNCTIONS "

    Public Function BuildMetaTag(ByVal tag As String, ByVal value As String) As HtmlMeta
        Dim meta As New HtmlMeta
        meta.Name = tag
        meta.Content = value
        Return meta
    End Function

    Public Function BuildCopyright() As String
        Return "&copy;&nbsp;Copyright 2004 - " + Today.Year.ToString + ", All rights reserved"
    End Function

    Public Function BuildHtmlImage(ByVal src As String, ByVal altText As String, ByVal width As Integer, ByVal height As Integer, ByVal align As String) As HtmlImage
        Dim genericImage As New HtmlImage
        With GenericImage
            .Src = src
            .Alt = AltText
            .Align = align
            .Border = 0
        End With
        Return GenericImage
    End Function

    Public Function BuildHtmlImage(ByVal image As ImageFile) As HtmlImage
        Dim genericImage As New HtmlImage
        With GenericImage
            .Src = image.ImagePath
            .Alt = image.AltText
            .Align = "left"
            .Border = 0
        End With
        Return GenericImage
    End Function

    Public Function CompressStringForJavaScript(ByVal value As String) As String
        Dim temp As String = value
        Dim chars() As String = {".", ",", " ", "-", "/", "&", "!", "'"}
        For i As Integer = 0 To chars.Length - 1
            temp = temp.Replace(chars.GetValue(i).ToString, "")
        Next
        Return temp
    End Function

    Function GetImageSource(ByVal imageType As String, ByVal currentMarket As Market) As String

        Dim imagePath As String = String.Empty
        Select Case ImageType.ToUpper
            Case "NAVIGATION ON", "NAVIGATION OFF", "NAV ON IMAGE", "NAV OFF IMAGE"
                If currentMarket.TopMenuNavigationRegion.Count > 0 Then
                    For i As Integer = 1 To currentMarket.TopMenuNavigationRegion.Count
                        If currentMarket IsNot Nothing Then
                            Dim imageMod As ImageModule = TryCast(currentMarket.TopMenuNavigationRegion.Item(i), ImageModule)
                            If imageMod IsNot Nothing Then
                                If imageMod.ModuleType.ToUpper = ImageType.ToUpper Or imageMod.ImageType.ToUpper = ImageType.ToUpper Then
                                    imagePath = imageMod.ImageFile.ImagePath
                                    Exit For
                                End If
                            End If
                        End If
                    Next
                End If
            Case "HEADER", "HEADER IMAGE"
                If currentMarket.HeaderImageRegion.Count > 0 Then
                    'TODO: Need to render a random image (see existing rules)
                    'Dim randCeiling As Integer = currentMarket.HeaderImageRegion.Count
                    'Dim rnd As New Random(1)
                    'Dim randomNum As Integer = rnd.Next(randCeiling)
                    For i As Integer = 1 To currentMarket.HeaderImageRegion.Count
                        If currentMarket IsNot Nothing Then
                            Dim imageMod As ImageModule = TryCast(currentMarket.HeaderImageRegion.Item(i), ImageModule)
                            If imageMod IsNot Nothing Then
                                imagePath = imageMod.ImageFile.ImagePath
                                Exit For
                            End If
                        End If
                    Next
                End If
        End Select

        Return imagePath
    End Function


    ''' <summary>
    ''' This is for handling the Petroferm home page
    ''' </summary>
    ''' <param name="ImageType"></param>
    ''' <param name="currBusUnit"></param>
    ''' <returns></returns>
    ''' <remarks>Added for task #28, kr, 12/26/06</remarks>
    Function GetImageSource(ByVal imageType As String, ByVal welcomeImageId As Integer, ByVal currBusUnit As BusinessUnit) As String

        Dim imagePath As String = String.Empty
        Select Case imageType.ToUpper
            Case "NAVIGATION ON", "NAVIGATION OFF", "NAV ON IMAGE", "NAV OFF IMAGE"
                If currBusUnit.TopMenuNavigationRegion.Count > 0 Then
                    For i As Integer = 0 To currBusUnit.TopMenuNavigationRegion.Count - 1
                        If currBusUnit IsNot Nothing Then
                            Dim imageMod As ImageModule = TryCast(currBusUnit.TopMenuNavigationRegion.Item(i), ImageModule)
                            If imageMod IsNot Nothing Then
                                If imageMod.ImageType = imageType And imageMod.WelcomeImageID = welcomeImageID Then ' imageMod.WelcomeTitle.ToUpper = welcomeTitle.ToUpper Then
                                    imagePath = imageMod.ImageFile.ImagePath
                                    Exit For
                                End If
                            End If
                        End If
                    Next
                End If
            Case "HEADER", "HEADER IMAGE"
                If currBusUnit.HeaderImageRegion.Count > 0 Then
                    'TODO: Need to render a random image (see existing rules)
                    'Dim randCeiling As Integer = currentMarket.HeaderImageRegion.Count
                    'Dim rnd As New Random(1)
                    'Dim randomNum As Integer = rnd.Next(randCeiling)
                    For i As Integer = 1 To currBusUnit.HeaderImageRegion.Count
                        If currBusUnit IsNot Nothing Then
                            Dim imageMod As ImageModule = TryCast(currBusUnit.HeaderImageRegion.Item(i), ImageModule)
                            If imageMod IsNot Nothing Then
                                imagePath = imageMod.ImageFile.ImagePath
                                Exit For
                            End If
                        End If
                    Next
                End If
        End Select

        Return imagePath
    End Function

    Public Function BuildTopMenuOfMarkets(ByVal currentPage As WebPage) As Control

        Dim ctl As New Control



        Select Case True
            Case (currentPage.BusUnit.BusUnitID = 1)
                Dim referringPage As New WebPage(currentPage.BusUnit.BusUnitID, WorkflowItem.LiveMode.Live)

                ' will grab nav on/nav off image modules in lieu of markets
                For i As Integer = 0 To currentPage.BusUnit.TopMenuNavigationRegion.Count - 1
                    Dim imageMod As ImageModule = TryCast(currentPage.BusUnit.TopMenuNavigationRegion.Item(i), ImageModule)
                    If imageMod IsNot Nothing Then
                        If imageMod.ImageType.ToUpper = "NAVIGATION OFF" Then
                            Dim topNavImageContainer As New LiteralControl
                            Dim navTopMenuLink As New StringBuilder
                            Dim onmouseover As String = String.Empty
                            Dim onmouseout As String = String.Empty
                            Dim imageOnSrc As String = GetImageSource("NAVIGATION ON", imageMod.WelcomeImageID, referringPage.BusUnit)
                            Dim imageClientId As String = CompressStringForJavaScript(imageMod.WelcomeTitle)

                            TopNavImageContainer.Text = "<img src=""" + imageMod.ImageFile.ImagePath + """ name=""" + ImageClientId + """ alt=""" + imageMod.ImageFile.AltText + """ border=""0"">"
                            onmouseover = "MM_swapImage('" + ImageClientId + "','','" + imageOnSrc + "',0);"
                            onmouseout = "MM_swapImgRestore();"

                            NavTopMenuLink.AppendFormat("<a href=""{0}"" onmouseover=""{1}"" onmouseout=""{2}"">{3}</a>{4}", _
                                    imageMod.WelcomeLinkPageFriendlyURL, _
                                    onmouseover, onmouseout, TopNavImageContainer.Text, _
                                    "<img src=""web/files/images/misc/nav_spacer.gif"" alt=""Petroferm Inc."" border=""0"" width=""1"" height=""44"">")

                            ctl.Controls.Add(New LiteralControl(NavTopMenuLink.ToString))
                        End If
                    End If
                Next
            Case (currentPage.CurrentMarket.MarketID > 0 Or currentPage.BusUnit.BusUnitID > 1)



                For i As Integer = 1 To currentPage.BusUnit.Markets.Count
                    Dim market As Market = TryCast(currentPage.BusUnit.Markets.Item(i), Market)
                    If market IsNot Nothing Then
                        Dim imageMod As ImageModule = TryCast(market.TopMenuNavigationRegion.Item(0), ImageModule)
                        If imageMod IsNot Nothing Then
                            If imageMod.ImageType.ToUpper = "NAVIGATION OFF" Then

                                Dim topNavImageContainer As New LiteralControl
                                Dim doSelectCurrentMarket As Boolean = False
                                Dim navTopMenuLink As New StringBuilder
                                Dim onmouseover As String = String.Empty
                                Dim onmouseout As String = String.Empty


                                Dim imageOnSrc As String = GetImageSource("NAVIGATION ON", market)
                                Dim imageClientId As String = CompressStringForJavaScript(market.MarketName)
                                TopNavImageContainer.Text = "<img src=""" + imageMod.ImageFile.ImagePath + """ name=""" + ImageClientId + """ alt=""" + imageMod.ImageFile.AltText + """ border=""0"">"

                                If market.MarketID <> 0 Then
                                    If market.MarketID <> currentPage.CurrentMarket.MarketID Then
                                        StyleObjects.Append("#homepage" + ImageClientId + "Welcome {position:absolute;visibility:hidden;z-index:100;top:0px;left:0px;} " + vbCrLf)
                                        onmouseover = "MM_swapImage('" + ImageClientId + "','','" + imageOnSrc + "',0);toggleWelcomeSections('homepage" + ImageClientId + "Welcome');"
                                        onmouseout = "MM_swapImgRestore();toggleWelcomeSections('homepage" + ImageClientId + "Welcome');"
                                    Else
                                        TopNavImageContainer.Text = "<img src=""" + imageOnSrc + """ name=""" + ImageClientId + """ alt=""" + imageMod.ImageFile.AltText + """ border=""0"">"
                                    End If
                                Else
                                    onmouseover = "MM_swapImage('" + ImageClientId + "','','" + imageOnSrc + "',0);"
                                    onmouseout = "MM_swapImgRestore();"
                                End If

                                NavTopMenuLink.AppendFormat("<a href=""{0}"" onmouseover=""{1}"" onmouseout=""{2}"">{3}</a>{4}", _
                                        LinkGenerator.BuildTopNavMenuLinks(currentPage.BusUnit.BusUnitID, market.MarketID), _
                                        onmouseover, onmouseout, TopNavImageContainer.Text, _
                                        "<img src=""web/files/images/misc/nav_spacer.gif"" alt=""Petroferm Inc."" border=""0"" width=""1"" height=""44"">")

                                ctl.Controls.Add(New LiteralControl(NavTopMenuLink.ToString))
                            End If
                        End If
                    End If
                Next
        End Select

        Return ctl

    End Function

#End Region

    Public Function FullSubPageContainer(ByVal bodyContent As String, ByVal termsSrc As String) As String

        Dim sb As New StringBuilder
        'sb.Append("<td colspan=""6"" style=""padding:10 20 10 10;"">")
        'sb.Append("<table><tr>")
        sb.Append("<td width=""630"" height=""100%"" valign=""top"" style=""padding-top:10;"">") 'maybe make this 600px
        sb.Append(" <table border=""0"" width=""95%"" cellspacing=""0"" cellpadding=""0"">")
        sb.Append("     <tr valign=""top"">")
        sb.Append("         <td height=""275"" valign=""top"">")
        sb.Append("             <table width=""100%"" border=""0"" cellpadding=""0"" cellspacing=""0"">")
        sb.Append(bodyContent) 'LOAD BODY CONTENT
        'sb.AppendFormat("<tr><td style=""padding-top: 10px;"" colspan=""100%"" valign=""bottom""><a href=""{0}"" class=""small"" onmouseover=""window.status='Review the website Terms & Conditions'; return true;"" onmouseout=""window.status=' '; return true;"">Terms & Conditions</a>&nbsp; &nbsp;<span class=""bodySmall"">&copy; Copyright 2004 - {1}, All rights reserved</span></td></tr>", termsSrc, Today.Year.ToString)
        sb.Append("             </table>")
        sb.Append("         </td>")
        sb.Append("     </tr>")
        'sb.AppendFormat("<tr><td style=""padding-top: 10px;"" valign=""bottom""><a href=""{0}"" class=""small"" onmouseover=""window.status='Review the website Terms & Conditions'; return true;"" onmouseout=""window.status=' '; return true;"">Terms & Conditions</a>&nbsp; &nbsp;<span class=""bodySmall"">&copy; Copyright 2004 - {1}, All rights reserved</span></td></tr>", termsSrc, Today.Year.ToString)
        sb.Append(" </table>")
        sb.Append("</td>")
        'sb.Append("</tr></table>")
        'sb.Append("</td>")

        Return sb.ToString

    End Function

    Public Function SplitColumnSubPageContainer(ByVal bodyContent As String, ByVal sideContent As String, ByVal altText As String) As String

        Dim sb As New StringBuilder
        sb.Append("<td width=""395"" rowspan=""2"" style=""padding-bottom: 10px;"" valign=""top"">")
        sb.Append("<table border=""0"" width=""395"" cellspacing=""0"" cellpadding=""0"">")
        sb.Append(bodyContent) 'LOAD BODY CONTENT CONTROL HERE
        sb.Append("</table>")
        sb.Append("</td>")
        sb.AppendFormat("<td width=""30"" colspan=""3"" rowspan=""2"" bgcolor=""#FFFFFF""><img src=""web/files/images/misc/spacer.gif"" width=""16"" height=""1"" border=""0"" alt=""{0}"" /></td>", altText)
        sb.Append("<td width=""172"" colspan=""2"" rowspan=""2"" style=""padding-top:9px;padding-bottom:10px;"" valign=""top"">")
        sb.Append("<div style=""padding:0;display:block;"">")
        sb.Append(sideContent) 'LOAD SIDE CONTENT CONTROL HERE
        sb.Append(" </div>")
        sb.Append("</td>")

        Return sb.ToString

    End Function

    Public Function SplitColumnBuContainer(ByVal bodyContent As String, ByVal sideContent As String, ByVal termsSrc As String, ByVal altText As String) As String

        Dim sb As New StringBuilder

        sb.Append("<td width=""400"" rowspan=""2"" height=""100%"" style=""padding-bottom: 10px;"">")
        sb.Append("<table border=""0"" height=""100%"" width=""400"" cellspacing=""0"" cellpadding=""0"">")
        sb.Append(bodyContent) 'LOAD BODY CONTENT CONTROL HERE
        sb.AppendFormat("<tr><td style=""padding-top: 10px;"" colspan=""100%"" valign=""bottom""><a href=""{0}"" class=""small"" onmouseover=""window.status='Review the website Terms & Conditions'; return true;"" onmouseout=""window.status=' '; return true;"">Terms & Conditions</a>&nbsp; &nbsp;<span class=""bodySmall"">&copy; Copyright 2004 - {1}, All rights reserved</span></td></tr>", termsSrc, Today.Year.ToString)
        sb.Append("</table>")
        sb.Append("</td>")
        sb.Append("<td width=""202"" rowspan=""2"" style=""padding-top:9px;padding-bottom:10px;padding-left:20px;"">")
        sb.Append("<div style=""padding:0;display:block;"">")
        sb.Append(sideContent) 'LOAD SIDE CONTENT CONTROL HERE
        sb.Append(" </div>")
        sb.Append("</td>")

        Return sb.ToString

    End Function

    Function GetTitleUnderline() As String
        Select Case True
            Case currentPage.PageType = "BUSINESS HOME", currentPage.PageType = "MARKET HOME"
                Return "#ffffff"
            Case Else
                Return "#E3E3D1"
        End Select
    End Function

    Public Function SideBodyContentSection(ByVal title As String, ByVal content As String, ByVal altText As String) As String

        Dim sb As New StringBuilder

        sb.Append("<table border=""0"" width=""172"" cellspacing=""0"" cellpadding=""0"" align=""center"">")
        If title.Length > 0 Then
            sb.AppendFormat("<tr><td class=""rtColTitle"">{0}</td></tr>", title)
            sb.AppendFormat("<tr><td height=""1"" bgcolor=""" + Me.GetTitleUnderline() + """><img src=""web/files/images/misc/spacer.gif"" height=""1"" border=""0"" alt=""{0}"" /></td></tr>", altText)
            sb.Append("<tr><td height=""7""></td></tr>")
        End If
        sb.Append("<tr><td style=""padding-left: 2px; padding-right: 1px;"">")
        sb.Append("<div id=""content"" style=""width:169;padding-right:3;"">")
        sb.AppendFormat("<p>{0}</p>", content)
        sb.Append("</div>")
        sb.Append("</td></tr>")
        sb.Append("<tr><td height=""30""></td></tr>")
        sb.Append("</table>")

        Return sb.ToString
    End Function

    Public Function ProductBlurbSectionFormat(ByVal title As String, ByVal blurbMod As IProductBlurbModule) As String

        Dim sb As New StringBuilder

        sb.Append("<tr valign=""top"">")
        sb.Append("<td>")
        If title.Length > 0 Then
            sb.AppendFormat("<div style=""padding-top:10;"" class=""blueTitle"">{0}</div>", title)
        End If

        Dim fmtBlurb As String = blurbMod.ProductBlurb
        For Each prod As Product In blurbMod.Products
            fmtBlurb = Regex.Replace(fmtBlurb, prod.ProductName, "<span style=""font-weight:bold;"">" + prod.ProductName + "</span>", RegexOptions.IgnoreCase)
        Next

        sb.Append("<table style=""padding-top:10px;""><tr><td valign=""top""><span style=""font-weight:bold;font-size:10px;"">&bull;</span></td>")
        sb.AppendFormat("<td style=""padding-left:5px;"">{0}</td></tr>", fmtBlurb)
        If currentPage.BusUnit.DocAuth = True Then
            If Roles.IsUserInRole(HttpContext.Current.User.Identity.Name, "WebsiteUser") = True Then
                For Each prod As Product In blurbMod.Products
                    sb.AppendFormat("<tr><td>&nbsp;</td><td style=""padding-left:5px;""><span style=""border:none;padding:0 3 0 3;""><img src=""web/files/images/misc/icon_pdf_text.gif"" border=""0"" alt=""{0}"" align=""middle"">", prod.ProductName)
                    For Each doc As Document In prod.Documents
                        sb.AppendFormat("&nbsp;&nbsp; <a class=""small"" href=""GetFile.aspx?file={0}"" title=""{1}"">{2}</a>", doc.DocumentId, prod.ProductName, doc.ContentType)
                    Next
                    sb.AppendFormat("</span> ( {0} )</td></tr>", prod.ProductName)
                Next
            End If
        Else
            sb.Append("<tr><td>&nbsp;</td><td style=""padding-left:5px;"">")
            For Each prod As Product In blurbMod.Products
                sb.AppendFormat("<span style=""border:none;padding:0 3 0 3;""><img src=""web/files/images/misc/icon_pdf_text.gif"" border=""0"" alt=""{0}"" align=""middle"">", prod.ProductName)
                For Each doc As Document In prod.Documents
                    sb.AppendFormat("&nbsp;&nbsp; <a class=""small"" href=""GetFile.aspx?file={0}"" title=""{1}"">{2}</a>", doc.DocumentId, prod.ProductName, doc.ContentType)
                Next
                sb.AppendFormat("</span> ( {0} )<br>", prod.ProductName)
            Next
        End If
        sb.Append("</td></tr></table>")
        sb.Append("</td>")
        sb.Append("</tr>")

        Return sb.ToString
    End Function



    Public Function MainBodyContentSection(ByVal title As String, ByVal content As String, ByVal altText As String) As String

        Dim sb As New StringBuilder

        sb.Append("<tr valign=""top"">")
        'sb.AppendFormat("<td height=""100%"" width=""1""><img src=""web/files/images/misc/spacer.gif"" width=""1"" height=""100%"" border=""0"" alt=""{0}"" ></td>", altText)
        sb.Append("<td>")
        If title.Length > 0 Then
            sb.AppendFormat("<div style=""padding-top:10;"" class=""blueTitle"">{0}</div>", title)
        End If
        If content.StartsWith("<table") Then
            sb.Append("<br/>" + content) 'expecting a product grid here
        Else
            sb.AppendFormat("<p>{0}</p>", content)
        End If
        sb.Append("</td>")
        sb.Append("</tr>")

        Return sb.ToString
    End Function

#Region " HEADER SIDE CONTENT REGION "

    'Function HeaderSideContentContainer(ByVal content As Object, ByVal altText As String) As String
    '    Dim sb As New StringBuilder
    '    sb.Append(HeaderSideContentSection(content, altText))
    '    Return sb.ToString

    'End Function

    Function ClickHereCleanup(ByVal lineText As String, ByVal linkHref As String) As String
        Dim parsedText As String
        parsedText = Regex.Replace(lineText, "click here", "<a href=""" + linkHref + """ target=""_blank""><strong>click here</strong></a>", RegexOptions.IgnoreCase)
        Return parsedText
    End Function

    Function HeaderSideContentSubSection(ByVal zone As Integer, ByVal content As HeaderSideContentModule, ByVal altText As String) As String
        Dim publishDate As Date = content.PublishDate
        Dim expireDate As Date = content.ExpireDate
        Dim lineText As String = String.Empty
        Dim internalLink As Integer = 0
        Dim internalLinkType As String = String.Empty
        Dim externalLink As String = String.Empty
        If zone = 1 Then
            lineText = content.LineText1
            externalLink = content.ExternalLink1
            internalLink = content.InternalLink1
            internalLinkType = content.InternalLink1Type.ToUpper
        ElseIf zone = 2 Then
            lineText = content.LineText2
            externalLink = content.ExternalLink2
            internalLink = content.InternalLink2
            internalLinkType = content.InternalLink2Type.ToUpper
        End If

        Dim sb As New StringBuilder
        sb.Append("<tr>")
        If externalLink.Length > 0 Then
            sb.AppendFormat("<td style=""padding-top: 3px; padding-right: 5px;""><img src=""web/files/images/misc/arrow_blue.gif"" alt=""{0}"" width=""7"" height=""7"" border=""0""></td>", altText)
            sb.AppendFormat("<td style=""padding-right:3;"">{0}", ClickHereCleanup(lineText, externalLink))
        ElseIf internalLink > 0 Then
            sb.AppendFormat("<td style=""padding-top: 3px; padding-right: 5px;""><img src=""web/files/images/misc/arrow_blue.gif"" alt=""{0}"" width=""7"" height=""7"" border=""0""></td>", altText)
            If internalLinkType = "PAGE" Then
                Dim dt As DataTable = TryCast(Cache("URL_REWRITE"), DataTable)
                If dt Is Nothing Then
                    Dim rewriteValidator As New UrlRewriteValidator
                    dt = rewriteValidator.LoadUrlRewritePaths()
                End If
                Dim dv As DataView = dt.DefaultView
                dv.RowFilter = "PageID=" + internalLink.ToString
                If dv IsNot Nothing Then
                    sb.AppendFormat("<td style=""padding-right:3;"">{0}", ClickHereCleanup(lineText, dv(0)("UrlFriendlyName").ToString))
                End If
            ElseIf internalLinkType = "DOCUMENT" Then
                sb.AppendFormat("<td style=""padding-right:3;"">{0}", ClickHereCleanup(lineText, "GetFile.aspx?file=" + internalLink.ToString))
            End If
        End If
        sb.Append("</td></tr>")
        Return sb.ToString
    End Function


    'Function HeaderSideContentSection(ByVal sideContent As Object, ByVal altText As String) As String

    'Dim UseDefault As Boolean = False
    'Dim sb As New StringBuilder

    '    sb.Append("<table width=""100%"" cellpadding=""0"" cellspacing=""0"" border=""0""><tr><td>")
    '    If TypeOf sideContent Is HeaderSideContentModule Then
    'Dim content As HeaderSideContentModule = TryCast(sideContent, HeaderSideContentModule)
    '        If content IsNot Nothing Then
    '            sb.Append(HeaderSideContentSubSection(1, content, altText))
    '            If sideContent.LineText2.Length > 0 Then
    '                sb.Append("<tr><td colspan=""2"">&nbsp;</td></tr>")
    '                sb.Append(HeaderSideContentSubSection(2, content, altText))
    '            End If
    '        Else
    '            UseDefault = True
    '        End If
    '    ElseIf TypeOf sideContent Is ImageModule Then
    '        If sideContent IsNot Nothing Then
    'Dim path As String = TryCast(sideContent, ImageModule).ImageFile.ImagePath
    '            If path.Length > 0 Then
    '                sb.AppendFormat("<img src=""{0}"" alt=""{1}"" width=""158"" height=""90"" border=""0"">", path, altText)
    '            Else
    '                UseDefault = True
    '            End If
    '        End If
    '    End If

    '    If UseDefault = True Then
    '        sb.Append("<tr>")
    '        sb.AppendFormat("<td style=""padding-top: 3px; padding-right: 5px;""><img src=""web/files/images/misc/arrow_blue.gif"" alt=""{0}"" width=""7"" height=""7"" border=""0""></td>", altText)
    '        sb.Append("<td>Register now for a online Petroferm account to gain access to the latest product information, <a href=""Register.aspx"" target=""_blank""><strong>click here</strong></a> to register</td>")
    '        sb.Append("</tr>")
    '    End If

    '    sb.Append("</table>")
    '    Return sb.ToString

    'End Function

    Function HeaderSideContentSection(ByVal sideContent As Object, ByVal altText As String) As String

        Dim useDefault As Boolean = False
        Dim sb As New StringBuilder

        If TypeOf sideContent Is HeaderSideContentModule Then
            Dim content As HeaderSideContentModule = TryCast(sideContent, HeaderSideContentModule)
            If content IsNot Nothing Then
                sb.Append("<td width=""1"" bgcolor=""#FFFFFF"" height=""1""><img src=""web/files/images/misc/spacer.gif"" width=""1""  alt=""Petroferm Inc."" height=""1"" border=""0""></td>")
                sb.Append("<td width=""16"" bgcolor=""#BAE0EA"" height=""1""><img src=""web/files/images/misc/spacer.gif"" width=""16"" alt=""Petroferm Inc."" height=""1"" border=""0""></td>")
                sb.Append("<td width=""172"" bgcolor=""#BAE0EA"" valign=""middle"" style=""padding-top: 10px; padding-bottom: 10px;"" height=""110"">")

                sb.Append("<table border=""0"" width=""172"" cellspacing=""0"" cellpadding=""0"">")
                sb.Append("<tr valign=""top""><td>")

                sb.Append("<table width=""100%"" cellpadding=""0"" cellspacing=""0"" border=""0""><tr><td>")
                sb.Append(HeaderSideContentSubSection(1, content, altText))
                If sideContent.LineText2.Length > 0 Then
                    sb.Append("<tr><td colspan=""2"">&nbsp;</td></tr>")
                    sb.Append(HeaderSideContentSubSection(2, content, altText))
                End If
                sb.Append("</td>")
                sb.Append("</table>")

                sb.Append("</td></tr></table>")
            Else
                sb.Append(Me.GetDefaultHeaderSideContent)
            End If
        ElseIf TypeOf sideContent Is ImageModule Then
            If sideContent IsNot Nothing Then
                Dim path As String = TryCast(sideContent, ImageModule).ImageFile.ImagePath
                If path.Length > 0 Then
                    sb.Append("<td width=""1"" bgcolor=""#FFFFFF"" height=""1""><img src=""web/files/images/misc/spacer.gif"" width=""1""  alt=""Petroferm Inc."" height=""1"" border=""0""></td>")
                    'sb.Append("<td width=""1"" bgcolor=""#BAE0EA"" height=""0""><img src=""web/files/images/misc/spacer.gif"" width=""1"" alt=""Petroferm Inc."" height=""0"" border=""0""></td>")
                    sb.Append("<td width=""189"" bgcolor=""#BAE0EA"" valign=""middle"" height=""110"">")
                    sb.AppendFormat("<img src=""{0}"" alt=""{1}"" width=""189"" height=""110"" border=""0"">", path, altText)
                    sb.Append("</td>")
                Else
                    sb.Append(Me.GetDefaultHeaderSideContent())
                End If
            End If
        End If

        Return sb.ToString

    End Function

    Function GetDefaultHeaderSideContent() As String
        Dim sbContent As New StringBuilder

        sbContent.Append("<td width=""1"" bgcolor=""#FFFFFF"" height=""1""><img src=""web/files/images/misc/spacer.gif"" width=""1""  alt=""Petroferm Inc."" height=""1"" border=""0""></td>")
        sbContent.Append("<td width=""16"" bgcolor=""#BAE0EA"" height=""1""><img src=""web/files/images/misc/spacer.gif"" width=""16"" alt=""Petroferm Inc."" height=""1"" border=""0""></td>")
        sbContent.Append("<td width=""172"" bgcolor=""#BAE0EA"" valign=""middle"" style=""padding-top: 10px; padding-bottom: 10px;"" height=""110"">")

        sbContent.Append("<table border=""0"" width=""172"" cellspacing=""0"" cellpadding=""0"">")
        sbContent.Append("<tr valign=""top""><td>")

        sbContent.Append("<table width=""100%"" cellpadding=""0"" cellspacing=""0"" border=""0""><tr><td>")
        sbContent.Append("<tr>")
        sbContent.AppendFormat("<td style=""padding-top: 3px; padding-right: 5px;""><img src=""web/files/images/misc/arrow_blue.gif"" alt=""{0}"" width=""7"" height=""7"" border=""0""></td>", currentPage.CurrentMarket.MarketName)
        sbContent.AppendFormat("<td>To gain access to the latest product information, <a href=""Register.aspx?ref={0},{1},{2}""><strong>click here</strong></a> to register for a Petroferm account.</td>", _
                    currentPage.BusUnit.BusUnitID.ToString, currentPage.CurrentMarket.MarketID.ToString, Me.currentPage.PageId.ToString)
        sbContent.Append("</tr>")
        sbContent.Append("</td>")
        sbContent.Append("</table>")

        sbContent.Append("</td></tr></table>")
        Return sbcontent.tostring
    End Function

#End Region
End Class
