Partial Class General
    Inherits GeneralBasePage

    Protected Sub Page_Init(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Init

        'Dim data As New DataAccess(SiteProfile.GetConnectionString, DataAccess.DataProvider.SQL)
        'Dim iCmd As IDbCommand = data.GetCommand("sp__GetRegions", CommandType.StoredProcedure, DataAccess.DataProvider.SQL)
        'Dim iParmLiveMode As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@LiveMode", DbType.Int32, WorkflowItem.LiveMode.Live, 4, ParameterDirection.Input)
        'iCmd.Parameters.Add(iParmLiveMode)
        'Dim dt As DataTable = data.GetDataTable(iCmd)
        'Dim sb As New StringBuilder(String.Empty)
        'For Each dataRow As DataRow In dt.Rows
        '    Dim lbtnMaps As New LinkButton
        '    lbtnMaps.CommandArgument = dataRow("RegionName").ToString
        '    lbtnMaps.Attributes.Add("style", "padding-right:5px;")
        '    lbtnMaps.Text = "<img src=""" + dataRow("ImagePath").ToString + """ border=""0"" alt=""" + dataRow("RegionName").ToString + """/>"

        '    AddHandler lbtnMaps.Click, AddressOf RegionChangedHandler
        '    Me.Master.RegionFlags.Controls.Add(lbtnMaps)
        'Next
        '   BuildRegionFlagsContent() ' 12/24/06 - task #24 - kr
    End Sub

    Protected Sub Page_LoadComplete(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.LoadComplete

        'HEADER SECTION
        With Master.MasterLogoAndLink
            .HRef = LinkGenerator.BuildHomePageFriendlyPageLink(currentPage.BusUnit.BusUnitID)
            .Controls.Add(BuildHtmlImage(currentPage.BusUnit.LogoImage))
        End With

        If currentPage.PageType = "SEARCH" Then
            Master.MasterSearchRegion.Visible = False
        Else
            'TODO: USE AS REFERENCE TO LINK TO PASSTHROUGH PAGETYPES
            CType(Master.FindControl("btnSimpleSearch"), Button).PostBackUrl = "~/Search.aspx?ref=" + currentPage.BusUnit.BusUnitID.ToString + "," + currentPage.CurrentMarket.MarketID.ToString + "," + MyBase.CurrentPageId.ToString + "&type=simple"
            Master.MasterAdvanceSearchLink.Title = "Advanced Search for " + currentPage.CurrentMarket.MarketName
        End If

        ' add ref to register link in login box - 12/22/06 - kr
        Master.MasterRegisterLink.HRef = "~/Register.aspx?ref=" + currentPage.BusUnit.BusUnitID.ToString + "," + currentPage.CurrentMarket.MarketID.ToString + "," + MyBase.CurrentPageId.ToString

        ' add ref to advanced search link - 12/27/06 - kr - task #57
        Master.MasterAdvanceSearchLink.HRef = "~/Search.aspx?ref=" + currentPage.BusUnit.BusUnitID.ToString + "," + currentPage.CurrentMarket.MarketID.ToString + "," + MyBase.CurrentPageId.ToString + "&type=advanced"
        Master.MasterAdvanceSearchLink.Title = "Advanced Search for " + currentPage.BusUnit.BusName

        Dim regionContainer As HtmlTableRow = CType(Master.FindControl("RegionContainer"), HtmlTableRow)
        If IsProductPage Then
            regionContainer.Visible = True
        Else
            regionContainer.Visible = False
        End If

        'TOP MENU SECTION
        Dim tempElement As String = String.Empty
        For i As Integer = 1 To currentPage.BusUnit.Markets.Count
            tempElement += """homepage" & CompressStringForJavaScript(CType(currentPage.BusUnit.Markets.Item(i), Market).MarketName.ToString) & "Welcome" & """" & ","
        Next
        Me.Master.MasterTopMenuRegion.Controls.Add(BuildTopMenu(currentPage))


        'SIDE NAVIGATION
        'Dim nav As New SideNavigationModule(currentPage.BusUnit.BusUnitID, MyBase.CurrentPageId, currentPage.PageType, WorkflowItem.LiveMode.Live, currentPage.BusUnit.BusName)
        'Dim nav As New SideNavigationModule(currentPage)
        'Master.MasterSideNavigationRegion.Controls.Add(New LiteralControl(nav.BuildSideNavigation))
        Master.MasterSideNavigationRegion.Controls.Add(New LiteralControl(currentPage.SideNavigationRegion))

        'BODY CONTENT AREA (FULL PAGE OR SPLIT PAGE W/ SIDE MODULES + FOOTER SECTION)
        Master.MasterBodyContentRegion.Controls.Add(BuildBodyRegion(currentPage))

        'FOOTER SECTION
        Master.MasterTermsLink.HRef = LinkGenerator.BuildCommonPageLink(currentPage.BusUnit.BusUnitID, LinkGenerator.PageType.TERMS)
        Master.MasterCopyrightText.InnerHtml = BuildCopyright()


    End Sub

    'Public Sub RegionChangedHandler(ByVal sender As Object, ByVal e As System.EventArgs)
    '    Session.Add("USER_REGION_PREFERENCE", CType(sender, DropDownList).SelectedValue)
    '    BuildRegionFlagsContent()
    'End Sub

    'Public Sub BuildRegionFlagsContent()
    '    ' Master.RegionFlags.Controls.Clear()
    '    Dim reg As New Region
    '    Dim dt As DataTable = reg.GetList(WorkflowItem.LiveMode.Live)
    '    Dim ddlRegion As New DropDownList
    '    With ddlRegion
    '        .AutoPostBack = True
    '        .DataSource = dt
    '        .DataValueField = "RegionID"
    '        .DataTextField = "RegionName"
    '        .DataBind()
    '        If Session.Item("USER_REGION_PREFERENCE") IsNot Nothing Then
    '            If .Items.FindByValue(Session.Item("USER_REGION_PREFERENCE").ToString) IsNot Nothing Then
    '                .SelectedValue = Session.Item("USER_REGION_PREFERENCE").ToString
    '            Else
    '                ' set default value
    '                .SelectedValue = "1"
    '            End If
    '        Else
    '            ' set default value
    '            .SelectedValue = "1"
    '        End If
    '    End With
    '    Me.Master.RegionFlags.Controls.Add(ddlRegion)

    '    AddHandler ddlRegion.SelectedIndexChanged, AddressOf RegionChangedHandler


    '    ' now get the flag image
    '    Dim imgRegion As New Image
    '    Dim selectedRegion As String = ddlRegion.SelectedValue
    '    Dim dv As DataView = dt.DefaultView
    '    With imgRegion
    '        dv.RowFilter = "RegionID = " & selectedRegion
    '        If dv.Count > 0 Then
    '            .ImageUrl = "~/" & Services.GetNULLableString(dv(0)("imagepath"))
    '            .ID = "imgRegion"
    '            .AlternateText = ddlRegion.SelectedItem.Text
    '            Me.Master.RegionFlags.Controls.Add(New LiteralControl("&nbsp;"))
    '            Me.Master.RegionFlags.Controls.Add(imgRegion)
    '        End If
    '    End With


    '    'Dim sb As New StringBuilder(String.Empty)
    '    'For Each dataRow As DataRow In dt.Rows
    '    '    Dim lbtnMaps As New LinkButton
    '    '    lbtnMaps.CommandArgument = dataRow("RegionName").ToString
    '    '    lbtnMaps.Attributes.Add("style", "padding-right:5px;")
    '    '    lbtnMaps.Text = "<img src=""" + dataRow("ImagePath").ToString + """ border=""0"" alt=""" + dataRow("RegionName").ToString + """/>"

    '    '    AddHandler lbtnMaps.Click, AddressOf RegionChangedHandler
    '    '    Me.Master.RegionFlags.Controls.Add(lbtnMaps)
    '    'Next()
    'End Sub

End Class
