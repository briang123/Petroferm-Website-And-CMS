Imports System.Configuration.ConfigurationManager
imports System.Web.Security

Partial Class MasterCMS
    Inherits System.Web.UI.MasterPage
    Public Property PageTitle() As String
        Get
            Return lblPageTitle.text
        End Get
        Set(ByVal value As String)
            lblPageTitle.Text = value.Trim
            ' also set head title
            Me.HeadTitle.Text = "Content Management System ~ " & value.Trim
        End Set
    End Property

    Public Sub HideBusinessUnitDropdown()
        Me.ddlBusinessUnit.Visible = False
        Me.lblBusUnit.Visible = False
    End Sub

    Public Sub HideJobDropdown()
        Me.ddlJob.Visible = False
        Me.btnSetActiveJob.Visible = False
        Me.lblJob.Visible = False
    End Sub

    Public ReadOnly Property SelectedBusinessUnit() As String
        Get
            Return ddlBusinessUnit.SelectedItem.Text
        End Get
    End Property
    Public Property ActiveJobId() As Integer
        Get
            If IsNumeric(Me.ddlJob.SelectedValue) Then
                Return Convert.ToInt32(Me.ddlJob.SelectedValue)
            Else
                Return 0
            End If
        End Get
        Set(ByVal value As Integer)
            Me.ddlJob.SelectedValue = value.ToString
        End Set
    End Property


    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load

        ' hide the tree view side navigation if it's the login page
        If Me.Page.Request.Path.ToLower.IndexOf("login.aspx") > 0 Then
            Me.SideNavTree.Visible = False
        End If
        ' set logo here
        Me.imgLogo.ImageUrl = "~/" & AppSettings("LOGO_IMAGE_DIRECTORY") & "Petrofermlogo.png"


        If Not (My.User.IsInRole("Administrators") Or _
           My.User.IsInRole("Deployer") Or _
           My.User.IsInRole("Approver") Or _
           My.User.IsInRole("Reviewer") Or _
           My.User.IsInRole("Author") Or _
           My.User.IsInRole("Reader")) Then
            HideJobDropdown()
            HideBusinessUnitDropdown()

        End If


    End Sub

    Protected Sub Page_PreRender(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.PreRender
        ' TODO: CMS - hide ddl's if not logged in
        If My.User.Name.Length = 0 Then
            Me.lblBusUnit.Visible = False
            Me.ddlBusinessUnit.Visible = False
            Me.lblJob.Visible = False
            Me.ddlJob.Visible = False
            Me.btnSetActiveJob.Visible = False
        ElseIf AppUser.IsInRoleOnly("Reader") Then
            Me.lblJob.Visible = False
            Me.ddlJob.Visible = False
            Me.btnSetActiveJob.Visible = False
        End If

    End Sub

    Protected Sub ddlBusinessUnit_PreRender(ByVal sender As Object, ByVal e As System.EventArgs) Handles ddlBusinessUnit.PreRender

        If My.User.IsAuthenticated Then

            ' TODO: CMS - check to make sure user can get in here
            Dim memUser As MembershipUser = Membership.GetUser(My.User.Name)
            Dim u As New User(memUser)
            Dim li As ListItem = Nothing

            With ddlBusinessUnit
                .DataSource = u.GetBUByUserID()
                .DataValueField = "BusinessUnitID"
                .DataTextField = "BusinessUnitName"
                .DataBind()
                ' see if there's a session value first
                If Session("BusUnitID") IsNot Nothing Then
                    li = .Items.FindByValue(Session("BusUnitID").ToString)
                End If
                ' if not, then use default bu
                If li Is Nothing Then
                    li = .Items.FindByValue(u.GetDefaultBUByUserID.ToString)
                End If
                ' set the selected value of the ddl
                If li IsNot Nothing Then
                    li.Selected = True
                    Session("BusUnitID") = li.Value
                End If

                .Items.Insert(0, New ListItem("-- Select Business Unit --", "0"))
            End With
        End If

        'If (Session("BusUnitID") & "").length = 0 Then
        '    ' TODO: CMS - find out the user's business unit or set to Petroferm if it
        '    ' is a full admin user
        '    ' default it to 1 - PETROFERM, INC.
        '    Me.ddlBusinessUnit.SelectedValue = "1"
        '    Session("BusUnitID") = 1
        'Else
        '    Dim li As ListItem = Me.ddlBusinessUnit.Items.FindByValue(Session("BusUnitID").ToString)
        '    If li IsNot Nothing Then
        '        Me.ddlBusinessUnit.SelectedValue = Session("BusUnitID").ToString
        '    End If

        'End If
    End Sub

    Protected Sub ddlBusinessUnit_SelectedIndexChanged(ByVal sender As Object, ByVal e As System.EventArgs) Handles ddlBusinessUnit.SelectedIndexChanged
        Session("BusUnitID") = Me.ddlBusinessUnit.SelectedValue
        Response.Redirect("~/cms/")
    End Sub

    Protected Sub ddlJob_PreRender(ByVal sender As Object, ByVal e As System.EventArgs) Handles ddlJob.PreRender
        ' add initial empty "select" module type item
        ' if it's not there already
        ' this is a b&w -- taking it out for now 12/17/06 KR
        With Me.ddlJob
            If .Items.Count > 0 Then
                If .Items(0).Value <> "SELECT" Then
                    Dim liSelect As New ListItem("-- Select Deployment Job --", "SELECT")
                    .Items.Insert(0, liSelect)
                    'TODO: CMS - Allow user to create a new job (if they are in any role except Reader
                    'Dim liCreate As New ListItem("-- Create New Job --", "CREATE")
                    '.Items.Insert(1, liCreate)
                End If
                Me.btnSetActiveJob.Text = "Set Active Job"
            ElseIf Not AppUser.IsInRoleOnly("Reader") Then
                Me.ddlJob.Visible = False
                Me.btnSetActiveJob.Text = "Create New Job"
            Else
                Me.ddlJob.Visible = False
                Me.btnSetActiveJob.Visible = False
                Me.lblJob.Visible = False
            End If

            If Session("ActiveJobID") IsNot Nothing Then
                .SelectedValue = Session("ActiveJobID").ToString
            End If
        End With


    End Sub
    Protected Sub btnSetActiveJob_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles btnSetActiveJob.Click
        If Me.ddlJob.Items.Count > 0 Then
            Select Case Me.ddlJob.SelectedValue
                Case "SELECT"
                    Session("ActiveJobID") = Nothing
                    Response.Redirect("~/cms/")
                Case Else
                    Session("ActiveJobID") = Convert.ToInt32(Me.ddlJob.SelectedValue)
                    Dim job As New DeploymentJob(Convert.ToInt32(Me.ddlJob.SelectedValue))
                    job.Fill()
                    Session("ActiveJob") = job
                    Response.Redirect("~/cms/")
            End Select
        Else
            Session("FormMode") = CMSFormUtils.FormMode.Edit
            Session("FormJobID") = 0 ' meaning adding a new one
            Response.Redirect("DeploymentJobEdit.aspx")
        End If

    End Sub

    Protected Sub lbtnViewJobDetails_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles lbtnViewJobDetails.Click
        Session("FormJobID") = Convert.ToInt32(Me.ddlJob.SelectedValue)
        ' redirect to edit page
        Response.Redirect("DeploymentJobDetail.aspx")
    End Sub

End Class