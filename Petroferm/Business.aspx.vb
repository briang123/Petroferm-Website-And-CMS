Imports System.Collections.Generic

Partial Class Business
    Inherits BasePage

    Protected Sub Page_LoadComplete(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.LoadComplete

        'HEADER SECTION
        With Master.MasterLogoAndLink
            .HRef = LinkGenerator.BuildHomePageFriendlyPageLink(currentPage.BusUnit.BusUnitID)
            .Controls.Add(BuildHtmlImage(currentPage.BusUnit.LogoImage))
        End With

        CType(Master.FindControl("btnSimpleSearch"), Button).PostBackUrl = "~/Search.aspx?ref=" + currentPage.BusUnit.BusUnitID.ToString + "," + currentPage.CurrentMarket.MarketID.ToString + "," + MyBase.CurrentPageId.ToString + "&type=simple"
        Master.MasterAdvanceSearchLink.HRef = "~/Search.aspx?ref=" + currentPage.BusUnit.BusUnitID.ToString + "," + currentPage.CurrentMarket.MarketID.ToString + "," + MyBase.CurrentPageId.ToString + "&type=advanced"
        Master.MasterAdvanceSearchLink.Title = "Advanced Search for " + currentPage.BusUnit.BusName

        ' add ref to register link in login box - 12/22/06 - kr
        Master.MasterRegisterLink.HRef = "~/Register.aspx?ref=" + currentPage.BusUnit.BusUnitID.ToString + "," + currentPage.CurrentMarket.MarketID.ToString + "," + MyBase.CurrentPageId.ToString

        'TOP MENU SECTION
        Dim tempElement As String = String.Empty
        Select Case True
            Case IsPetrofermHomePage
                'TODO: How will we be able to determine what top nav items get displayed for the Petroferm home page - Maybe we can have a BU setting indicating whether they get added to the top nav and we can iterate through each business unit looking for that value
                For i As Integer = 1 To currentPage.BusUnit.Markets.Count
                    tempElement += """homepage" & CompressStringForJavaScript(CType(currentPage.BusUnit.Markets.Item(i), Market).MarketName.ToString) & "Welcome" & """" & ","
                Next

                ' kr - task #28 - 12/26/06
                Me.Master.MasterTopMenuRegion.Controls.Add(BuildTopMenu(currentPage))

            Case IsMarketHomePage Or IsBusinessHomePage
                For i As Integer = 1 To currentPage.BusUnit.Markets.Count
                    tempElement += """homepage" & CompressStringForJavaScript(CType(currentPage.BusUnit.Markets.Item(i), Market).MarketName.ToString) & "Welcome" & """" & ","
                Next
                Me.Master.MasterTopMenuRegion.Controls.Add(BuildTopMenu(currentPage))
        End Select

        If tempElement.Length > 1 Then
            Master.MasterWelcomeJavaScript = tempElement.Substring(0, tempElement.Length - 1)
        End If

        'HEADER IMAGE SECTION
        Master.MasterHeaderImageRegion.Controls.Add(New LiteralControl(BuildHeaderRegion(currentPage)))

        'SIDE NAVIGATION
        'Dim nav As New SideNavigationModule(currentPage.BusUnit.BusUnitID, Me.CurrentPageId, currentPage.PageType, WorkflowItem.LiveMode.Live)
        Master.MasterSideNavigationRegion.Controls.Add(New LiteralControl(currentPage.SideNavigationRegion)) 'nav.BuildSideNavigation))

        'BODY CONTENT AREA (FULL PAGE OR SPLIT PAGE W/ SIDE MODULES + FOOTER SECTION)
        Master.MasterBodyContentRegion.Controls.Add(BuildBodyRegion(currentPage))

        'INITIALIZE THE TOP NAVIGATION HEADER GRAPHICS BY SETTING THE VISIBILITY TO HIDDEN
        Dim myStyles As String = "<style type=""text/css"">{0}</style>"
        Page.ClientScript.RegisterStartupScript(Me.GetType(), "navStyles", String.Format(myStyles, StyleObjects.ToString), False)

    End Sub

#Region " OVERRIDE METHODS "

    Overrides Function BuildHeaderRegion(ByVal currentPage As WebPage) As String

        Dim ctl As New Control
        Dim tempElement As String = String.Empty
        Dim isMarketLanding As Boolean = (currentPage.PageType.ToUpper = "MARKET HOME")
        Dim isBusinessHome As Boolean = (currentPage.PageType.ToUpper = "BUSINESS HOME")
        Dim isPetrofermHome As Boolean = (IsBusinessHome And currentPage.BusUnit.BusUnitID = 1)
        Dim isMarketSubPage As Boolean = (currentPage.PageType.ToUpper = "PRODUCT")
        Dim isGenericPage As Boolean = (currentPage.PageType.ToUpper.StartsWith("GENERAL") = True)
        Dim sb As New StringBuilder(String.Empty)
        Select Case True

            Case IsPetrofermHome

                If currentPage.HeaderImageRegion.Count > 0 Then
                    For i As Integer = 0 To currentPage.HeaderImageRegion.Count - 1
                        Dim imageMod As ImageModule = TryCast(currentPage.HeaderImageRegion.Item(i), ImageModule)
                        If imageMod IsNot Nothing Then
                            sb.Append("<div id=""homepageDefaultWelcome"">")
                            sb.Append("    <table width=""797"" border=""0"" cellspacing=""0"" cellpadding=""0"">")
                            sb.Append("        <tr> ")
                            sb.Append("            <td><img src=""" + imageMod.ImageFile.ImagePath + """ border=""0"" alt=""" + imageMod.ImageFile.AltText + """></td>")
                            sb.Append("            <td width=""1"" height=""110""><img src=""web/files/images/misc/spacer.gif"" width=""1"" height=""110"" alt=""" + imageMod.ImageFile.AltText + """ border=""0""></td>")
                            sb.Append("            <td bgcolor=""#BAE0EA"" width=""352"" valign=""top"" style=""padding-top: 10px;"">")
                            sb.Append("                <br>")
                            sb.Append("                <div class=""marketTitleBold"" style=""padding-left: 18px;"">Welcome to</div>")
                            sb.Append("                <div class=""marketTitle"" style=""padding-left: 45px;"">" + currentPage.BusUnit.BusName + "</div>")
                            sb.Append("            </td>        ")
                            sb.Append("        </tr>")
                            sb.Append("    </table>   ")
                            sb.Append("</div>")
                        End If
                    Next i
                End If

                ' loop through the nav region stuff -- and get the welcome image id from the image module
                For i As Integer = 0 To currentPage.BusUnit.TopMenuNavigationRegion.Count - 1
                    Dim imageMod As ImageModule = TryCast(currentPage.BusUnit.TopMenuNavigationRegion.Item(i), ImageModule)
                    If imageMod IsNot Nothing Then
                        ' only look at the NAVIGATION ON image
                        If imageMod.ImageType = "NAVIGATION ON" Then
                            ' get and fill the image


                            sb.Append("<div id=""homepage" + CompressStringForJavaScript(imageMod.WelcomeTitle) + "Welcome"">")
                            sb.Append("<table width=""796"" border=""0"" cellspacing=""0"" cellpadding=""0"">")
                            sb.Append("    <tr> ")
                            sb.Append("      <td><img src=""" + imageMod.WelcomeImageFile.ImagePath + """ border=""0"" alt=""" + imageMod.WelcomeImageFile.AltText + """></td>")
                            sb.Append("      <td width=""1"" height=""110""><img src=""web/files/images/misc/spacer.gif"" alt=""" + imageMod.WelcomeImageFile.AltText + """ width=""1"" height=""110"" border=""0""></td>")
                            sb.Append("      <td bgcolor=""#BAE0EA"" width=""352"" valign=""top"" style=""padding-top: 10px;"" onMouseOver=""window.clearTimeout(timeOut);"" onMouseOut=""welcomeSectionMouseOut();"">")
                            sb.Append("        <div class=""marketTitleBold"" style=""padding-left: 18px;"" >Welcome ")
                            sb.Append("          to </div>")
                            sb.Append("        <div class=""marketTitle"" style=""padding-left: 45px;"" >" + imageMod.WelcomeTitle + "</div>")

                            ' if this navigational element represents more than one link (industrial products)
                            ' then get the list of links/link text and display in welcome area
                            If imageMod.WelcomeLinkPageIDList.Length > 0 Then
                                sb.Append("       <div style=""padding-left: 50px;font-weight:bold;color: #74BBCE;"" >")
                                sb.Append("         <table border=""0"" cellpadding=""2"" cellspacing=""0"">")
                                sb.Append("           <tr valign=""top"">")
                                sb.Append("             <td style=""font-weight:bold;color: #74BBCE;"">")

                                Dim welcomeLinkHrefs As String() = imageMod.WelcomeLinkPageIDList.Split("|")
                                Dim welcomeLinkTexts As String() = imageMod.WelcomeLinkTextList.Split("|")
                                Dim href As String = ""
                                Dim linkText As String = ""
                                Dim linkIndex As Integer
                                Dim newColumnIndex As Integer = 0

                                ' figure out when to add the new column
                                Select Case True
                                    Case welcomeLinkHrefs.Length > 4
                                        newColumnIndex = 3
                                    Case welcomeLinkHrefs.Length > 2
                                        newColumnIndex = 2
                                    Case welcomeLinkHrefs.Length > 1
                                        newColumnIndex = 1
                                End Select

                                For linkIndex = 0 To welcomeLinkHrefs.Length - 1

                                    If linkIndex = newColumnIndex Then ' go to next column
                                        sb.Append("     </td>")
                                        sb.Append("     <td style=""font-weight:bold;color: #74BBCE;"">")
                                    End If
                                    sb.AppendFormat("     <a href=""{0}"" class=""marketTitleLink"" >{1}</a> &rarr;<br>", _
                                                    LinkGenerator.BuildCommonPageLink(Convert.ToInt32(welcomeLinkHrefs(linkIndex))), welcomeLinkTexts(linkIndex).ToString)


                                Next
                                sb.Append("             </td>")
                                sb.Append("           </tr>")
                                sb.Append("         </table>")
                                sb.Append("       </div>")

                            End If



                            sb.Append("      </td>")
                            sb.Append("    </tr>")
                            sb.Append("</table>")
                            sb.Append("</div>")
                        End If


                    End If


                Next




            Case Else



                If currentPage.HeaderImageRegion.Count > 0 Then
                    For i As Integer = 0 To currentPage.HeaderImageRegion.Count - 1
                        Dim imageMod As ImageModule = TryCast(currentPage.HeaderImageRegion.Item(i), ImageModule)
                        If imageMod IsNot Nothing Then
                            sb.Append("<div id=""homepageDefaultWelcome"">")
                            sb.Append("    <table width=""797"" border=""0"" cellspacing=""0"" cellpadding=""0"">")
                            sb.Append("        <tr> ")
                            sb.Append("            <td><img src=""" + imageMod.ImageFile.ImagePath + """ border=""0"" alt=""" + imageMod.ImageFile.AltText + """></td>")
                            sb.Append("            <td width=""1"" height=""110""><img src=""web/files/images/misc/spacer.gif"" width=""1"" height=""110"" alt=""" + imageMod.ImageFile.AltText + """ border=""0""></td>")
                            sb.Append("            <td bgcolor=""#BAE0EA"" width=""352"" valign=""top"" style=""padding-top: 10px;"">")
                            sb.Append("                <br>")
                            sb.Append("                <div class=""marketTitleBold"" style=""padding-left: 18px;"">Welcome to</div>")
                            sb.Append("                <div class=""marketTitle"" style=""padding-left: 45px;"">" + currentPage.BusUnit.BusName + "</div>")
                            sb.Append("            </td>        ")
                            sb.Append("        </tr>")
                            sb.Append("    </table>   ")
                            sb.Append("</div>")
                        End If
                    Next i
                End If


                For i As Integer = 1 To currentPage.BusUnit.Markets.Count
                    Dim market As Market = TryCast(currentPage.BusUnit.Markets.Item(i), Market)
                    If market IsNot Nothing Then
                        Dim imageMod As ImageModule = TryCast(market.HeaderImageRegion.Item(0), ImageModule)
                        If imageMod IsNot Nothing Then

                            sb.Append("<div id=""homepage" + CompressStringForJavaScript(market.MarketName) + "Welcome"">")
                            sb.Append("<table width=""796"" border=""0"" cellspacing=""0"" cellpadding=""0"">")
                            sb.Append("    <tr> ")
                            sb.Append("      <td><img src=""" + imageMod.ImageFile.ImagePath + """ border=""0"" alt=""" + imageMod.ImageFile.AltText + """></td>")
                            sb.Append("      <td width=""1"" height=""110""><img src=""web/files/images/misc/spacer.gif"" alt=""" + imageMod.ImageFile.AltText + """ width=""1"" height=""110"" border=""0""></td>")
                            sb.Append("      <td bgcolor=""#BAE0EA"" width=""352"" valign=""top"" style=""padding-top: 10px;"" onMouseOver=""window.clearTimeout(timeOut);"" onMouseOut=""welcomeSectionMouseOut();"">")
                            sb.Append("        <div class=""marketTitleBold"" style=""padding-left: 18px;"" >Welcome ")
                            sb.Append("          to </div>")
                            sb.Append("        <div class=""marketTitle"" style=""padding-left: 45px;"" >" + market.MarketName + "</div>")
                            sb.Append("      </td>")
                            sb.Append("    </tr>")
                            sb.Append("</table>")
                            sb.Append("</div>")

                        End If
                    End If
                Next




        End Select


        Return sb.ToString

    End Function

    Overrides Function BuildTopMenu(ByVal currentPage As WebPage) As Control

        '"<a href=""/?bu=3"" 
        '   onMouseOver=""welcomeSectionMouseOver('PetrofermCleaning','images/nav_petroferm_cleaning_on.gif','homepagePetrofermCleaningWelcome');"" 
        '   onMouseOut=""welcomeSectionMouseOut('homepagePetrofermCleaningWelcome');"">
        '       <img src=""images/nav_petroferm_cleaning_off.gif"" alt=""Petroferm Cleaning Products"" name=""PetrofermCleaning"" width=""145"" height=""44"" border=""0"" id=""PetrofermCleaning"">
        '</a>
        '<img src=""images/nav_spacer.gif"" width=""1"" height=""44"" border=""0"" name=""notch1"" id=""notch1"">
        '<a href=""/?bu=4"" 
        '   onMouseOver=""welcomeSectionMouseOver('PetrofermFuel','images/nav_petroferm_fuel_on.gif','homepagePetrofermFuelWelcome');"" 
        '   onMouseOut=""welcomeSectionMouseOut('homepagePetrofermFuelWelcome');"">
        '       <img src=""images/nav_petroferm_fuel_off.gif"" alt=""Petroferm Fuels"" name=""PetrofermFuel"" width=""145"" height=""44"" border=""0"" id=""PetrofermFuel"">
        '</a>
        '<img src=""images/nav_spacer.gif"" width=""1"" height=""44"" border=""0"" name=""notch1"" id=""Img1"">
        '<a href="""" 
        '   onMouseOver=""welcomeSectionMouseOver('Industrial','images/nav_petroferm_industrial_on.gif','homepageIndustrialWelcome');"" 
        '   onMouseOut=""welcomeSectionMouseOut('homepageIndustrialWelcome');"">
        '       <img src=""images/nav_petroferm_industrial_off.gif"" alt=""Industrial Products"" name=""Industrial"" width=""145"" height=""44"" border=""0"" id=""Industrial"">
        '</a>
        '<img src=""images/nav_spacer.gif"" width=""1"" height=""44"" border=""0"" name=""notch3"" id=""notch3"">"


        'TODO: Will need to determine if the top menu mouseover needs to display sub-links in the menu header text area

        'Dim menuSpacer As String = "<img src=""images/nav_spacer.gif"" width=""1"" height=""44"" border=""0"">"


        'TODO: Will need to get the Business Unit ID and format the menu accordingly


        Dim ctl As New Control
        Dim tempElement As String = String.Empty
        Dim isMarketLanding As Boolean = (currentPage.PageType.ToUpper = "MARKET HOME")
        Dim isBusinessHome As Boolean = (currentPage.PageType.ToUpper = "BUSINESS HOME")
        Dim isPetrofermHome As Boolean = (IsBusinessHome And currentPage.BusUnit.BusUnitID = 1)
        Dim isMarketSubPage As Boolean = (currentPage.PageType.ToUpper = "PRODUCT")
        Dim isGenericPage As Boolean = (currentPage.PageType.ToUpper.StartsWith("GENERAL") = True)

        Select Case True
            Case IsPetrofermHome
                ' also need to compile welcome section names for mouse over/out functionality
                Dim welcomeSectionsJs As New StringBuilder
                welcomeSectionsJS.Append("var welcomeSections = new Array(")

                ' will grab nav on/nav off image modules in lieu of markets
                For i As Integer = 0 To currentPage.BusUnit.TopMenuNavigationRegion.Count - 1
                    Dim imageMod As ImageModule = TryCast(currentPage.BusUnit.TopMenuNavigationRegion.Item(i), ImageModule)
                    If imageMod IsNot Nothing Then

                        If imageMod.ImageType.ToUpper = "NAVIGATION OFF" Then

                            Dim topNavImageContainer As New LiteralControl
                            Dim doSelectCurrentMarket As Boolean = False
                            Dim navTopMenuLink As New StringBuilder
                            Dim onmouseover As String = String.Empty
                            Dim onmouseout As String = String.Empty
                            Dim imageOnSrc As String = GetImageSource("NAVIGATION ON", imageMod.WelcomeImageID, currentPage.BusUnit)
                            Dim imageClientId As String = CompressStringForJavaScript(imageMod.WelcomeTitle) 'CompressStringForJavaScript(Market.MarketName)
                            With welcomeSectionsJS
                                .Append("'homepage" + ImageClientId + "Welcome',")
                            End With

                            TopNavImageContainer.Text = "<img src=""" + imageMod.ImageFile.ImagePath + """ name=""" + ImageClientId + """ alt=""" + imageMod.ImageFile.AltText + """ border=""0"">"

                            StyleObjects.Append("#homepage" + ImageClientId + "Welcome {position:absolute;visibility:hidden;z-index:100;top:0px;left:0px;} " + vbCrLf)

                            ' old version
                            'onmouseover = "MM_swapImage('" + ImageClientId + "','','" + imageOnSrc + "',0);toggleWelcomeSections('homepage" + ImageClientId + "Welcome');"
                            onmouseover = "welcomeSectionMouseOver('" + ImageClientId + "','" + imageOnSrc + "','homepage" + ImageClientId + "Welcome');"

                            ' old version
                            'onmouseout = "MM_swapImgRestore();toggleWelcomeSections('homepage" + ImageClientId + "Welcome');"
                            onmouseout = "welcomeSectionMouseOut('homepage" + ImageClientId + "Welcome');"

                            NavTopMenuLink.AppendFormat("<a href=""{0}"" onmouseover=""{1}"" onmouseout=""{2}"">{3}</a>{4}", _
                                    imageMod.WelcomeLinkPageFriendlyURL, _
                                    onmouseover, onmouseout, TopNavImageContainer.Text, _
                                    "<img src=""web/files/images/misc/nav_spacer.gif"" alt=""Petroferm Inc."" border=""0"" width=""1"" height=""44"">")

                            ctl.Controls.Add(New LiteralControl(NavTopMenuLink.ToString))
                        End If
                    End If
                Next
                ' strip off last comma from welcome sections js array
                With welcomeSectionsJS
                    .Remove(.Length - 1, 1)
                    .Append(");")
                End With
                Me.ClientScript.RegisterClientScriptBlock(Me.GetType, "WelcomeSections", _
                    welcomeSectionsJS.ToString, True)

            Case IsMarketLanding Or IsBusinessHome Or IsGenericPage
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
            Case IsMarketSubPage


            Case Else


        End Select

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
                sbBody.Append(MainBodyContentSection(contentMod.ContentTitle.Trim, contentMod.Content.ToString, currentPage.BusUnit.BusName))
                'sbBody.Append(MainBodyContentMktSection(contentMod.ContentTitle.Trim, contentMod.Content.ToString))
            Next
        End If

        If currentPage.SideBodyContentRegion.Count > 0 Then

            Dim sbSide As New StringBuilder 'build of multiple side content
            If currentPage.SideBodyContentRegion.Count > 0 Then
                For i = 0 To currentPage.BodyContentRegion.Count - 1
                    contentMod = DirectCast(currentPage.SideBodyContentRegion.Item(i), IContentModule)
                    sbSide.Append(SideBodyContentSection(contentMod.ContentTitle.Trim, contentMod.Content.ToString, currentPage.BusUnit.BusName))
                    'sbSide.Append(SideBodyContentMktSection(contentMod.ContentTitle, contentMod.Content.ToString))
                Next i
            End If

            Select Case currentPage.PageType.ToUpper
                Case "BUSINESS HOME"
                    If currentPage.BusUnit.BusUnitID = 1 Then
                        sbLayout.Append(FullPageContainer(sbBody.ToString))
                        'sbLayout.Append(PetroHomeFullPageContainer(sbBody.ToString, "terms.aspx"))
                    Else
                        sbLayout.Append(SplitColumnBUContainer(sbBody.ToString, sbSide.ToString, "terms.aspx", currentPage.BusUnit.BusName))
                    End If

                Case "MARKET HOME"
                    'sbLayout.Append(SplitColumnMktContainer(sbBody.ToString, sbSide.ToString, currentPage.CurrentMarket.MarketName))
                Case Else
                    'sbLayout.Append(SplitColumnMktContainer(sbBody.ToString, sbSide.ToString, currentPage.PageTitle))
            End Select
        Else
            Select Case currentPage.PageType.ToUpper
                Case "BUSINESS HOME"
                    If currentPage.BusUnit.BusUnitID = 1 Then
                        'sbLayout.Append(FullPageContainer(sbBody.ToString))
                        sbLayout.Append(PetroHomeFullPageContainer(sbBody.ToString, "terms.aspx"))
                    Else
                        sbLayout.Append(PetroHomeFullPageContainer(sbBody.ToString, "terms.aspx"))
                        'sbLayout.Append(FullPageContainer(sbBody.ToString))
                    End If

                Case "MARKET HOME"
                    'sbLayout.Append(FullPageMktContainer(sbBody.ToString))
                Case Else
                    sbLayout.Append(FullSubPageContainer(sbBody.ToString, "terms.aspx"))
            End Select

        End If

        bodyControl.Controls.Add(New LiteralControl(sbLayout.ToString))
        Return bodyControl

    End Function

    Public Function FullPageContainer(ByVal bodyContent As String) As String
        'CLONE OF FullPageMktContainer
        Dim sb As New StringBuilder
        sb.Append("<td width=""572"" colspan=""4"" height=""100%"" style=""padding-top: 16px; padding-bottom: 10px;"">")
        sb.Append(bodyContent) 'LOAD BODY CONTENT
        sb.Append("</td>")
        Return sb.ToString
    End Function

#End Region

#Region " PETROFERM HOMEPAGE LAYOUT "

    Private Function BuildPetrofermTopMenu(ByVal bu As Integer) As Control

        '"<a href=""/?bu=3"" 
        '   onMouseOver=""welcomeSectionMouseOver('PetrofermCleaning','images/nav_petroferm_cleaning_on.gif','homepagePetrofermCleaningWelcome');"" 
        '   onMouseOut=""welcomeSectionMouseOut('homepagePetrofermCleaningWelcome');"">
        '       <img src=""images/nav_petroferm_cleaning_off.gif"" alt=""Petroferm Cleaning Products"" name=""PetrofermCleaning"" width=""145"" height=""44"" border=""0"" id=""PetrofermCleaning"">
        '</a>
        '<img src=""images/nav_spacer.gif"" width=""1"" height=""44"" border=""0"" name=""notch1"" id=""notch1"">
        '<a href=""/?bu=4"" 
        '   onMouseOver=""welcomeSectionMouseOver('PetrofermFuel','images/nav_petroferm_fuel_on.gif','homepagePetrofermFuelWelcome');"" 
        '   onMouseOut=""welcomeSectionMouseOut('homepagePetrofermFuelWelcome');"">
        '       <img src=""images/nav_petroferm_fuel_off.gif"" alt=""Petroferm Fuels"" name=""PetrofermFuel"" width=""145"" height=""44"" border=""0"" id=""PetrofermFuel"">
        '</a>
        '<img src=""images/nav_spacer.gif"" width=""1"" height=""44"" border=""0"" name=""notch1"" id=""Img1"">
        '<a href="""" 
        '   onMouseOver=""welcomeSectionMouseOver('Industrial','images/nav_petroferm_industrial_on.gif','homepageIndustrialWelcome');"" 
        '   onMouseOut=""welcomeSectionMouseOut('homepageIndustrialWelcome');"">
        '       <img src=""images/nav_petroferm_industrial_off.gif"" alt=""Industrial Products"" name=""Industrial"" width=""145"" height=""44"" border=""0"" id=""Industrial"">
        '</a>
        '<img src=""images/nav_spacer.gif"" width=""1"" height=""44"" border=""0"" name=""notch3"" id=""notch3"">"


        'TODO: Will need to determine if the top menu mouseover needs to display sub-links in the menu header text area

        Dim ctl As New Control
        'Dim menuSpacer As String = "<img src=""images/nav_spacer.gif"" width=""1"" height=""44"" border=""0"">"


        'TODO: Will need to get the Business Unit ID and format the menu accordingly


        'REQUIREMENTS FOR TOP MENU FROM CMS
        '   IMAGE INFO: 
        '       MOUSEOUT IMAGE
        '       MOUSEOVER IMAGE
        '       ALT TEXT
        '       IMAGE WIDTH
        '       IMAGE HEIGHT
        '       
        '   LINK INFO:
        '       BUSINESS UNIT ID
        '       MOUSEOUT IMAGE
        '       

        'JAVASCRIPT CHANGES:
        'TODO: PETROFERM HOMEPAGE - Dynamically build the WelcomeSection name based on Business Unit name

        'List of Business Unit IDs
        Dim biArr() As String = {"3", "4", ""}
        Dim bi As String
        Dim img As HtmlImage
        Dim topNavMenuLink As HtmlAnchor

        For i As Integer = 0 To biArr.Length - 1

            bi = biArr(i).Trim

            TopNavMenuLink = New HtmlAnchor
            Select Case bi
                Case "3"
                    img = New HtmlImage
                    With img
                        .Src = "web/files/images/nav/nav_petroferm_cleaning_off.gif"
                        .ID = "PetrofermCleaning"
                        .Attributes.Add("name", "PetrofermCleaning")
                        .Alt = "Petroferm Cleaning Products"
                        .Width = 145
                        .Height = 44
                        .Border = 0
                    End With

                    With TopNavMenuLink
                        .ID = "link" + i.ToString
                        .HRef = "~/Business.aspx?bu=3"
                        .Attributes.Add("onmouseover", "welcomeSectionMouseOver('" & img.ID & "','web/files/images/nav/nav_petroferm_cleaning_on.gif','homepagePetrofermCleaningWelcome');")
                        .Attributes.Add("onmouseout", "welcomeSectionMouseOut('homepagePetrofermCleaningWelcome');")
                        .Controls.Add(img)
                    End With

                Case "4"
                    img = New HtmlImage
                    With img
                        .Src = "web/files/images/nav/nav_petroferm_fuel_off.gif"
                        .ID = "PetrofermFuel"
                        .Attributes.Add("name", "PetrofermFuel")
                        .Alt = "Petroferm Fuels"
                        .Width = 145
                        .Height = 44
                        .Border = 0
                    End With

                    With TopNavMenuLink
                        .ID = "link" + i.ToString
                        .HRef = "~/Business.aspx?bu=4"
                        .Attributes.Add("onmouseover", "welcomeSectionMouseOver('" & img.ID & "','web/files/images/nav/nav_petroferm_fuel_on.gif','homepagePetrofermFuelWelcome');")
                        .Attributes.Add("onmouseout", "welcomeSectionMouseOut('homepagePetrofermFuelWelcome');")
                        .Controls.Add(img)
                    End With

                Case ""
                    img = New HtmlImage
                    With img
                        .Src = "web/files/images/nav/nav_petroferm_industrial_off.gif"
                        .ID = "Industrial"
                        .Attributes.Add("name", "Industrial")
                        .Alt = "Industrial Products"
                        .Width = 145
                        .Height = 44
                        .Border = 0
                    End With

                    With TopNavMenuLink
                        .ID = "link" + i.ToString
                        .HRef = """"
                        .Attributes.Add("onclick", "javascript:void(0);")
                        .Attributes.Add("onmouseover", "welcomeSectionMouseOver('" & img.ID & "','web/files/images/nav/nav_petroferm_industrial_on.gif','homepageIndustrialWelcome');")
                        .Attributes.Add("onmouseout", "welcomeSectionMouseOut('homepageIndustrialWelcome');")
                        .Controls.Add(img)
                    End With

            End Select

            ctl.Controls.Add(TopNavMenuLink)
            ctl.Controls.Add(New MenuSpacer)

        Next

        Return ctl

    End Function

    Function BuildHeaderRegionWithSubLinks(ByVal currentPage As WebPage) As String

        Dim sb As New StringBuilder(String.Empty)

        sb.Append("<div id=""homepageIndustrialWelcome"" > ")
        sb.Append("    <table width=""796"" border=""0"" cellspacing=""0"" cellpadding=""0"">")
        sb.Append("        <tr> ")
        sb.Append("            <td><img src=""web/files/images/header/industrial_home_menu2.jpg"" width=""443"" height=""110"" border=""0"" alt=""Industrial Products Division""></td>")
        sb.Append("            <td width=""1"" height=""110""><img src=""web/files/images/misc/spacer.gif"" width=""1"" height=""110"" border=""0""></td>")
        sb.Append("            <td bgcolor=""#BAE0EA"" width=""352"" valign=""top"" style=""padding-top: 10px;"" onMouseOver=""window.clearTimeout(timeOut);"" onMouseOut=""welcomeSectionMouseOut();""> ")
        sb.Append("                <div class=""marketTitleBold"" style=""padding-left: 18px;"" >Welcome to</div>")
        sb.Append("                <div class=""marketTitle"" style=""padding-left: 45px;"" >Industrial Products Division</div>")
        sb.Append("                <div style=""padding-left: 50px;font-weight:bold;color: #74BBCE;"" >")
        sb.Append("                    <table border=""0"" cellpadding=""2"" cellspacing=""0"">")
        sb.Append("                        <tr>")
        sb.Append("                            <td style=""font-weight:bold;color: #74BBCE;"">")
        sb.Append("                                <a href=""/?bu=2"" class=""marketTitleLink"" >Lambent Technologies</a> &rarr;<br>")
        sb.Append("                                <a href=""/ssd.asp"" class=""marketTitleLink"" >Lambent Technologies SSD</a> &rarr;<br>")
        sb.Append("                            </td>")
        sb.Append("                            <td><img src=""web/files/images/misc/spacer.gif"" width=""10"" height=""1"" border=""0""></td>")
        sb.Append("                            <td style=""font-weight:bold;color: #74BBCE;"">")
        sb.Append("                                <a href=""/wax.asp"" class=""marketTitleLink"" >Hansotech Inc.</a> &rarr;<br>")
        sb.Append("                                <a href=""/?bu=5"" class=""marketTitleLink"" >Joseph Storey</a> &rarr;")
        sb.Append("                            </td>")
        sb.Append("                        </tr>")
        sb.Append("                    </table>")
        sb.Append("                </div>  ")
        sb.Append("            </td>")
        sb.Append("        </tr>")
        sb.Append("    </table>")
        sb.Append("</div>	")

        Return sb.ToString

    End Function

    Public Function PetroHomeFullPageContainer(ByVal bodyContent As String, ByVal termsSrc As String) As String
        Dim sb As New StringBuilder

        sb.Append("<td rowspan=""2"">")
        sb.Append("<table border=""0"" width=""572"" height=""100%"" cellpadding=""0"" cellspacing=""0"">")
        sb.Append("<tr>")
        sb.Append(bodyContent) 'LOAD BODY CONTENT
        sb.Append("</tr>")
        sb.AppendFormat("<tr><td style=""padding-top: 10px;"" valign=""bottom""><a href=""{0}"" class=""small"" onmouseover=""window.status='Review the website Terms & Conditions'; return true;"" onmouseout=""window.status=' '; return true;"">Terms & Conditions</a>&nbsp; &nbsp;<span class=""bodySmall"">&copy; Copyright 2004 - {1}, All rights reserved</span></td></tr>", termsSrc, Today.Year.ToString)
        sb.Append("</table>")
        sb.Append("</td>")
        Return sb.ToString
    End Function


#End Region


End Class
