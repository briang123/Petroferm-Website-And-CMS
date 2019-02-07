Partial Class MarketLanding
    Inherits System.Web.UI.MasterPage
    Implements IMarketMasterPage

    Public JavaScriptBodyInitArrayList As String = String.Empty
    Public JavaScriptWelcomeArrayList As String = String.Empty

    Public Property MasterTopMenuRegion() As System.Web.UI.HtmlControls.HtmlTableCell Implements IMarketMasterPage.MasterTopMenuRegion
        Get
            Return MasterTopMenu
        End Get
        Set(ByVal value As System.Web.UI.HtmlControls.HtmlTableCell)
            MasterTopMenu = value
        End Set
    End Property

    Public Property MasterLogoAndLink() As System.Web.UI.HtmlControls.HtmlAnchor Implements IMarketMasterPage.MasterLogoAndLink
        Get
            Return MasterLogoHref
        End Get
        Set(ByVal value As System.Web.UI.HtmlControls.HtmlAnchor)
            MasterLogoHref = value
        End Set
    End Property

    Public Property MasterSideNavigationRegion() As System.Web.UI.WebControls.PlaceHolder Implements IMarketMasterPage.MasterSideNavigationRegion
        Get
            Return Me.SideNavigation
        End Get
        Set(ByVal value As System.Web.UI.WebControls.PlaceHolder)
            Me.SideNavigation = value
        End Set
    End Property

    Public Property MasterAdvanceSearchLink() As System.Web.UI.HtmlControls.HtmlAnchor Implements IMarketMasterPage.MasterAdvanceSearchLink
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


    Public Property MasterHeaderImage() As System.Web.UI.HtmlControls.HtmlImage Implements IMarketMasterPage.MasterHeaderImage
        Get
            Return MasterMarketLandingHeaderImage
        End Get
        Set(ByVal value As System.Web.UI.HtmlControls.HtmlImage)
            MasterMarketLandingHeaderImage = value
        End Set
    End Property

    Public Property MasterWelcomeJavaScript() As String Implements IMarketMasterPage.MasterWelcomeJavaScript
        Get
            Return JavaScriptWelcomeArrayList
        End Get
        Set(ByVal value As String)
            JavaScriptWelcomeArrayList = value
        End Set
    End Property

    Public Property MasterHeaderSideContent() As System.Web.UI.WebControls.PlaceHolder Implements IMarketMasterPage.MasterHeaderSideContent
        Get
            Return phMasterHeaderSideContent
        End Get
        Set(ByVal value As System.Web.UI.WebControls.PlaceHolder)
            phMasterHeaderSideContent = value
        End Set
    End Property

    Public Property MasterBodyContentRegion() As System.Web.UI.WebControls.ContentPlaceHolder Implements IMarketMasterPage.MasterBodyContentRegion
        Get
            Return MasterBodyContent
        End Get
        Set(ByVal value As System.Web.UI.WebControls.ContentPlaceHolder)
            MasterBodyContent = value
        End Set
    End Property

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
                'If prodCatId > 0 Or sectionId > 0 Then
                '    Me.MasterBody.Attributes.Add("onload", "InitMenu('Sect" + sectionId + "Menu','imgSect" + sectionId + "','Sect" + sectionId + "Container','Sect" + sectionId + "MenuClick');")
                'End If

                If prodCatId > 0 Then
                    'Me.MasterBody.Attributes.Add("onload", "InitMenu('Sect" + prodCatId + "Menu','imgSect" + sectionId + "','Sect" + prodCatId + "Container','Sect" + sectionId + "MenuClick');")
                    Me.MasterBody.Attributes.Add("onload", "InitMenu('Sect" + sectionId + prodCatId + "Menu','imgSect" + prodCatId + "','Sect" + prodCatId + "Container','Sect" + sectionId + "MenuClick');")
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


End Class

