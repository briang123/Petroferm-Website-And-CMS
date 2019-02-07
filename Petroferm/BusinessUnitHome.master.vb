Partial Class BusinessUnitHome
    Inherits System.Web.UI.MasterPage
    Implements IBusinessUnitMasterPage

    Public JavaScriptWelcomeArrayList As String = String.Empty

    Private Function BuildTopMenu(ByVal bu As Integer) As Control

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

        'TODO: Will need to get the Business Unit ID and format the menu accordingly

        'JAVASCRIPT CHANGES:
        'TODO: Dynamically build the WelcomeSection name based on Business Unit name

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

    Public Function BuildCountryFlagRegion() As System.Web.UI.Control Implements IBusinessUnitMasterPage.BuildCountryFlagRegion
        Return New LiteralControl("&nbsp;")
    End Function

    Public Property MasterAdvanceSearchLink() As System.Web.UI.HtmlControls.HtmlAnchor Implements IPetrofermMasterPage.MasterAdvanceSearchLink
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

    Public Property MasterBodyContentRegion() As System.Web.UI.Control
        Get
            Return MasterBodyContent
        End Get
        Set(ByVal value As System.Web.UI.Control)
            MasterBodyContent = value
        End Set
    End Property


    Public Property MasterBodyRegion() As System.Web.UI.HtmlControls.HtmlTableCell Implements IPetrofermMasterPage.MasterBodyRegion
        Get
            Return Me.MasterBodyContentRegion
        End Get
        Set(ByVal value As System.Web.UI.HtmlControls.HtmlTableCell)
            Me.MasterBodyContentRegion = value
        End Set
    End Property

    Public Property MasterBodyTag() As System.Web.UI.HtmlControls.HtmlGenericControl Implements IPetrofermMasterPage.MasterBodyTag
        Get
            Return Me.MasterBody
        End Get
        Set(ByVal value As System.Web.UI.HtmlControls.HtmlGenericControl)
            Me.MasterBody = value
        End Set
    End Property

    Public Property MasterLogoAndLink() As System.Web.UI.HtmlControls.HtmlAnchor Implements IPetrofermMasterPage.MasterLogoAndLink
        Get
            Return MasterLogoHref
        End Get
        Set(ByVal value As System.Web.UI.HtmlControls.HtmlAnchor)
            MasterLogoHref = value
        End Set
    End Property

    Public Property MasterSideNavigationRegion() As System.Web.UI.WebControls.PlaceHolder Implements IPetrofermMasterPage.MasterSideNavigationRegion
        Get
            Return Me.SideNavigation
        End Get
        Set(ByVal value As System.Web.UI.WebControls.PlaceHolder)
            Me.SideNavigation = value
        End Set
    End Property

    Public Property MasterTopMenuRegion() As System.Web.UI.HtmlControls.HtmlTableCell Implements IPetrofermMasterPage.MasterTopMenuRegion
        Get
            Return MasterTopMenu
        End Get
        Set(ByVal value As System.Web.UI.HtmlControls.HtmlTableCell)
            MasterTopMenu = value
        End Set
    End Property

    Public Property MasterWelcomeJavaScript() As String Implements IPetrofermMasterPage.MasterWelcomeJavaScript
        Get
            Return JavaScriptWelcomeArrayList
        End Get
        Set(ByVal value As String)
            JavaScriptWelcomeArrayList = value
        End Set
    End Property

    Public Property MasterHeaderImageRegion() As System.Web.UI.WebControls.ContentPlaceHolder Implements IPetrofermMasterPage.MasterHeaderImageRegion
        Get
            Return MasterHeaderImage
        End Get
        Set(ByVal value As System.Web.UI.WebControls.ContentPlaceHolder)
            MasterHeaderImage = value
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

                If sectionId > 0 Then
                    Me.MasterBody.Attributes.Add("onload", "InitMenu('Sect" + sectionId + "Menu','imgSect" + sectionId + "','Sect" + sectionId + "Container','Sect" + sectionId + "MenuClick');")
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





