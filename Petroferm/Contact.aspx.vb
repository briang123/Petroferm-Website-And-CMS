
Partial Class Contact
    Inherits PassthroughBasePage

    Private _mFormType As String

    Public Overrides Function BuildTopMenu(ByVal currentPage As WebPage) As System.Web.UI.Control
        Dim ctl As Control = MyBase.BuildTopMenuOfMarkets(currentPage, False)
        Return ctl
    End Function

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load

        If Request.QueryString("type") IsNot Nothing Then
            _mFormType = Request.QueryString("type").ToString.ToUpper
        End If

        If _mFormType = "FEEDBACK" Then
            Me.PageTitle.InnerHtml = "Provide Feedback"
            Me.BodyText.InnerHtml = SiteProfile.GetProvideFeedbackMessage()
        Else
            Me.PageTitle.InnerHtml = "Request Information"
            Me.BodyText.InnerHtml = SiteProfile.GetRequestInfoMessage()
        End If

        If Page.IsPostBack = False Then

            Me.radioNo.Checked = True

            Dim ht As Hashtable

            If _mFormType = "FEEDBACK" Then
                ht = Services.GetHashFromConfig("FEEDBACK_CATEGORIES")
            Else
                ht = Services.GetHashFromConfig("REQUEST_INFO_CATEGORIES")
            End If

            ddlCategories.DataSource = ht
            ddlCategories.DataValueField = "Value"
            ddlCategories.DataTextField = "Key"
            ddlCategories.DataBind()

        End If

    End Sub



    Protected Sub Submit_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles Submit.Click

        Dim category As String = String.Empty
        Dim li As ListItem = ddlCategories.Items.FindByText(ddlCategories.SelectedItem.Text)
        If li IsNot Nothing Then
            category = li.Text
        End If

        Dim sb As New StringBuilder
        With sb
            .Append("Full Name: " + Me.txtFullName.ToString + vbCrLf)
            .Append("Company Name: " + Me.txtCompanyName.ToString + vbCrLf)
            .Append("Phone Number: " + Me.txtPhoneNumber.ToString + vbCrLf)
            .Append("Email: " + Me.txtEmail.ToString + vbCrLf)
            .Append("Category: " + category + vbCrLf)
            .Append("Comments: " + Me.txtComments.ToString + vbCrLf)
        End With

        Try

            Dim mail As New EMail
            If li IsNot Nothing Then
                mail.ToEmail = li.Value.ToString
                mail.FromEmail = SiteProfile.GetFeedbacRequestFromEmail()
                mail.Body = sb.ToString
                mail.Priority = Net.Mail.MailPriority.Normal
                mail.Subject = "WEBSITE EMAIL: " + _mFormType + " regarding " + li.Text
                mail.Send()
            End If

            Dim thankYou As String = ""

            If _mFormType = "FEEDBACK" Then
                thankYou = "Your feedback has been successfully submitted to our customer service group. "
                If Me.radioYes.Checked = True Then
                    thankYou += "A representative will be following up with you shortly regarding your feedback. "
                End If
                thankYou += "Again, we appreciate the information you can provide in order for us to improve your experience with us."
            Else
                thankYou = "Your information request has been successfully submitted to our customer service group. You should receive a response shortly. Again, we thank you for your interest in our services."
            End If

            If thankYou.Length > 0 Then
                Me.ThankYouMessage.InnerHtml = thankYou
            End If

        Catch ex As Exception
            Throw New NLTException("An error occurred while attempting to send an email", ex, "Contact.aspx.vb", "Submit_Click()")
        End Try

    End Sub

    Protected Sub Page_LoadComplete(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.LoadComplete

        'Dim refBU As Integer = 0
        'Dim refMkt As Integer = 0
        'Dim refPage As Integer = 0
        'Dim refProd As Integer = 0


        'refBU = Services.GetNULLableInteger(Request.QueryString("bu"))
        'refMkt = Services.GetNULLableInteger(Request.QueryString("mkt"))
        'refPage = Services.GetNULLableInteger(Request.QueryString("pageId"))
        'refProd = Services.GetNULLableInteger(Request.QueryString("pcat"))

        'If refPage = 0 Then 'user got here through an outside link somehow or manually entered the search page url
        '    refPage = 1 'use the petroferm homepage context
        'End If

        ''I change the name of this variable from currentPage like everywhere else because we only care about the business unit type stuff
        'Dim currentBU As New WebPage(refPage, WorkflowItem.LiveMode.Live)

        'HEADER SECTION
        With Master.MasterLogoAndLink
            .HRef = LinkGenerator.BuildHomePageFriendlyPageLink(currentPage.BusUnit.BusUnitID)
            .Controls.Add(BuildHtmlImage(currentPage.BusUnit.LogoImage))
        End With

        Master.MasterSearchRegion.Visible = (MyBase.IsSearchPage = False)
        Dim regionContainer As HtmlTableRow = CType(Master.FindControl("RegionContainer"), HtmlTableRow)
        regionContainer.Visible = False

        'TOP MENU SECTION

        If currentPage.BusUnit.Markets IsNot Nothing Then
            If currentPage.BusUnit.Markets.Count > 0 Then
                Dim tempElement As String = String.Empty
                For i As Integer = 1 To currentPage.BusUnit.Markets.Count
                    tempElement += """homepage" & CompressStringForJavaScript(CType(currentPage.BusUnit.Markets.Item(i), Market).MarketName.ToString) & "Welcome" & """" & ","
                Next

            End If
            Me.Master.MasterTopMenuRegion.Controls.Add(BuildTopMenu(currentPage))
        End If

        'SIDE NAVIGATION
        'Dim sideNav As New SideNavigationModule(refBU, refPage, "GENERAL", WorkflowItem.LiveMode.Live)
        Master.MasterSideNavigationRegion.Controls.Add(New LiteralControl(currentPage.SideNavigationRegion))

        'FOOTER SECTION
        Master.MasterTermsLink.HRef = LinkGenerator.BuildCommonPageLink(currentPage.BusUnit.BusUnitID, LinkGenerator.PageType.TERMS)
        Master.MasterCopyrightText.InnerHtml = BuildCopyright()

        ' add ref to register link in login box - 12/22/06 - kr
        Master.MasterRegisterLink.HRef = "~/Register.aspx?ref=" + currentPage.BusUnit.BusUnitID.ToString + "," + currentPage.CurrentMarket.MarketID.ToString + "," + MyBase.CurrentPageId.ToString

        ' add ref to advanced search link - 12/27/06 - kr - task #57
        Master.MasterAdvanceSearchLink.HRef = "~/Search.aspx?ref=" + currentPage.BusUnit.BusUnitID.ToString + "," + currentPage.CurrentMarket.MarketID.ToString + "," + MyBase.CurrentPageId.ToString + "&type=advanced"
        Master.MasterAdvanceSearchLink.Title = "Advanced Search for " + currentPage.BusUnit.BusName


    End Sub


End Class
