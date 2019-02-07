Public Class GeneralBasePage
    Inherits BasePage

    Public Sub New()
    End Sub

    Overrides Function BuildHeaderRegion(ByVal currentPage As WebPage) As String
        Return String.Empty
    End Function

    Overrides Function BuildTopMenu(ByVal currentPage As WebPage) As Control
        Dim ctl As Control = MyBase.BuildTopMenuOfMarkets(currentPage)
        Return ctl
    End Function

    Overrides Function BuildBodyRegion(ByVal currentPage As WebPage) As Control

        Dim bodyControl As New Control 'control our body content is returned in
        Dim contentMod As Object = Nothing 'content module with the content
        Dim sbBody As New StringBuilder 'build of multiple main body content
        Dim sbLayout As New StringBuilder 'wrapper for body and/or side content
        Dim i As Integer

        If currentPage.BodyContentRegion.Count > 0 Then
            For i = 0 To currentPage.BodyContentRegion.Count - 1
                Dim modTitle As String = String.Empty

                If TypeOf currentPage.BodyContentRegion.Item(i) Is IProductGridModule Then
                    contentMod = DirectCast(currentPage.BodyContentRegion.Item(i), IProductGridModule)
                    If CType(contentMod, ProductGridModule).ShowTitle = True Then
                        modTitle = CType(contentMod, ProductGridModule).ProductGridTitle.Trim
                    End If
                    sbBody.Append(MyBase.MainBodyContentSection(modTitle, CType(contentMod, ProductGridModule).GetProductGrid, currentPage.BusUnit.BusName))
                ElseIf TypeOf currentPage.BodyContentRegion.Item(i) Is IProductBlurbModule Then
                    contentMod = DirectCast(currentPage.BodyContentRegion.Item(i), IProductBlurbModule)
                    If CType(contentMod, ProductBlurbModule).ShowTitle = True Then
                        modTitle = CType(contentMod, ProductBlurbModule).Title.Trim
                    End If
                    sbBody.Append(MyBase.ProductBlurbSectionFormat(modTitle, contentMod))
                    'sbBody.Append(MyBase.MainBodyContentSection(modTitle, CType(contentMod, ProductBlurbModule).ProductBlurb, currentPage.BusUnit.BusName))
                ElseIf TypeOf currentPage.BodyContentRegion.Item(i) Is IContentModule Then
                    contentMod = DirectCast(currentPage.BodyContentRegion.Item(i), IContentModule)
                    If CType(contentMod, ContentModule).ShowTitle = True Then
                        modTitle = contentMod.ContentTitle.Trim
                    End If
                    sbBody.Append(MyBase.MainBodyContentSection(modTitle, contentMod.Content, currentPage.BusUnit.BusName))
                Else 'should not reach this point - show an empty page
                    sbBody.Append(MyBase.MainBodyContentSection("Invalid Page", "The current page is not valid. If you believe this to be incorrect, we would appreciate you notifying us so we can best assist you. Please <a href=""mailto:website@petroferm.com?subject=Invalid Page Found On Website"">send us an email</a> to alert us of the problem.", String.Empty))
                End If

            Next
        End If

        If currentPage.SideBodyContentRegion.Count > 0 Then

            Dim sbSide As New StringBuilder 'build of multiple side content
            If currentPage.SideBodyContentRegion.Count > 0 Then
                For i = 0 To currentPage.SideBodyContentRegion.Count - 1
                    contentMod = DirectCast(currentPage.SideBodyContentRegion.Item(i), IContentModule)
                    Dim modTitle As String = String.Empty
                    If CType(contentMod, ContentModule).ShowTitle = True Then
                        modTitle = contentMod.ContentTitle
                    End If
                    sbSide.Append(Me.SideBodyContentSection(modTitle, contentMod.Content, currentPage.CurrentMarket.MarketName))
                Next i
            End If

            If sbSide.ToString.Length > 0 Then
                sbLayout.Append(MyBase.SplitColumnSubPageContainer(sbBody.ToString, sbSide.ToString, currentPage.CurrentMarket.MarketName))
            End If

        Else
            sbLayout.Append(MyBase.FullSubPageContainer(sbBody.ToString, "terms.aspx"))
        End If

        bodyControl.Controls.Add(New LiteralControl(sbLayout.ToString))
        Return bodyControl

    End Function



