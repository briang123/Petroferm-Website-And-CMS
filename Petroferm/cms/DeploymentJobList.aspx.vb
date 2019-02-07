
Partial Class CmsDeploymentJobList
    Inherits CMSPage
    Private _editPage As String = "DeploymentJobEdit.aspx"
    Private _detailPage As String = "DeploymentJobDetail.aspx"
    Private Const DeleteColumn As Integer = 0
    Private Const EditColumn As Integer = 1
    Private Const ViewColumn As Integer = 2
    Private Const DetailsColumn As Integer = 3

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        lblMessage.Text = ""
    End Sub

    Protected Sub lbtnAdd_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles lbtnAdd.Click
        Session("FormMode") = CMSFormUtils.FormMode.Edit
        Session("FormJobID") = 0 ' meaning adding a new one
        Response.Redirect(_editPage)
    End Sub

    Protected Sub Page_PreRenderComplete(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.PreRenderComplete

        ' if it's a reader user, hide the add button
        If AppUser.IsInRoleOnly("Reader") Then
            Me.lbtnAdd.Visible = False
            Me.Master.PageTitle = "View Deployment Jobs"
        Else
            Me.Master.PageTitle = "Manage Deployment Jobs"

            Me.Master.HideBusinessUnitDropdown()
            Me.Master.HideJobDropdown()
        End If

    End Sub

    Protected Sub gvJobs_RowCommand(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewCommandEventArgs) Handles gvJobs.RowCommand
        ' If multiple ButtonField column fields are used, use the
        ' CommandName property to determine which button was clicked.
        Select Case e.CommandName
            Case "GoToEditPage"
                ' Get the ID to be edited
                Dim jobId As Integer = Convert.ToInt32(e.CommandArgument)
                Session("FormMode") = CMSFormUtils.FormMode.Edit
                Session("FormJobID") = jobID
                ' redirect to edit page
                Response.Redirect(_editPage)
            Case "GoToReadPage"
                ' Get the ID to be viewed
                Dim jobId As Integer = Convert.ToInt32(e.CommandArgument)
                Session("FormMode") = CMSFormUtils.FormMode.Read
                Session("FormJobID") = jobID
                ' redirect to edit page
                Response.Redirect(_editPage)
            Case "GoToDetailPage"
                ' Get the ID to be viewed
                Dim jobId As Integer = Convert.ToInt32(e.CommandArgument)
                '  Session("FormMode") = CMSFormUtils.FormMode.Read
                Session("FormJobID") = jobID
                ' redirect to edit page
                Response.Redirect(_detailPage)
            Case "RollbackItem"
                Dim rollbackJob As New DeploymentJob(Convert.ToInt32(e.CommandArgument))
                With rollbackJob
                    .LastModBy = Me.ActiveUserID
                    If .Rollback() Then
                        lblMessage.Text = "The changes for the deployment job have been rolled back to the live content."
                        lblMessage.CssClass = "infoMessage"
                    End If
                End With
                ' refresh grid view data
                gvJobs.DataBind()
        End Select

    End Sub

    Protected Sub gvJobs_RowDataBound(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewRowEventArgs) Handles gvJobs.RowDataBound
        ' this adds a confirmation message to the delete command
        If e.Row.RowType = DataControlRowType.DataRow Then
            Dim jobName As String = DataBinder.Eval(e.Row.DataItem, "JobName")

            ' replace any apostrophes
            jobName = jobName.Replace("'", "\'")
            Dim ibtnRollback As ImageButton = e.Row.FindControl("ibtnRollback")
            ibtnRollback.Attributes.Add("onclick", "javascript:return " & _
              "confirm('Are you sure you want to roll back the changes for " & _
              jobName & "?')")

            '' hide the edit/delete button for item that is marked for deletion
            ' DON'T NEED THIS FOR JOB LIST
            'If Convert.ToBoolean(DataBinder.Eval(e.Row.DataItem, "MarkedForDeletion")) Then
            '    e.Row.Cells(EDIT_COLUMN).Text = String.Empty
            '    e.Row.Cells(DELETE_COLUMN).Text = String.Empty
            'End If

            ' -- part of other job check --
            ' if the item is part of another job and in non-LIVE status, then hide edit/delete icons
            ' DON'T NEED THIS FOR JOB LIST
            'If Convert.ToInt32(DataBinder.Eval(e.Row.DataItem, "DeploymentJobID")) <> _
            '        Me.ActiveJobID And _
            '    DataBinder.Eval(e.Row.DataItem, "WorkflowStatus").ToString <> "LIVE" Then
            '    e.Row.Cells(EDIT_COLUMN).Text = CMSGlobals.BlankIcon
            '    e.Row.Cells(DELETE_COLUMN).Text = CMSGlobals.BlankIcon
            'End If

            ' if this is a Reader user, then hide delete/edit icons
            If AppUser.IsInRoleOnly("Reader") Then
                e.Row.Cells(EditColumn).Text = CMSGlobals.BlankIcon
                e.Row.Cells(DeleteColumn).Text = CMSGlobals.BlankIcon
            End If


        End If



    End Sub
End Class
