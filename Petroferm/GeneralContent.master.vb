Partial Class GeneralContent
    Inherits System.Web.UI.MasterPage
    Implements IGeneralContentMasterPage

    Public Property MasterAdvanceSearchLink() As System.Web.UI.HtmlControls.HtmlAnchor Implements IGeneralContentMasterPage.MasterAdvanceSearchLink
        Get
            Return MasterAdvancedSearch
        End Get
        Set(ByVal value As System.Web.UI.HtmlControls.HtmlAnchor)
            MasterAdvancedSearch = value
        End Set
    End Property

    Public Property MasterRegisterLink() As System.Web.UI.HtmlControls.HtmlAnchor
        Get
            Dim loginCtl As Login = TryCast(Me.Login1.FindControl("Login1"), Login)
            Return TryCast(loginCtl.FindControl("lnkRegister"), HtmlAnchor)

        End Get
        Set(ByVal value As HtmlAnchor)

            Dim loginCtl As Login = TryCast(Me.Login1.FindControl("Login1"), Login)
            If loginCtl.FindControl("lnkRegister") IsNot Nothing Then
                Dim lnk As HtmlAnchor = TryCast(loginCtl.FindControl("lnkRegister"), HtmlAnchor)
                lnk = value
            End If
        End Set
    End Property

    Public Property MasterBodyContentRegion() As System.Web.UI.WebControls.ContentPlaceHolder Implements IGeneralContentMasterPage.MasterBodyContentRegion
        Get
            Return MasterBodyContent
        End Get
        Set(ByVal value As System.Web.UI.WebControls.ContentPlaceHolder)
            MasterBodyContent = value
        End Set
    End Property

    Public Property MasterCopyrightText() As System.Web.UI.HtmlControls.HtmlGenericControl Implements IGeneralContentMasterPage.MasterCopyrightText
        Get
            Return MasterCopyright
        End Get
        Set(ByVal value As System.Web.UI.HtmlControls.HtmlGenericControl)
            MasterCopyright = value
        End Set
    End Property

    Public Property MasterLogoAndLink() As System.Web.UI.HtmlControls.HtmlAnchor Implements IGeneralContentMasterPage.MasterLogoAndLink
        Get
            Return MasterLogoHref
        End Get
        Set(ByVal value As System.Web.UI.HtmlControls.HtmlAnchor)
            MasterLogoHref = value
        End Set
    End Property

    Public Property MasterSearchRegion() As System.Web.UI.HtmlControls.HtmlTableCell Implements IGeneralContentMasterPage.MasterSearchRegion
        Get
            Return MasterSearchContainer
        End Get
        Set(ByVal value As System.Web.UI.HtmlControls.HtmlTableCell)
            MasterSearchContainer = value
        End Set
    End Property

    Public Property MasterSideNavigationRegion() As System.Web.UI.WebControls.PlaceHolder Implements IGeneralContentMasterPage.MasterSideNavigationRegion
        Get
            Return SideNavigation
        End Get
        Set(ByVal value As System.Web.UI.WebControls.PlaceHolder)
            SideNavigation = value
        End Set
    End Property

    Public Property MasterTermsLink() As System.Web.UI.HtmlControls.HtmlAnchor Implements IGeneralContentMasterPage.MasterTermsLink
        Get
            Return MasterTerms
        End Get
        Set(ByVal value As System.Web.UI.HtmlControls.HtmlAnchor)
            MasterTerms = value
        End Set
    End Property

    Public Property MasterTopMenuRegion() As System.Web.UI.HtmlControls.HtmlTableCell Implements IGeneralContentMasterPage.MasterTopMenuRegion
        Get
            Return MasterTopMenu
        End Get
        Set(ByVal value As System.Web.UI.HtmlControls.HtmlTableCell)
            MasterTopMenu = value
        End Set
    End Property

    'Public Property RegionFlags() As PlaceHolder Implements IGeneralContentMasterPage.RegionFlags
    '    Get
    '        Return RegionMaps
    '    End Get
    '    Set(ByVal value As PlaceHolder)
    '        RegionMaps = value
    '    End Set
    'End Property

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load


        Dim dtRewritePaths As DataTable = TryCast(HttpContext.Current.Cache("URL_REWRITE"), DataTable)
        If dtRewritePaths Is Nothing Then
            Dim rewriteValidator As New UrlRewriteValidator
            dtRewritePaths = rewriteValidator.LoadUrlRewritePaths
        End If

        Dim pageId As Integer = 0
        If Request.QueryString("pageId") IsNot Nothing Then
            pageId = Services.GetNULLableInteger(Request.QueryString("pageId"))
        End If

        Dim dvPaths As DataView = dtRewritePaths.DefaultView
        dvPaths.RowFilter = "PageID=" + pageId.ToString

        If dvPaths.Count > 0 Then
            For Each rowview As DataRowView In dvPaths
                Dim prodCatId As String = rowview("PC_ProdCatID").ToString
                Dim sectionId As String = rowview("SectionID").ToString
                If prodCatId > 0 Then
                    'Me.MasterBody.Attributes.Add("onload", "InitMenu('Sect" + prodCatId + "Menu','imgSect" + sectionId + "','Sect" + prodCatId + "Container','Sect" + sectionId + "MenuClick');")
                    Me.MasterBody.Attributes.Add("onload", "InitMenu('Sect" + sectionId + prodCatId + "Menu','imgSect" + sectionId + prodCatId + "','Sect" + prodCatId + "Container','Sect" + sectionId + "MenuClick');")
                Else
                    If sectionId > 0 And sectionId < 5 Then '5=registration; 6=other links; we don't want to attempt to expand links without being contained in a section
                        Me.MasterBody.Attributes.Add("onload", "InitMenu('Sect" + sectionId + "Menu','imgSect" + sectionId + "','Sect" + sectionId + "Container','Sect" + sectionId + "MenuClick');")
                    End If
                End If

            Next
        End If




        'If HttpContext.Current.Session("USER_REGION_PREFERENCE") IsNot Nothing Then
        '    Me.lblRegionContextMessage.Text = "region context: [<img src=web/files/images/misc/en-US.gif border=""0""/>]"
        'Else
        '    Me.lblRegionContextMessage.Text = String.Empty
        'End If

    End Sub
    Protected Sub Page_PreRender(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.PreRender
        'added 12/27/06 - kr - task #24
        SetRegionInfo()
    End Sub

    Protected Sub ddlRegion_SelectedIndexChanged(ByVal sender As Object, ByVal e As System.EventArgs) Handles ddlRegion.SelectedIndexChanged
        ' added 12/27/06 - kr - task #24
        Session.Add("USER_REGION_PREFERENCE", CType(sender, DropDownList).SelectedValue)
    End Sub


    Sub SetRegionInfo()
        ' added 12/27/06 - kr - task #24
        ' set the region dropdown list
        Dim reg As New Region
        Dim dt As DataTable = reg.GetList(WorkflowItem.LiveMode.Live)
        With ddlRegion
            .DataSource = dt
            .DataValueField = "RegionID"
            .DataTextField = "RegionName"
            .DataBind()
            If Session.Item("USER_REGION_PREFERENCE") IsNot Nothing Then
                If .Items.FindByValue(Session.Item("USER_REGION_PREFERENCE").ToString) IsNot Nothing Then
                    .SelectedValue = Session.Item("USER_REGION_PREFERENCE").ToString
                Else
                    ' set default value
                    .SelectedValue = "1"
                End If
            Else
                ' set default value
                .SelectedValue = "1"
            End If
        End With

        ' now get the flag image
        Dim selectedRegion As String = ddlRegion.SelectedValue
        Dim dv As DataView = dt.DefaultView
        With imgRegion
            dv.RowFilter = "RegionID = " & selectedRegion
            If dv.Count > 0 Then
                .ImageUrl = "~/" & Services.GetNULLableString(dv(0)("imagepath"))
                .ID = "imgRegion"
                .AlternateText = ddlRegion.SelectedItem.Text
            End If
        End With

    End Sub


End Class