#Region " MARKET LAYOUTS "

    'TODO: NEED TO BUILD CONTAINER FOR BUSINESS UNIT HOME PAGE AND SUB-PAGES (THE ONES HERE ARE FOR MARKET LANDING)
    Public Function FullPageMktContainer(ByVal bodyContent As String) As String

        Dim sb As New StringBuilder

        sb.Append("<td colspan=""6"" style=""padding:10 20 10 30;"">")
        sb.Append(" <table border=""0"" width=""100%"" cellspacing=""0"" cellpadding=""0"">")
        sb.Append("     <tr valign=""top"">")
        sb.Append("         <td height=""275"">")
        sb.Append("             <table width=""100%"" border=""0"" cellpadding=""0"" cellspacing=""0"">")
        sb.Append(bodyContent) 'LOAD BODY CONTENT
        sb.Append("             </table>")
        sb.Append("         </td>")
        sb.Append("     </tr>")
        sb.Append(" </table>")
        sb.Append("</td>")





        '        sb.Append("<td width=""572"" colspan=""4"" height=""100%"" style=""padding-top: 16px; padding-bottom: 10px;"">")
        '        sb.Append(bodyContent) 'LOAD BODY CONTENT
        '       sb.Append("</td>")
        Return sb.ToString

    End Function


    Public Function SplitColumnMktContainer(ByVal bodyContent As String, ByVal sideContent As String, ByVal altText As String) As String

        Dim sb As New StringBuilder
        'sb.Append("<table border=1><tr>")
        sb.AppendFormat("<td width=""30""><img src=""web/files/images/misc/spacer.gif"" width=""30"" height=""1"" alt=""{0}"" border=""0""></td>", altText)
        sb.Append("<td width=""400"" rowspan=""2"" height=""100%"" style=""padding-bottom: 10px;"">")
        sb.Append("<table border=""0"" height=""100%"" width=""400"" cellspacing=""0"" cellpadding=""0"">")
        sb.Append(bodyContent) 'LOAD BODY CONTENT CONTROL HERE
        sb.Append("</table>")
        sb.Append("</td>")
        ''sb.AppendFormat("<td width=""30"" colspan=""3"" rowspan=""2"" bgcolor=""" + Me.GetTitleUnderline() + """><img src=""web/files/images/misc/spacer.gif"" width=""16"" height=""1"" border=""0"" alt=""{0}"" /></td>", altText)
        ''sb.Append("<td width=""172"" colspan=""2"" rowspan=""2"" style=""padding-top:9px;padding-bottom:10px;"">")
        sb.Append("<td width=""202"" colspan=""5"" rowspan=""2"" style=""padding-top:9px;padding-bottom:10px;padding-left:20px;"">")
        sb.Append("<div style=""padding:0;display:block;"">")
        sb.Append(sideContent) 'LOAD SIDE CONTENT CONTROL HERE
        sb.Append(" </div>")
        sb.Append("</td>")
        'sb.Append("</tr></table>")
        Return sb.ToString

    End Function

    Public Function MainBodyContentMktSection(ByVal title As String, ByVal content As String) As String

        Dim sb As New StringBuilder
        sb.Append("<tr valign=""top"">")
        sb.AppendFormat("<td height=""100%"" width=""1""><img src=""web/files/images/misc/spacer.gif"" width=""1"" height=""100%"" border=""0"" alt=""{0}"" ></td>", title)
        sb.Append("<td height=""275"">")
        If title.Length > 0 Then
            sb.AppendFormat("<div class=""blueTitle"">{0}</div>", title)
        End If
        sb.AppendFormat("<p>{0}</p>", content)
        sb.Append("</td>")
        sb.Append("</tr>")

        Return sb.ToString
    End Function

    Public Function SideBodyContentMktSection(ByVal title As String, ByVal content As String, ByVal altText As String) As String

        Dim sb As New StringBuilder

        sb.Append("<table border=""0"" width=""172"" cellspacing=""0"" cellpadding=""0"" align=""center"">")
        If title.Length > 0 Then
            sb.AppendFormat("<tr><td class=""rtColTitle"">{0}</td></tr>", title)
            sb.AppendFormat("<tr><td height=""1"" bgcolor=""" + Me.GetTitleUnderline() + """><img src=""web/files/images/misc/spacer.gif"" height=""1"" border=""0"" alt=""{0}"" /></td></tr>", altText)
            sb.Append("<tr><td height=""7""></td></tr>")
        End If
        sb.Append("<tr><td style=""padding-left: 2px; padding-right: 1px;"">")
        sb.Append("<div id=""content"" style=""width:169;padding-right:3px;"">")
        sb.AppendFormat("<p>{0}</p>", content)
        sb.Append("</div>")
        sb.Append("</td></tr>")
        sb.Append("<tr><td height=""30""></td></tr>")
        sb.Append("</table>")

        Return sb.ToString
    End Function

#End Region



End Class
