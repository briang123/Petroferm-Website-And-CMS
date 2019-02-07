Public MustInherit Class MarketBasePage
    Inherits BasePage

    Sub New()
    End Sub

    Public Function BuildCountryFlagRegion() As System.Web.UI.Control
        Return New LiteralControl("&nbsp;")
    End Function

    Overridable Function BuildHeaderSideContentRegion(ByVal currentPage As WebPage) As Control

        Dim bodyControl As New Control 'control our body content is returned in
        Dim contentMod As Object = Nothing 'content module with the content
        Dim sbContent As New StringBuilder 'build of multiple main body content
        Dim i As Integer

        If currentPage.HeaderSideImageRegion.Count > 0 Then
            For i = 0 To currentPage.HeaderSideImageRegion.Count - 1
                'only allow a single image loaded into this spot at a time - IMAGE DIMENSION SHOULD BE 189 X 110. (space constraints)
                contentMod = DirectCast(currentPage.HeaderSideImageRegion.Item(0), IImageModule)
                sbContent.Append(HeaderSideContentSection(contentMod, currentPage.CurrentMarket.MarketName))
            Next
        ElseIf currentPage.HeaderSideContentRegion.Count > 0 Then
            For i = 0 To currentPage.HeaderSideContentRegion.Count - 1
                'only allow a single set of link1/link2 header side content modules in this area (space constraints)
                contentMod = DirectCast(currentPage.HeaderSideContentRegion.Item(0), IHeaderSideContentModule)
                sbContent.Append(HeaderSideContentSection(contentMod, currentPage.CurrentMarket.MarketName))
            Next
        Else
            sbContent.Append(MyBase.GetDefaultHeaderSideContent)
        End If

        bodyControl.Controls.Add(New LiteralControl(sbContent.ToString))
        Return bodyControl

    End Function

#Region " OVERRIDE METHODS "

    Overrides Function BuildHeaderRegion(ByVal currentPage As WebPage) As String

        Dim sb As New StringBuilder

        If currentPage.HeaderImageRegion.Count > 0 Then
            For i As Integer = 0 To currentPage.HeaderImageRegion.Count - 1
                Dim imageMod As ImageModule = TryCast(currentPage.HeaderImageRegion.Item(i), ImageModule)
                If imageMod IsNot Nothing Then
                    sb.Append(imageMod.ImageFile.ImagePath)
                End If
            Next i
        End If
        Return sb.ToString

    End Function

    Overrides Function BuildTopMenu(ByVal currentPage As WebPage) As Control
        'call common function used by market and general content pages
        Dim ctl As Control = BuildTopMenuOfMarkets(currentPage)
        Return ctl
    End Function

    Overrides Function BuildBodyRegion(ByVal currentPage As WebPage) As Control

        Dim bodyControl As New Control 'control our body content is returned in
        Dim contentMod As IContentModule 'content module with the content
        Dim sbBody As New StringBuilder 'build of multiple main body content
        Dim sbLayout As New StringBuilder 'wrapper for body and/or side content
        Dim i As Integer

        If currentPage.BodyContentRegion.Count > 0 Then
            For i = 0 To currentPage.BodyContentRegion.Count - 1
                contentMod = DirectCast(currentPage.BodyContentRegion.Item(i), IContentModule)
                Dim modTitle As String = String.Empty
                If CType(contentMod, ContentModule).ShowTitle = True Then
                    modTitle = contentMod.ContentTitle.Trim
                End If
                sbBody.Append(MainBodyContentMktSection(modTitle, contentMod.Content))
                'sbBody.Append(MyBase.MainBodyContentSection(modtitle, contentMod.Content, currentPage.BusUnit.BusName))
            Next
        End If

        If currentPage.SideBodyContentRegion.Count > 0 Then

            Dim sbSide As New StringBuilder 'build of multiple side content
            If currentPage.SideBodyContentRegion.Count > 0 Then
                For i = 0 To currentPage.BodyContentRegion.Count - 1
                    contentMod = DirectCast(currentPage.SideBodyContentRegion.Item(i), IContentModule)
                    Dim modTitle As String = String.Empty
                    If CType(contentMod, ContentModule).ShowTitle = True Then
                        modTitle = contentMod.ContentTitle
                    End If
                    sbSide.Append(Me.SideBodyContentMktSection(modTitle, contentMod.Content, currentPage.CurrentMarket.MarketName))
                Next i
            End If

            If IsMarketHomePage Then
                sbLayout.Append(Me.SplitColumnMktContainer(sbBody.ToString, sbSide.ToString, currentPage.CurrentMarket.MarketName))
            End If

        Else
            If IsMarketHomePage Then
                sbLayout.Append(FullPageMktContainer(sbBody.ToString))
            Else
                'TODO: see the FullPageMktContainer method
                sbLayout.Append(MyBase.FullSubPageContainer(sbBody.ToString, "terms.aspx"))
            End If
        End If

        bodyControl.Controls.Add(New LiteralControl(sbLayout.ToString))
        Return bodyControl

    End Function

