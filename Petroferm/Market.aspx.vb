
Partial Class MarketPage
    Inherits MarketBasePage

    Protected Sub Page_LoadComplete(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.LoadComplete

        'HEADER SECTION
        With Master.MasterLogoAndLink
            .HRef = LinkGenerator.BuildHomePageFriendlyPageLink(currentPage.BusUnit.BusUnitID)
            .Controls.Add(BuildHtmlImage(currentPage.BusUnit.LogoImage))
        End With

        CType(Master.FindControl("btnSimpleSearch"), Button).PostBackUrl = "~/Search.aspx?ref=" + currentPage.BusUnit.BusUnitID.ToString + "," + currentPage.CurrentMarket.MarketID.ToString + "," + MyBase.CurrentPageId.ToString + "&type=simple"
        Master.MasterAdvanceSearchLink.HRef = "~/Search.aspx?ref=" + currentPage.BusUnit.BusUnitID.ToString + "," + currentPage.CurrentMarket.MarketID.ToString + "," + MyBase.CurrentPageId.ToString + "&type=advanced"
        Master.MasterAdvanceSearchLink.Title = "Advanced Search for " + currentPage.CurrentMarket.MarketName

        ' add ref to register link in login box - 12/22/06 - kr
        Master.MasterRegisterLink.HRef = "~/Register.aspx?ref=" + currentPage.BusUnit.BusUnitID.ToString + "," + currentPage.CurrentMarket.MarketID.ToString + "," + MyBase.CurrentPageId.ToString

        'TOP MENU SECTION
        Dim tempElement As String = String.Empty
        If MyBase.IsMarketHomePage = True Then
            For i As Integer = 1 To currentPage.BusUnit.Markets.Count
                tempElement += """homepage" & CompressStringForJavaScript(CType(currentPage.BusUnit.Markets.Item(i), Market).MarketName.ToString) & "Welcome" & """" & ","
            Next
            Me.Master.MasterTopMenuRegion.Controls.Add(BuildTopMenu(currentPage))
        Else
            'Response.Redirect("~/404.htm")
        End If
        If tempElement.Length > 1 Then
            Master.MasterWelcomeJavaScript = tempElement.Substring(0, tempElement.Length - 1)
        End If

        'HEADER IMAGE SECTION
        Master.MasterHeaderImage.Src = BuildHeaderRegion(currentPage)

        'SIDE HEADER CONTENT
        Master.MasterHeaderSideContent.Controls.Add(BuildHeaderSideContentRegion(currentPage))

        'SIDE NAVIGATION
        'Dim nav As New SideNavigationModule(currentPage.BusUnit.BusUnitID, MyBase.CurrentPageId, currentPage.PageType, WorkflowItem.LiveMode.Live, currentPage.BusUnit.BusName)
        Dim nav As New SideNavigationModule(currentPage) 'currentPage.BusUnit.BusUnitID, MyBase.CurrentPageId, currentPage.PageType, WorkflowItem.LiveMode.Live, currentPage.BusUnit.BusName)
        Master.MasterSideNavigationRegion.Controls.Add(New LiteralControl(nav.BuildSideNavigation))

        'BODY CONTENT AREA (FULL PAGE OR SPLIT PAGE W/ SIDE MODULES + FOOTER SECTION)
        Master.MasterBodyContentRegion.Controls.Add(BuildBodyRegion(currentPage))

        'INITIALIZE THE TOP NAVIGATION HEADER GRAPHICS BY SETTING THE VISIBILITY TO HIDDEN
        Dim myStyles As String = "<style type=""text/css"">{0}</style>"
        Page.ClientScript.RegisterStartupScript(Me.GetType(), "navStyles", String.Format(myStyles, StyleObjects.ToString), False)

    End Sub

End Class






