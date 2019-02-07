
Partial Class CmsDeploymentJobDetail
    Inherits CMSPage
    Private _editPage As String = "DeploymentJobEdit.aspx"
    Private _listPage As String = "DeploymentJobList.aspx"
    Private Const MaxLogoWidth As Integer = 100
    Private Const MaxLogoHeight As Integer = 50
    Private Const DeleteColumn As Integer = 0
    Private Const EditColumn As Integer = 1
    Private Const ViewColumn As Integer = 2
    Private _currJob As DeploymentJob
    Private Property CurrentJobId() As Integer
        Get
            If ViewState("CurrentJobID") IsNot Nothing Then
                Return Services.GetNULLableInteger(ViewState("CurrentJobID"))
            Else
                Return 0
            End If
        End Get
        Set(ByVal value As Integer)
            ViewState("CurrentJobID") = value
        End Set
    End Property

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        lblMessage.Text = ""
        ' The ID is sent from the list page in session -- if it's an add, 0 is passed as the ID
        If Session("FormJobID") Is Nothing Then
            Response.Redirect(_listPage)
        Else
            _currJob = New DeploymentJob(Services.GetNULLableInteger(Session("FormJobID")))
            Me.CurrentJobID = Session("FormJobID")
            ' also set the dropdown list on the master page
            _currJob.Fill()
            Session("ActiveJobID") = _currJob.DeploymentJobID
            ' if the job info could not be retrieved, go back to list page
            If _currJob.JobName.Length = 0 Then
                Response.Redirect(_listPage)
            End If
            ' fill the job info section
            With _currJob
                Me.lblJobName.Text = .JobName
                Me.lblJobDesc.Text = .JobDescription
                Me.lblReviewedBy.Text = .ReviewByName.ToString
                Me.lblApprovedBy.Text = .ApprovedByName.ToString
                Me.lblDeployedBy.Text = .DeployedByName.ToString
                Me.lblDeploymentDate.Text = .DeploymentDate.ToShortDateString
                Me.lblWorkflowStatus.Text = .WorkflowStatus
                Me.lblLastModByName.Text = .LastModByName.ToString
                Me.lblLastModDate.Text = .LastModDate.ToShortDateString & " " & .LastModDate.ToShortTimeString

            End With
            ' Session("FormJobID") = Nothing
        End If
    End Sub

    Protected Sub Page_PreRenderComplete(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.PreRenderComplete
        Me.Master.PageTitle = "Deployment Job Detail for " & _currJob.JobName
        Me.Master.HideBusinessUnitDropdown()
        Me.Master.HideJobDropdown()

        If Me.gvPages.Rows.Count = 0 Then
            lblPageListNone.Visible = True
        End If

        If Me.gvPageModules.Rows.Count = 0 Then
            lblPageModuleListHeading.Visible = True
        End If

        If Me.gvProducts.Rows.Count = 0 Then
            lblProductListNone.Visible = True
        End If
        If Me.gvProductAttributes.Rows.Count = 0 Then
            lblProductAttributesNone.Visible = True
        End If
        If Me.gvSearchAttributes.Rows.Count = 0 Then
            Me.lblSearchAttributesNone.Visible = True
        End If
        If Me.gvBusUnitList.Rows.Count = 0 Then
            Me.lblBusinessUnitsNone.Visible = True
        End If
        If Me.gvMarket.Rows.Count = 0 Then
            Me.lblMarketsNone.Visible = True
        End If
        Me.Master.ActiveJobID = _currJob.DeploymentJobID

        ' if just a reader, hide the change workflow status section
        If AppUser.IsInRoleOnly(SiteProfile.UserRole.Reader.ToString) Then
            MakePageReadOnly()
        End If

        Dim nextStatus As String = ""

        ' use the current job status to find out what the next step should be
        ' also, the user must be the related role to accept the changes and move it
        ' to the next step in the workflow process
        Select Case _currJob.WorkflowStatus
            Case "WORKING"
                If My.User.IsInRole(SiteProfile.UserRole.Author.ToString) Then
                    nextStatus = "PENDING REVIEW"
                Else
                    Me.trChangeWorkflowStatus.Visible = False
                End If
            Case "PENDING REVIEW"
                If My.User.IsInRole(SiteProfile.UserRole.Reviewer.ToString) Then
                    nextStatus = "PENDING APPROVAL"
                Else
                    Me.trChangeWorkflowStatus.Visible = False
                End If
            Case "PENDING APPROVAL"
                If My.User.IsInRole(SiteProfile.UserRole.Approver.ToString) Then
                    nextStatus = "PENDING DEPLOYMENT"
                Else
                    Me.trChangeWorkflowStatus.Visible = False
                End If
            Case "PENDING DEPLOYMENT"
                If My.User.IsInRole(SiteProfile.UserRole.Deployer.ToString) Then
                    nextStatus = "LIVE"
                    Me.btnAccept.Text = "Deploy Job"
                Else
                    Me.trChangeWorkflowStatus.Visible = False
                End If
            Case "LIVE"
                Me.trChangeWorkflowStatus.Visible = False
                Me.pnlChangeDetail.Visible = False
                Session("ActiveJobID") = Nothing
        End Select


        'Select Case True
        '    '     == AUTHOR ==
        '    Case My.User.IsInRole(SiteProfile.UserRole.Author.ToString)
        '        If currJob.WorkflowStatus = "WORKING" Then
        '            nextStatus = "PENDING REVIEW"
        '        End If
        '        ' == REVIEWER ==
        '    Case My.User.IsInRole(SiteProfile.UserRole.Reviewer.ToString)
        '        If currJob.WorkflowStatus = "WORKING" Or _
        '            currJob.WorkflowStatus = "PENDING REVIEW" Then
        '            nextStatus = "PENDING APPROVAL"
        '        End If
        '        ' == APPROVER ==
        '    Case My.User.IsInRole(SiteProfile.UserRole.Approver.ToString)
        '        If currJob.WorkflowStatus = "WORKING" Or _
        '            currJob.WorkflowStatus = "PENDING REVIEW" Or _
        '            currJob.WorkflowStatus = "PENDING APPROVAL" Then
        '            nextStatus = "PENDING DEPLOYMENT"
        '        End If

        '        ' == DEPLOYER ==
        '    Case My.User.IsInRole(SiteProfile.UserRole.Deployer.ToString)

        '        If currJob.WorkflowStatus = "WORKING" Or _
        '            currJob.WorkflowStatus = "PENDING REVIEW" Or _
        '            currJob.WorkflowStatus = "PENDING APPROVAL" Or _
        '            currJob.WorkflowStatus = "PENDING DEPLOYMENT" Then
        '            nextStatus = "LIVE"
        '        End If
        '        ' == ADMINISTRATOR ==
        '    Case My.User.IsInRole(SiteProfile.UserRole.Administrator.ToString)

        '        If currJob.WorkflowStatus = "WORKING" Or _
        '            currJob.WorkflowStatus = "PENDING REVIEW" Or _
        '            currJob.WorkflowStatus = "PENDING APPROVAL" Or _
        '            currJob.WorkflowStatus = "PENDING DEPLOYMENT" Then
        '            nextStatus = "LIVE"
        '        End If
        'End Select
        Select Case nextStatus
            Case "LIVE"
                lblInstructions.Text = "When you click Deploy Job, the changes will be updated to the LIVE site. " & _
                    "If you click Reject Changes, the workflow status will be set back to WORKING."
            Case "WORKING", "PENDING REVIEW", "PENDING APPROVAL", "PENDING DEPLOYMENT"
                lblInstructions.Text = "When you click Accept Changes, the workflow status " & _
                    "of this job will be set to " & nextStatus & ". If you click Reject Changes, " & _
                    "the workflow status will be set back to WORKING."
            Case Else
                MakePageReadOnly()
        End Select
    End Sub

    Private Sub MakePageReadOnly()
        Me.trChangeWorkflowStatus.Visible = False
        Me.lnkManageBUs.Visible = False
        Me.lnkManageMarkets.Visible = False
        Me.lnkManagePages.Visible = False
        Me.lnkManageProductAttributes.Visible = False
        Me.lnkManageProducts.Visible = False
        Me.lnkManageSearchAttributes.Visible = False
    End Sub

    Protected Sub btnAccept_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles btnAccept.Click
        ' need to find out what role user is in
        ' and set the workflow status accordingly
        Dim currJob As New DeploymentJob(Me.CurrentJobID)
        currJob.Fill()
        Dim nextStatus As String = ""


        Select Case currJob.WorkflowStatus
            Case "WORKING"
                If My.User.IsInRole(SiteProfile.UserRole.Author.ToString) Then
                    nextStatus = "PENDING REVIEW"
                End If
            Case "PENDING REVIEW"
                If My.User.IsInRole(SiteProfile.UserRole.Reviewer.ToString) Then
                    nextStatus = "PENDING APPROVAL"
                End If
            Case "PENDING APPROVAL"
                If My.User.IsInRole(SiteProfile.UserRole.Approver.ToString) Then
                    nextStatus = "PENDING DEPLOYMENT"
                End If
            Case "PENDING DEPLOYMENT"
                If My.User.IsInRole(SiteProfile.UserRole.Deployer.ToString) Then
                    nextStatus = "LIVE"
                End If
        End Select

        ' now save the job information (run both the Save and SetWorkflowStatus because the latter updates all job-related records)
        With currJob
            ' need to fill info first
            .LastModBy = Me.ActiveUserID
            Select Case nextStatus
                Case "PENDING APPROVAL"
                    .ReviewBy = Me.ActiveUserID
                Case "PENDING DEPLOYMENT"
                    .ApprovedBy = Me.ActiveUserID
                Case "LIVE"
                    .DeployedBy = Me.ActiveUserID
            End Select
            '
            .WorkflowStatus = nextStatus
            If .WorkflowStatus <> "LIVE" Then
                .Save()
                .SetWorkflowStatus()
            Else 'DEPLOY JOB!!
                ' the job needs to be set to pending approval status first before it can be deployed
                If .DeployCMSContent() Then
                    .Save()
                End If
                Me.ActiveJobID = 0
                Session("ActiveJobID") = Nothing
            End If
        End With
        Response.Redirect("DeploymentJobDetail.aspx")
    End Sub

    Protected Sub btnReject_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles btnReject.Click
        Dim currJob As New DeploymentJob(Me.CurrentJobID)
        With currJob
            .Fill()
            .ReviewBy = 0
            .ApprovedBy = 0
            .DeployedBy = 0
            .LastModBy = Me.ActiveUserID
            .WorkflowStatus = "WORKING"
            .Save()
            .SetWorkflowStatus()
        End With
        Response.Redirect("DeploymentJobDetail.aspx")
    End Sub

    Protected Sub gvBusUnitList_RowDataBound(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewRowEventArgs) Handles gvBusUnitList.RowDataBound
        ' this adds a confirmation message to the delete command
        If e.Row.RowType = DataControlRowType.DataRow Then
            Dim ibtnDelete As ImageButton = e.Row.FindControl("ibtnDelete")
            ibtnDelete.Attributes.Add("onclick", "javascript:return " & _
              "confirm('Are you sure you want to delete " & _
              DataBinder.Eval(e.Row.DataItem, "BusinessUnitName") + "?')")

            ' set logo image for business unit using image control in a template column
            Dim imgLogo As Image = e.Row.FindControl("imgLogo")
            ' height and width values are not going to be stored (12/14/06 - kr)
            'Dim intWidth As Integer = Convert.ToInt16(DataBinder.Eval(e.Row.DataItem, "Width"))
            'If intWidth > MAX_LOGO_WIDTH Then intWidth = MAX_LOGO_WIDTH
            'Dim intHeight As Integer = Convert.ToInt16(DataBinder.Eval(e.Row.DataItem, "Height"))
            'If intHeight > MAX_LOGO_HEIGHT Then intHeight = MAX_LOGO_HEIGHT
            With imgLogo
                .Width = MaxLogoWidth
                .Height = MaxLogoHeight
                .AlternateText = DataBinder.Eval(e.Row.DataItem, "Alt").ToString
                .ImageUrl = "~/" & DataBinder.Eval(e.Row.DataItem, "ImagePath").ToString
            End With

            '' hide the edit/delete button for item that is marked for deletion
            'If Convert.ToBoolean(DataBinder.Eval(e.Row.DataItem, "MarkedForDeletion")) Then
            '    e.Row.Cells(EDIT_COLUMN).Text = String.Empty
            '    e.Row.Cells(DELETE_COLUMN).Text = String.Empty
            'ElseIf Convert.ToInt32(DataBinder.Eval(e.Row.DataItem, "BusinessUnitID")) = 1 Then
            '    e.Row.Cells(DELETE_COLUMN).Text = String.Empty
            'End If

            '' -- part of other job check --
            '' if the item is part of another job and in non-LIVE status, then hide edit/delete icons
            'If Convert.ToInt32(DataBinder.Eval(e.Row.DataItem, "DeploymentJobID")) <> _
            '        Me.ActiveJobID And _
            '    DataBinder.Eval(e.Row.DataItem, "WorkflowStatus").ToString <> "LIVE" Then
            '    e.Row.Cells(EDIT_COLUMN).Text = CMSGlobals.BlankIcon
            '    e.Row.Cells(DELETE_COLUMN).Text = CMSGlobals.BlankIcon
            'End If

        End If
    End Sub

    'Protected Sub gvPages_RowCommand(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewCommandEventArgs) Handles gvPages.RowCommand
    '    ' If multiple ButtonField column fields are used, use the
    '    ' CommandName property to determine which button was clicked.
    '    Select Case e.CommandName
    '        Case "GoToEditPage"
    '            ' Get the ID to be edited
    '            Dim jobID As Integer = Convert.ToInt32(e.CommandArgument)
    '            Session("FormMode") = CMSFormUtils.FormMode.Edit
    '            Session("FormJobID") = jobID
    '            ' redirect to edit page
    '            Response.Redirect(EDIT_PAGE)
    '        Case "GoToReadPage"
    '            ' Get the ID to be viewed
    '            Dim jobID As Integer = Convert.ToInt32(e.CommandArgument)
    '            Session("FormMode") = CMSFormUtils.FormMode.Read
    '            Session("FormJobID") = jobID
    '            ' redirect to edit page
    '            Response.Redirect(EDIT_PAGE)
    '        Case "DeleteItem"
    '            Dim delMarket As New Market(Convert.ToInt32(e.CommandArgument))
    '            With delMarket
    '                .JobID = Me.ActiveJobID
    '                .LastModBy = Me.ActiveUserID
    '                If .Delete() Then
    '                    lblMessage.Text = "The deployment job has been deleted."
    '                    lblMessage.CssClass = "infoMessage"
    '                End If
    '            End With

    '            ' refresh grid view data
    '            gvPages.DataBind()
    '    End Select

    'End Sub

    'Protected Sub gvPages_RowDataBound(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewRowEventArgs) Handles gvPages.RowDataBound
    '    'TODO: CMS - Market - ADD CAPABILITY CHECK FOR ALLOWING DELETE/EDIT BUTTONS TO DISPLAY

    '    ' this adds a confirmation message to the delete command
    '    If e.Row.RowType = DataControlRowType.DataRow Then
    '        Dim ibtnDelete As ImageButton = e.Row.FindControl("ibtnDelete")
    '        ibtnDelete.Attributes.Add("onclick", "javascript:return " & _
    '          "confirm('Are you sure you want to delete " & _
    '          DataBinder.Eval(e.Row.DataItem, "JobName") + "?')")

    '        '' hide the edit/delete button for item that is marked for deletion
    '        ' DON'T NEED THIS FOR JOB LIST
    '        'If Convert.ToBoolean(DataBinder.Eval(e.Row.DataItem, "MarkedForDeletion")) Then
    '        '    e.Row.Cells(EDIT_COLUMN).Text = String.Empty
    '        '    e.Row.Cells(DELETE_COLUMN).Text = String.Empty
    '        'End If

    '        ' -- part of other job check --
    '        ' if the item is part of another job and in non-LIVE status, then hide edit/delete icons
    '        ' use the current job
    '        'If Convert.ToInt32(DataBinder.Eval(e.Row.DataItem, "DeploymentJobID")) <> _
    '        '        Me.ActiveJobID And _
    '        '    DataBinder.Eval(e.Row.DataItem, "WorkflowStatus").ToString <> "LIVE" Then
    '        '    e.Row.Cells(EDIT_COLUMN).Text = CMSGlobals.BlankIcon
    '        '    e.Row.Cells(DELETE_COLUMN).Text = CMSGlobals.BlankIcon
    '        'End If


    '    End If



    'End Sub


End Class