#End Region


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
        sb.Append("<td width=""400"" rowspan=""2"" height=""100%"" style=""padding:10 0 10 0;"" valign=""top"">")
        sb.Append("<table border=""0"" height=""100%"" width=""400"" cellspacing=""0"" cellpadding=""0"">")
        sb.Append(bodyContent) 'LOAD BODY CONTENT CONTROL HERE
        sb.Append("</table>")
        sb.Append("</td>")
        ''sb.AppendFormat("<td width=""30"" colspan=""3"" rowspan=""2"" bgcolor=""#E3E3D1""><img src=""web/files/images/misc/spacer.gif"" width=""16"" height=""1"" border=""0"" alt=""{0}"" /></td>", altText)
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
            sb.AppendFormat("<tr><td height=""1"" bgcolor=""#FFFFFF""><img src=""web/files/images/misc/spacer.gif"" height=""1"" border=""0"" alt=""{0}"" /></td></tr>", altText)
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



'<!-- BEGIN TABLE WRAPPER HERE FOR FULL PAGE -- USE THE FullSubPageContainer (possibly) -->
'<TD width="572" id="FullPageContentWrapper" runat=server>
'    <TABLE>
'        <TR>
'            <td width="400" height="100%" style="padding-top: 16px; padding-bottom: 10px;">
'             <!-- Begin Content Table -->
'             <table border="0" height="100%" width="400" cellspacing="0" cellpadding="0">
'              <tr valign="top">
'               <td height="100%" width="1"><img src="web/files/images/misc/spacer.gif" width="1"  alt="Petroferm Inc." height="100%" border="0"></td>
'               <td height="275">
'               </td>
'              </tr>
'             </table>
'             <!-- End Content Table -->
'            </td>
'            <td width="13"><img src="web/files/images/misc/spacer.gif" alt="Petroferm Inc." width="13" height="1" border="0"></td>
'            <td width="1"></td>
'            <td width="16"><img src="web/files/images/misc/spacer.gif" alt="Petroferm Inc." width="16" height="1" border="0"></td>
'            <td width="172" rowspan="2" style="padding-top: 9px; padding-bottom: 10px;">&nbsp;&nbsp;</td>		                            
'        </TR>
'    </TABLE>
'</TD>
'<!-- END TABLE WRAPPER HERE FOR FULL PAGE -->

'<!-- BEGIN TABLE HERE FOR SPLIT PAGE -- use SplitColumnMktContainer -->		                            

'<td width="602" id="SplitPageContentWrapper" runat="server" visible="false">
'    <table width="602">


'        <td width="400" height="100%" style="padding-top: 16px; padding-bottom: 10px;">
'         <!-- Begin Content Table -->
'         <table border="0" height="100%" width="400" cellspacing="0" cellpadding="0">
'          <tr valign="top">
'           <td height="100%" width="1"><img src="web/files/images/misc/spacer.gif" width="1"  alt="Petroferm Inc." height="100%" border="0"></td>
'           <td height="275">

'           </td>
'          </tr>
'         </table>
'         <!-- End Content Table -->
'        </td>
'        <td width="13"><img src="web/files/images/misc/spacer.gif" alt="Petroferm Inc." width="13" height="1" border="0"></td>
'        <td width="1"></td>
'        <td width="16"><img src="web/files/images/misc/spacer.gif" alt="Petroferm Inc." width="16" height="1" border="0"></td>
'        <td width="172" rowspan="2" style="padding-top: 9px; padding-bottom: 10px;">
'        <!-- Make a call to SideBodyContentMktSection -->
'        </td>

'    </table>
'</td>

'<!-- END TABLE HERE FOR SPLIT PAGE -->