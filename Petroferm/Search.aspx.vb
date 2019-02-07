Imports System.Text.RegularExpressions

Partial Class Search
    Inherits PassthroughBasePage

    Protected WithEvents LoginView1 As LoginView
    Private _mBusinessUnitId As Integer = 0
    Private _mMarketId As Integer = 0
    Private _vsCacheDocs As DataTable

    Public Property ProductsByBu() As DataTable
        Get
            _vsCacheDocs = TryCast(ViewState.Item("SEARCH_PAGE_PRODUCT_DOCS_BY_BU"), DataTable)
            If _vsCacheDocs IsNot Nothing Then
                Return _vsCacheDocs
            Else
                Return Nothing
            End If
        End Get
        Set(ByVal value As DataTable)
            ViewState.Add("SEARCH_PAGE_PRODUCT_DOCS_BY_BU", value)
        End Set
    End Property

    Public Property BusinessUnitId() As Integer
        Get
            Return _mBusinessUnitId
        End Get
        Set(ByVal value As Integer)
            _mBusinessUnitId = value
        End Set
    End Property

    Public Property MarketId() As Integer
        Get
            Return _mMarketId
        End Get
        Set(ByVal value As Integer)
            _mMarketId = value
        End Set
    End Property

    Protected Enum SearchType As Integer
        NotSet = -1
        Simple = 0
        Advanced = 1
    End Enum

    Protected Sub radioButton_CheckedChanged(ByVal sender As Object, ByVal e As System.EventArgs)

        Dim refQryString As String = Request.QueryString("ref").ToString

        GridAdvancedSearch.Visible = False
        Me.chkSearchAttributes.ClearSelection()
        Me.lblSearchResults.Visible = False
        Me.ResetValidatorMessages()

        If radioSimple.Checked Then
            MultiView1.ActiveViewIndex = SearchType.Simple
            Me.GridAdvancedSearch.Visible = False
            ' kr 12/22/06 - do a redirect to retain search type
            Response.Redirect("Search.aspx?ref=" & refQryString & "&type=simple")
        ElseIf radioAdvance.Checked Then
            MultiView1.ActiveViewIndex = SearchType.Advanced
            Me.GridSimpleSearch.Visible = False
            ' kr 12/22/06 - do a redirect to retain search type
            Response.Redirect("Search.aspx?ref=" & refQryString & "&type=advanced")
        End If

    End Sub

    Private Sub ResetControls(ByVal radio As RadioButton, ByVal defaultView As Integer)
        radio.Checked = True
        MultiView1.ActiveViewIndex = defaultView
        GridAdvancedSearch.Visible = False
        Me.lblSearchResults.Visible = False
        If radio.ID = "radioAdvanced" Then
            Me.lblSearchAttributeInstructions.Visible = False
        End If
    End Sub

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load

        Dim refBu As Integer = 0
        Dim refMkt As Integer = 0
        Dim refPage As Integer = 0
        Dim refSearch As String = Services.GetNULLableString(Request.Params("ref"))

        If refSearch <> String.Empty Then
            If refSearch.Split(","c).Length = 3 Then
                refBU = Services.GetNULLableInteger(refSearch.Split(","c).GetValue(0))
                refMkt = Services.GetNULLableInteger(refSearch.Split(","c).GetValue(1))
                refPage = Services.GetNULLableInteger(refSearch.Split(","c).GetValue(2))

                Me.BusinessUnitId = refBU
                Me.MarketId = refMkt
            End If
        End If


        If Page.IsPostBack = False Then
            If Me.ProductsByBu Is Nothing Then
                Dim prodDocs As New Document
                Me.ProductsByBu = prodDocs.GetListByBU(Me.BusinessUnitId, 1)
            End If

            Dim bus As New BusinessUnit
            Dim dtBus As DataTable = bus.GetList(WorkflowItem.LiveMode.Live)
            Dim dvBus As DataView = dtBus.DefaultView
            dvBus.RowFilter = "BusinessUnitId > 1"
            ddlBusiness.DataSource = dvBus
            ddlBusiness.DataValueField = "BusinessUnitID"
            ddlBusiness.DataTextField = "BusinessUnitName"
            ddlBusiness.DataBind()
            ddlBusiness.Items.Insert(0, New ListItem("--SELECT BUSINESS--", ""))

            If Me.BusinessUnitId > 0 Then
                If Me.BusinessUnitId > 1 Then
                    ddlBusiness.Items.FindByValue(Me.BusinessUnitId).Selected = True
                Else
                    ddlBusiness.Items(0).Selected = True
                End If

                Dim market As New Market
                Dim dv As DataView = market.GetListByBU(Me.BusinessUnitId, WorkflowItem.LiveMode.CMS)
                ddlMarkets.DataSource = dv
                ddlMarkets.DataValueField = "MarketId"
                ddlMarkets.DataTextField = "MarketName"
                ddlMarkets.DataBind()

                Dim li As New ListItem("--SELECT MARKET--", "")
                ddlMarkets.Items.Insert(0, li)

                'ddlMarkets.Items.FindByValue(Me.MarketId).Selected = True
            End If

            ' get data for region ddl - 12/22/06 - kr
            Dim reg As New Region
            With ddlRegion
                .DataSource = reg.GetList(WorkflowItem.LiveMode.Live)
                .DataValueField = "RegionID"
                .DataTextField = "RegionName"
                .DataBind()
                ' set default to english
                .SelectedValue = "1"
            End With

            lblSimpleSearchInstructions.Visible = True
            Me.lblSimpleSearchInstructions.Text = SiteProfile.GetInstructions("SIMPLE_SEARCH")
            Me.lblAdvancedSearchInstructions.Text = SiteProfile.GetInstructions("SIMPLE_SEARCH_KEYWORDS")

            If Services.GetNULLableString(Request.Params("type")).ToUpper = "SIMPLE" Then
                ResetControls(radioSimple, 0)
                Me.txtSimpleSearch.Text = Services.GetNULLableString(Request.Params("ctl00$txtSearch"))
                ' kr 12/22/06
                If Me.txtSimpleSearch.Text.Length > 0 Then
                    DoSearch(Me.txtSimpleSearch.Text, SearchType.Simple)
                End If



            ElseIf Services.GetNULLableString(Request.Params("type")).ToUpper = "ADVANCED" Then
                ResetValidatorMessages()
                Me.lblSearchAttributeInstructions.Visible = False
                Me.lblAdvancedSearchInstructions.Visible = True
                Me.lblAdvancedSearchInstructions.Text = SiteProfile.GetInstructions("ADVANCED_SEARCH")
                Me.lblSearchAttributeInstructions.Text = SiteProfile.GetInstructions("ADVANCED_SEARCH_ATTRIBUTE")

                ResetControls(radioAdvance, 1)
            Else
                If SiteProfile.GetDefaultSearchView = "SIMPLE" Then

                    ResetControls(radioSimple, 0)
                Else
                    ResetValidatorMessages()
                    Me.lblSearchAttributeInstructions.Visible = False
                    Me.lblAdvancedSearchInstructions.Visible = True
                    Me.lblAdvancedSearchInstructions.Text = SiteProfile.GetInstructions("ADVANCED_SEARCH")
                    Me.lblSearchAttributeInstructions.Text = SiteProfile.GetInstructions("ADVANCED_SEARCH_ATTRIBUTE")

                    ResetControls(radioAdvance, 1)
                End If

            End If

        Else
            'ddlMarkets.Items.FindByValue(ddlMarkets.SelectedValue).Selected = True
        End If
    End Sub

    Protected Sub Page_LoadComplete(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.LoadComplete

        Dim refBu As Integer = 0
        Dim refMkt As Integer = 0
        Dim refPage As Integer = 0
        Dim refSearch As String = Services.GetNULLableString(Request.Params("ref"))

        If refSearch.Split(","c).Length = 3 Then
            refBU = Services.GetNULLableInteger(refSearch.Split(","c).GetValue(0))
            refMkt = Services.GetNULLableInteger(refSearch.Split(","c).GetValue(1))
            refPage = Services.GetNULLableInteger(refSearch.Split(","c).GetValue(2))
        End If

        If refPage = 0 Then     'user got here through an outside link somehow or manually entered the search page url
            refPage = 1         'use the petroferm homepage context
        End If

        'I change the name of this variable from currentPage like everywhere else because we only care about the business unit type stuff
        Dim currentBu As New WebPage(refPage, WorkflowItem.LiveMode.Live)

        'HEADER SECTION
        With Master.MasterLogoAndLink
            .HRef = LinkGenerator.BuildHomePageFriendlyPageLink(refBU)
            .Controls.Add(BuildHtmlImage(currentBU.BusUnit.LogoImage))
        End With

        Master.MasterSearchRegion.Visible = False

        'TOP MENU SECTION
        'If currentBU.BusUnit.Markets IsNot Nothing Or currentBU.BusUnit.BusUnitID = 1 Then
        '    If currentBU.BusUnit.Markets.Count > 0 Or currentBU.BusUnit.BusUnitID = 1 Then
        '        Dim tempElement As String = String.Empty
        '        For i As Integer = 1 To currentBU.BusUnit.Markets.Count
        '            tempElement += """homepage" & CompressStringForJavaScript(CType(currentBU.BusUnit.Markets.Item(i), Market).MarketName.ToString) & "Welcome" & """" & ","
        '        Next
        '        Me.Master.MasterTopMenuRegion.Controls.Add(BuildTopMenu(currentBU))
        '    End If
        'End If

        'If currentBU.BusUnit.Markets.Count > 0 Or refMkt > 0 Then
        'Dim tempElement As String = String.Empty
        'For i As Integer = 1 To currentBU.BusUnit.Markets.Count
        'tempElement += """homepage" & CompressStringForJavaScript(CType(currentBU.BusUnit.Markets.Item(i), Market).MarketName.ToString) & "Welcome" & """" & ","
        'Next
        ' add top menu buttons for passthrough page - bg 12/31/2006
        Me.Master.MasterTopMenuRegion.Controls.Add(BuildTopMenu(currentBU))
        'End If



        'SIDE NAVIGATION
        Dim sideNav As New SideNavigationModule(refBU, refPage, "SEARCH", WorkflowItem.LiveMode.Live)
        Master.MasterSideNavigationRegion.Controls.Add(New LiteralControl(sideNav.BuildSideNavigation))

        'FOOTER SECTION
        Master.MasterTermsLink.HRef = LinkGenerator.BuildCommonPageLink(currentBU.BusUnit.BusUnitID, LinkGenerator.PageType.TERMS)
        Master.MasterCopyrightText.InnerHtml = BuildCopyright()



        ' change page title label to include current business unit name
        If Services.GetNULLableString(Request.Params("type")).ToUpper = "SIMPLE" Then
            Me.lblPageTitle.Text = "Search Page for " & currentBU.BusUnit.BusName.ToString
        End If


    End Sub


    Protected Sub DoSearch(ByVal searchTerm As String, ByVal searchTarget As SearchType)

        Dim data As New DataAccess(SiteProfile.GetConnectionString, DataAccess.DataProvider.SQL)
        Dim iCon As IDbConnection = data.GetConnection(SiteProfile.GetConnectionString, DataAccess.DataProvider.SQL)
        Dim iCmd As IDbCommand
        Dim iParmBusId As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@BusUnitID", DbType.Int32, Me.BusinessUnitId, 4, ParameterDirection.Input)
        Dim iParmKeywords As IDbDataParameter
        Dim iParmAttributeList As IDbDataParameter
        Dim iParmMktId As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@MarketID", DbType.Int32, ddlMarkets.SelectedValue, 4, ParameterDirection.Input)
        Dim searchKeyword As String = String.Empty
        If searchTarget = SearchType.Advanced Then

            searchKeyword = txtAdvanceSearchCriteria.Text.Trim

            Dim s As String = String.Empty
            For Each li As ListItem In Me.chkSearchAttributes.Items
                If li.Selected = True Then s += li.Value.ToString + ","
            Next
            If s.Length > 0 Then
                s = s.Substring(0, s.Length - 1)
            End If

            iCmd = data.GetCommand("sp__GetAdvanceSearchResults", CommandType.StoredProcedure, DataAccess.DataProvider.SQL)
            iParmKeywords = data.GetParameter(DataAccess.DataProvider.SQL, "@Keywords", DbType.String, txtAdvanceSearchCriteria.Text, 100, ParameterDirection.Input)
            iParmAttributeList = data.GetParameter(DataAccess.DataProvider.SQL, "@SearchAttribIdList", DbType.String, s.ToString, 300, ParameterDirection.Input)
            With iCmd.Parameters
                .Add(iParmKeywords)
                .Add(iParmMktID)
                .Add(iParmAttributeList)
            End With
        Else
            searchKeyword = txtSimpleSearch.Text.Trim
            iCmd = data.GetCommand("sp__GetSimpleSearchResults", CommandType.StoredProcedure, DataAccess.DataProvider.SQL)
            iParmKeywords = data.GetParameter(DataAccess.DataProvider.SQL, "@Keywords", DbType.String, txtSimpleSearch.Text, 100, ParameterDirection.Input)
            With iCmd.Parameters
                .Add(iParmKeywords)
                If iParmBusID.Value = 0 Then iParmBusID.Value = 1
                .Add(iParmBusID)
            End With

        End If

        Dim dt As DataTable = data.GetDataTable(iCmd)

        Dim dsSearchData As New DataSet
        Services.MoveTableToNewDataSet(dsSearchData, dt)
        Dim dtSearchData As DataTable = dsSearchData.Tables(0)
        For i As Integer = dtSearchData.Rows.Count - 1 To 0 Step -1
            If SearchKeywordExists(dtSearchData.Rows(i)("ProductBlurb"), searchKeyword) Then
                dtSearchData.Rows(i)("ProductBlurb") = Me.StripHTML(dtSearchData.Rows(i)("ProductBlurb"))
            Else
                dtSearchData.Rows(i).Delete()
            End If
        Next
        dtSearchData.AcceptChanges()

        If searchTarget = SearchType.Simple Then

            GridSimpleSearch.DataSource = dtSearchData
            GridSimpleSearch.DataBind()
            GridSimpleSearch.Visible = True

            GridAdvancedSearch.Visible = False
        Else
            GridAdvancedSearch.DataSource = dtSearchData
            GridAdvancedSearch.DataBind()
            GridAdvancedSearch.Visible = True

            GridSimpleSearch.Visible = False
        End If


        Dim results As String = String.Empty
        If searchTarget = SearchType.Advanced Then
            results = "<br/>We found <b>" + dtSearchData.Rows.Count.ToString + "</b> product(s) matching your search condition for the <b>" + ddlMarkets.SelectedItem.Text.ToUpper + "</b> market.<br/>"
        Else
            results = "<br/>We found <b>" + dtSearchData.Rows.Count.ToString + "</b> result(s) matching your search condition of <b>" + Me.txtSimpleSearch.Text.ToUpper + "</b><br/><br/>"
        End If

        lblSearchResults.Text = results
        lblSearchResults.Visible = True
    End Sub


    Protected Sub btnSearch_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles Button1.Click
        Dim searchTerm As String = String.Empty
        If MultiView1.ActiveViewIndex > -1 Then
            Select Case MultiView1.ActiveViewIndex
                Case SearchType.Simple
                    DoSearch(txtSimpleSearch.Text, MultiView1.ActiveViewIndex)
                Case SearchType.Advanced
                    If ControlsValidated() = True Then
                        DoSearch(txtAdvanceSearchCriteria.Text, MultiView1.ActiveViewIndex)
                    End If
            End Select
        End If
    End Sub


    Protected Sub ddlBusiness_SelectedIndexChanged(ByVal sender As Object, ByVal e As System.EventArgs) Handles ddlBusiness.SelectedIndexChanged

        ResetValidatorMessages()
        Me.chkSearchAttributes.Visible = False

        Dim searchAttrib As New SearchAttribute
        If ddlBusiness.SelectedValue <> "" Then

            ddlMarkets.Enabled = True
            Dim market As New Market
            Dim dv As DataView = market.GetListByBU(ddlBusiness.SelectedValue, WorkflowItem.LiveMode.CMS)
            ddlMarkets.DataSource = dv
            ddlMarkets.DataValueField = "MarketId"
            ddlMarkets.DataTextField = "MarketName"
            ddlMarkets.DataBind()

            Dim li As New ListItem("--SELECT MARKET--", "")
            ddlMarkets.Items.Insert(0, li)

        End If

    End Sub

    Protected Sub ddlMarkets_SelectedIndexChanged(ByVal sender As Object, ByVal e As System.EventArgs) Handles ddlMarkets.SelectedIndexChanged

        ResetValidatorMessages()

        Dim searchAttrib As New SearchAttribute
        If ddlMarkets.SelectedValue <> "" Then

            Dim dt As DataTable = searchAttrib.GetList(Me.BusinessUnitId, Services.GetNULLableInteger(ddlMarkets.SelectedValue), False)
            With chkSearchAttributes
                .ClearSelection()
                .DataSource = dt
                .DataValueField = "SearchAttribTypeID"
                .DataTextField = "SearchAttributeName"
                .DataBind()
            End With

            If chkSearchAttributes.Items.Count > 0 Then
                chkSearchAttributes.Visible = True
                Me.lblSearchAttributeInstructions.Visible = True
            Else
                chkSearchAttributes.Visible = False
                Me.lblSearchAttributeInstructions.Visible = False
            End If
        Else
            Me.lblSearchAttributeInstructions.Visible = False
            chkSearchAttributes.Visible = False
        End If
    End Sub

    Sub ResetValidatorMessages()
        Me.lblNoMarketOrProductValidationMessage.Visible = False
        Me.lblSearchAttributesValidateMessage.Visible = False
    End Sub

    Function ControlsValidated() As Boolean

        ResetValidatorMessages()
        Me.lblNoMarketOrProductValidationMessage.Text = "Please specify your search conditions by choosing a market or entering a product name."

        Dim valid As Boolean = False
        If Me.ddlMarkets.Items(0).Selected = True Then

            If Me.txtAdvanceSearchCriteria.Text.Trim.Length = 0 Then
                Me.lblNoMarketOrProductValidationMessage.Visible = True
                Me.lblSearchAttributesValidateMessage.Visible = False
                valid = False
            Else
                valid = True
            End If
        ElseIf ddlMarkets.SelectedValue <> "" Then
            If Me.chkSearchAttributes.Items.Count = 0 And _
                    Me.txtAdvanceSearchCriteria.Text.Trim.Length = 0 Then

                Me.lblNoMarketOrProductValidationMessage.Text = "There are no products to search for in this market."
                Me.lblNoMarketOrProductValidationMessage.Visible = True

                valid = False
            Else
                Me.lblNoMarketOrProductValidationMessage.Visible = False
                If SearchAttributesValid() = False Then
                    Me.lblSearchAttributesValidateMessage.Visible = True
                    valid = False
                Else
                    valid = True
                End If
            End If
        Else
            Me.lblNoMarketOrProductValidationMessage.Visible = False
            If SearchAttributesValid() = False Then
                Me.lblSearchAttributesValidateMessage.Visible = True
                valid = False
            Else
                valid = True
            End If

        End If

        Return valid

    End Function

    Function SearchAttributesValid() As Boolean
        Dim hasItemSelected As Boolean = False
        For Each li As ListItem In Me.chkSearchAttributes.Items
            If li.Selected = True Then
                HasItemSelected = True
                Exit For
            End If
        Next
        Return HasItemSelected
    End Function

    Protected Sub GridSimpleSearch_PageIndexChanging(ByVal sender As Object, ByVal e As GridViewPageEventArgs)

        DoSearch(txtSimpleSearch.Text, MultiView1.ActiveViewIndex)
        GridSimpleSearch.PageIndex = e.NewPageIndex
        GridSimpleSearch.DataBind()

    End Sub


    Protected Sub GridAdvancedSearch_PageIndexChanging(ByVal sender As Object, ByVal e As GridViewPageEventArgs)

        DoSearch(Me.txtAdvanceSearchCriteria.Text, MultiView1.ActiveViewIndex)
        GridAdvancedSearch.PageIndex = e.NewPageIndex
        GridAdvancedSearch.DataBind()

    End Sub

    Public Function SearchKeywordExists(ByVal blurb As String, ByVal searchValue As String) As Boolean
        blurb = Me.StripHTML(blurb)
        Dim m As Match = Regex.Match(blurb, searchValue, RegexOptions.IgnoreCase)
        Return m.Success
    End Function

    Public Function GetHighlightedSearchCondition(ByVal blurb As String, ByVal searchValue As String, ByVal link As String) As String

        blurb = blurb.Replace("\n", "").Replace("\r", "")
        Dim blurbOffset As Integer = SiteProfile.GetSearchResultsDescriptionOffset()

        Dim moreBeginInfo As String = "..."
        Dim moreEndInfo As String = "&nbsp;...&nbsp;<a href=""" + link + """ title=""Read more about " + searchValue.ToLower + """>more</a>&nbsp;<img src=""web/files/images/misc/arrow_gray_right.gif"" border=""0"" />"
        Dim stylizedValue As String = _
                String.Format("<span style=""color:{0};font-weight:{1};background-color:{2};"">{3}</span>", _
                    SiteProfile.GetSearchResultsSelectedForeColor, _
                        SiteProfile.GetSearchResultsSelectedFontWeight, _
                            SiteProfile.GetSearchResultsBGColor, _
                                searchValue.ToUpper)
        Dim startPosition As Integer = 0
        Dim endPosition As Integer = searchValue.Length
        Dim parseLength As Integer = 0

        'Dim searchValuePosition As Integer = blurb.IndexOf(searchValue)
        Dim m As Match = Regex.Match(blurb, searchValue, RegexOptions.IgnoreCase)
        Dim searchValuePosition As Integer = m.Index

        'get starting position of display blurb
        If searchValuePosition > blurbOffset Then
            startPosition = searchValuePosition - blurbOffset
        Else
            startPosition = 0
            moreBeginInfo = ""
        End If


        If blurb.Length > (searchValuePosition + blurbOffset) Then
            endPosition = searchValuePosition + blurbOffset
            parseLength = (endPosition + searchValue.Length) - startPosition
        Else
            If blurb.Length > blurbOffset Then
                endPosition = (blurb.Length - startPosition) + blurbOffset
                parseLength = (endPosition + searchValue.Length) - startPosition
                If startPosition + parseLength > blurb.Length Then
                    parseLength = blurb.Length - startPosition
                End If
            Else
                endPosition = blurb.Length
                parseLength = endPosition
                moreEndInfo = ""
            End If
        End If

        blurb = blurb.Substring(startPosition, parseLength)

        Dim parsedBlurb As String = moreBeginInfo + Regex.Replace(blurb, searchValue, stylizedValue, RegexOptions.IgnoreCase) + moreEndInfo
        Return parsedBlurb

    End Function

    Function StripHtml(ByVal html As String) As String
        Return Regex.Replace(html, "<[^>]+>", "")
    End Function

    Public Function GetProductName(ByVal name As String) As String
        If name.Trim.Length > 0 Then
            Return " - " + name.ToUpper
        Else
            Return ""
        End If
    End Function

    Public ReadOnly Property CurrentRegionContext() As String
        Get
            Return Services.GetNULLableString(Request.Params("region"))
        End Get
    End Property

    Public Function GetProductDocumentByProductId(ByVal productId As Integer, ByVal docAuth As Integer) As String

        Dim pdfProdCombo As String = String.Empty
        Dim dv As DataView = Me.ProductsByBu.DefaultView
        Dim region As String = Me.ddlRegion.Items(ddlRegion.SelectedIndex).Text
        Dim selectedRegion As String = Me.ddlRegion.Items.FindByValue(ddlRegion.SelectedValue).Value.ToString
        dv.RowFilter = "ProductID=" + ProductId.ToString + " AND RegionName='" + SelectedRegion + "'"

        If docAuth = False Then
            'Dim pdfImage As String = "<img src=""web/files/images/misc/icon_pdf_text.gif"" />&nbsp;"
            Dim regionImage As String = "<img src=""web/files/images/misc/" + GetRegionImage(SelectedRegion) + """ />&nbsp;"
            Dim prodLink As String = "<a href=""{0}"" title=""{1}"">{1}</a>&nbsp;&nbsp;"
            For Each rowView As DataRowView In dv
                pdfProdCombo += String.Format(prodLink, "GetFile.aspx?file=" + rowView.Item("DocumentID").ToString, rowView.Item("ContentType").ToString)
            Next
            If dv.Count > 0 Then
                pdfProdCombo = "<tr><td style=""background-color:#eeeeee;"" width=""100%"">" + regionImage + "&nbsp;" + pdfProdCombo + "</td></tr>"
            Else
                pdfProdCombo = String.Empty
            End If
        End If

        If Roles.IsUserInRole(User.Identity.Name, "WebsiteUser") Then
            Return pdfProdCombo
        Else
            Return String.Empty
        End If

    End Function

    Public Function GetProductDocumentByProductId(ByVal productId As Integer, ByVal region As String) As String

        Dim pdfProdCombo As String = String.Empty
        Dim dv As DataView = Me.ProductsByBu.DefaultView
        Dim docAuth As Boolean = False

        dv.RowFilter = "ProductID=" + ProductId.ToString + " AND RegionName='" + region + "'"

        If docAuth = True Then
            'Dim pdfImage As String = "<img src=""web/files/images/misc/icon_pdf_text.gif"" />&nbsp;"
            Dim regionImage As String = "<img src=""web/files/images/misc/" + GetRegionImage(region) + """ />&nbsp;"
            Dim prodLink As String = "<a href=""{0}"" title=""{1}"">{1}</a>"

            For Each rowView As DataRowView In dv
                pdfProdCombo += regionImage + String.Format(prodLink, "GetFile.aspx?file=" + rowView.Item("DocumentID").ToString, rowView.Item("ContentType").ToString)
            Next

            If dv.Count > 0 Then
                pdfProdCombo = "<tr><td width=""100%"">" + regionImage + "&nbsp;" + pdfProdCombo + "</td></tr>"
            Else
                pdfProdCombo = ""
            End If
        End If

        If Roles.IsUserInRole(User.Identity.Name, "WebsiteUser") Then
            Return pdfProdCombo
        Else
            Return String.Empty
        End If

    End Function

    Function GetRegionImage(ByVal region As String) As String

        Dim img As String = ""

        Select Case region.ToUpper
            Case "USA - ENGLISH" : img = "en-US.gif"
            Case "UNITED KINGDOM - ENGLISH" : img = "en-GB.gif"
            Case "SPANISH" : img = "es-MX.gif"
            Case "CANADIAN - ENGLISH" : img = "fr-CA.gif"
            Case "CANADIAN - FRENCH" : img = "fr-CA.gif"
            Case "ITALIAN" : img = "it-IT.gif"
            Case "GERMAN" : img = "de-DE.gif"
            Case "CHINESE - SIMPLIFIED" : img = "hz-Hant.gif"
            Case "CHINESE - TRADITIONAL" : img = "hz-Hant.gif"
            Case "JAPANESE" : img = "ja-JP.gif"
        End Select

        Return img

    End Function

    Public Overrides Function BuildTopMenu(ByVal currentPage As WebPage) As System.Web.UI.Control
        Dim ctl As Control = MyBase.BuildTopMenuOfMarkets(currentPage, False)
        Return ctl
    End Function

End Class


