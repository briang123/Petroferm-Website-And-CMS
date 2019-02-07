
Partial Class Register
    Inherits PassthroughBasePage

    Public Overrides Function BuildTopMenu(ByVal currentPage As WebPage) As System.Web.UI.Control
        Dim ctl As Control = MyBase.BuildTopMenuOfMarkets(currentPage, False)
        Return ctl
    End Function

    Protected Sub Page_LoadComplete(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.LoadComplete

        ' reset wizard step to 0 if not postback - 12/23/06 kr
        If Not IsPostBack Then
            Me.CreateUserWizard1.ActiveStepIndex = 0
        End If

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
        'If currentBU.BusUnit.Markets IsNot Nothing Then
        '    If currentBU.BusUnit.Markets.Count > 0 Then
        '        Dim tempElement As String = String.Empty
        '        For i As Integer = 1 To currentBU.BusUnit.Markets.Count
        '            tempElement += """homepage" & CompressStringForJavaScript(CType(currentBU.BusUnit.Markets.Item(i), Market).MarketName.ToString) & "Welcome" & """" & ","
        '        Next
        '        Me.Master.MasterTopMenuRegion.Controls.Add(BuildTopMenu(currentBU))
        '    End If
        'End If
        ' add top menu buttons for passthrough page - bg 12/31/2006
        Me.Master.MasterTopMenuRegion.Controls.Add(BuildTopMenu(currentBU))

        'SIDE NAVIGATION
        Dim sideNav As New SideNavigationModule(refBU, refPage, "SEARCH", WorkflowItem.LiveMode.Live)
        Master.MasterSideNavigationRegion.Controls.Add(New LiteralControl(sideNav.BuildSideNavigation))

        'FOOTER SECTION
        Master.MasterTermsLink.HRef = LinkGenerator.BuildCommonPageLink(currentBU.BusUnit.BusUnitID, LinkGenerator.PageType.TERMS)
        Master.MasterCopyrightText.InnerHtml = BuildCopyright()

        ' add ref to register link in login box - 12/22/06 - kr
        Master.MasterRegisterLink.HRef = "~/Register.aspx?ref=" + refBU.ToString + "," + refMkt.ToString + "," + refPage.ToString
        ' set the page title
        Master.Page.Title = "Registration"

        If Page.IsPostBack = False Then
            SetRegionInfo()
        End If
        ' ========= PREVIOUS CODE =============
        'HEADER SECTION
        'With Master.MasterLogoAndLink
        '    .HRef = LinkGenerator.BuildHomePageFriendlyPageLink(currentPage.BusUnit.BusUnitID)
        '    .Controls.Add(BuildHtmlImage(currentPage.BusUnit.LogoImage))
        'End With

        'If currentPage.PageType = "SEARCH" Or currentPage.PageType = "PASSTHROUGH" Then
        '    Master.MasterSearchRegion.Visible = False
        'Else
        '    'NEVER REACH HERE FOR THIS PAGE (FOR REFERENCE ONLY)
        '    CType(Master.FindControl("btnSimpleSearch"), Button).PostBackUrl = "~/Search.aspx?ref=" + currentPage.BusUnit.BusUnitID.ToString + "," + currentPage.CurrentMarket.MarketID.ToString + "," + MyBase.CurrentPageId.ToString + "&type=simple"
        '    Master.MasterAdvanceSearchLink.Title = "Advanced Search for " + currentPage.CurrentMarket.MarketName
        'End If

        ''TOP MENU SECTION
        ''Dim tempElement As String = String.Empty
        'If currentPage.BusUnit.Markets IsNot Nothing Then
        '    If currentPage.BusUnit.Markets.Count > 0 Then
        '        Dim tempElement As String = String.Empty
        '        For i As Integer = 1 To currentPage.BusUnit.Markets.Count
        '            tempElement += """homepage" & CompressStringForJavaScript(CType(currentPage.BusUnit.Markets.Item(i), Market).MarketName.ToString) & "Welcome" & """" & ","
        '        Next
        '        Me.Master.MasterTopMenuRegion.Controls.Add(BuildTopMenu(currentPage))
        '    End If
        'End If

        ''SIDE NAVIGATION
        'Master.MasterSideNavigationRegion.Controls.Add(New LiteralControl(currentPage.SideNavigationRegion))

        ''FOOTER SECTION
        'Master.MasterTermsLink.HRef = LinkGenerator.BuildCommonPageLink(currentPage.BusUnit.BusUnitID, LinkGenerator.PAGE_TYPE.TERMS)
        'Master.MasterCopyrightText.InnerHtml = BuildCopyright()

    End Sub


    Protected Sub CreateUserWizard1_CreatedUser(ByVal sender As Object, ByVal e As System.EventArgs) Handles CreateUserWizard1.CreatedUser

        Dim userNameTextBox As TextBox = CType(CreateUserWizardStep1.ContentTemplateContainer.FindControl("UserName"), TextBox)
        Dim fullNameTextBox As TextBox = CType(CreateUserWizardStep1.ContentTemplateContainer.FindControl("txtFullName"), TextBox)
        Dim companyNameTextBox As TextBox = CType(CreateUserWizardStep1.ContentTemplateContainer.FindControl("txtCompanyName"), TextBox)
        Dim phoneNumberTextBox As TextBox = CType(CreateUserWizardStep1.ContentTemplateContainer.FindControl("txtPhoneNumber"), TextBox)
        Dim regionPreferenceList As DropDownList = CType(CreateUserWizardStep1.ContentTemplateContainer.FindControl("ddlRegionList"), DropDownList)
        Dim interestsList As ListBox = CType(CreateUserWizardStep1.ContentTemplateContainer.FindControl("lstInterests"), ListBox)
        Dim commentsTextBox As TextBox = CType(CreateUserWizardStep1.ContentTemplateContainer.FindControl("txtComments"), TextBox)

        Dim interests As String = String.Empty
        For Each item As ListItem In InterestsList.Items
            If item.Selected = True Then
                interests += item.ToString + ", "
            End If
        Next
        If interests.Length > 1 Then
            interests = interests.Substring(0, interests.Length - 2)
        End If

        Dim user As MembershipUser = Membership.GetUser(UserNameTextBox.Text)
        user.Comment = "Interests: " + IIf(interests.Trim.Length > 0, interests, "(none)") + "; Comments: " + CommentsTextBox.Text
        Membership.UpdateUser(user)
        Dim userGuid As Object = user.ProviderUserKey

        Dim registrant As New Registrant
        With registrant
            .Region = RegionPreferenceList.SelectedItem.Text
            .MembershipId = CType(userGuid, Guid)
            .FullName = FullNameTextBox.Text
            .RegionId = RegionPreferenceList.SelectedValue
            .CompanyName = CompanyNameTextBox.Text
            .Phone = PhoneNumberTextBox.Text
            .ActiveFlag = True
        End With

        If registrant.Save() Then

            'by default, make sure that the registered user is not able to log in
            Dim appuser As New User(user)
            user.IsApproved = False
            appuser.ApproveUserById()

            'by default, all registrants get added to the WebsiteUser role (should be the only role they're assigned to)
            Roles.AddUserToRole(user.UserName, "WebsiteUser")

            'we don't want the user to automatically sign in after registration. They need to be approved by Petroferm first
            FormsAuthentication.SignOut()
            Roles.DeleteCookie()
        End If
    End Sub

    Protected Sub ContinueButton_Click(ByVal sender As Object, ByVal e As System.EventArgs)
        Dim refSearch As String = Services.GetNULLableString(Request.Params("ref"))
        Dim refBu As Integer = 0
        Dim refMkt As Integer = 0
        Dim refPage As Integer = 0

        If refSearch.Split(","c).Length = 3 Then
            refBU = Services.GetNULLableInteger(refSearch.Split(","c).GetValue(0))
            refMkt = Services.GetNULLableInteger(refSearch.Split(","c).GetValue(1))
            refPage = Services.GetNULLableInteger(refSearch.Split(","c).GetValue(2))
        End If
        If refPage <> 0 Then
            Dim pg As New WebPage(refPage, WorkflowItem.LiveMode.Live)
            If pg.URLRewritePath.Length > 0 Then
                Response.Redirect(pg.URLRewritePath)
            End If
        End If

    End Sub

    Sub SetRegionInfo()
        ' set the region dropdown list
        Dim reg As New Region
        Dim dt As DataTable = reg.GetList(WorkflowItem.LiveMode.Live)
        Dim ddlRegionList As DropDownList = CType(CreateUserWizardStep1.ContentTemplateContainer.FindControl("ddlRegionList"), DropDownList)
        With ddlRegionList
            .DataSource = dt
            .DataValueField = "RegionID"
            .DataTextField = "RegionName"
            .DataBind()
            .SelectedValue = "1"
        End With
    End Sub
End Class
