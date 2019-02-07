
Partial Class CmsPageList
    Inherits CMSPage
    Private _editPage As String = "PageEdit.aspx"
    Private Const DeleteColumn As Integer = 0
    Private Const EditColumn As Integer = 1
    Private Const ViewColumn As Integer = 2


    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        lblMessage.Text = ""
    End Sub

    Protected Sub lbtnAdd_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles lbtnAdd.Click
        Session("FormMode") = CMSFormUtils.FormMode.Edit
        Session("FormPageID") = 0 ' meaning adding a new one
        Response.Redirect(_editPage)
    End Sub

    Protected Sub Page_PreRenderComplete(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.PreRenderComplete
        
        ' if it's a reader user or if there's no active job, hide the add button
        If AppUser.IsInRoleOnly("Reader") Or Me.ActiveJobID = 0 Then
            Me.lbtnAdd.Visible = False
            Me.Master.PageTitle = "View Pages for " & Me.Master.SelectedBusinessUnit
        Else
            Me.Master.PageTitle = "Manage Pages for " & Me.Master.SelectedBusinessUnit
        End If


        ' if the current job is in a status that the user should not be making add/edits in,
        ' make this page readonly by hiding the edit/delete icons of the grid and the add button
        If Me.ActiveJob IsNot Nothing Then
            If Not Me.ActiveJob.JobEditsAllowed Then
                Me.gvPages.Columns(EditColumn).Visible = False
                Me.gvPages.Columns(DeleteColumn).Visible = False
                Me.lbtnAdd.Visible = False
            End If
        End If
    End Sub

    Protected Sub gvPages_RowCommand(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewCommandEventArgs) Handles gvPages.RowCommand
        Select Case e.CommandName
            Case "GoToEditPage"
                ' Get the ID to be edited
                Dim pageId As Integer = Convert.ToInt32(e.CommandArgument)
                Session("FormMode") = CMSFormUtils.FormMode.Edit
                Session("FormPageID") = pageID
                ' redirect to edit page
                Response.Redirect(_editPage)
            Case "GoToReadPage"
                ' Get the ID to be edited
                Dim pageId As Integer = Convert.ToInt32(e.CommandArgument)
                Session("FormMode") = CMSFormUtils.FormMode.Read
                Session("FormPageID") = pageID
                ' redirect to edit page
                Response.Redirect(_editPage)
            Case "DeleteItem"
                Dim delPage As New WebPage
                delPage.PageId = Convert.ToInt32(e.CommandArgument)
                With delPage
                    .JobID = Me.ActiveJobID
                    .LastModBy = Me.ActiveUserID
                    If .Delete() Then
                        lblMessage.Text = "The page has been deleted or marked for deletion."
                        lblMessage.CssClass = "infoMessage"
                    End If
                End With
                ' refresh grid view data
                gvPages.DataBind()
        End Select
    End Sub

    Protected Sub gvPages_RowDataBound(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewRowEventArgs) Handles gvPages.RowDataBound
        'TODO: CMS - Pages - ADD CAPABILITY CHECK FOR ALLOWING DELETE/EDIT BUTTONS TO DISPLAY

        ' this adds a confirmation message to the delete command
        If e.Row.RowType = DataControlRowType.DataRow Then

            Dim pageTitle As String = DataBinder.Eval(e.Row.DataItem, "PageTitle")

            ' replace any apostrophes
            pageTitle = pageTitle.Replace("'", "\'")

            Dim ibtnDelete As ImageButton = e.Row.FindControl("ibtnDelete")
            ibtnDelete.Attributes.Add("onclick", "javascript:return " & _
              "confirm('Are you sure you want to delete " & _
             pageTitle & "?')")


            ' hide the edit/delete button for item that is marked for deletion or marked as read only
            ' TODO: CMS - For IsRequired pages, hide the delete icon!
            If Convert.ToBoolean(DataBinder.Eval(e.Row.DataItem, "MarkedForDeletion")) Then
                e.Row.Cells(EditColumn).Text = String.Empty
                e.Row.Cells(DeleteColumn).Text = CMSGlobals.BlankIcon
            End If
            If Convert.ToBoolean(DataBinder.Eval(e.Row.DataItem, "IsRequired")) Then
                ' can't delete the page because it's required
                e.Row.Cells(DeleteColumn).Text = CMSGlobals.BlankIcon
            End If
            If Convert.ToBoolean(DataBinder.Eval(e.Row.DataItem, "IsReadOnly")) Then
                ' can't edit the page because it's read only
                e.Row.Cells(EditColumn).Text = CMSGlobals.BlankIcon
                ' also hide the view icon too
                e.Row.Cells(ViewColumn).Text = CMSGlobals.BlankIcon
            End If

            ' -- part of other job check --
            ' if the item is part of another job and in non-LIVE status, then hide just the delete icon
            '(there may be other things that can be edited within the page edit wizard)
            If Convert.ToInt32(DataBinder.Eval(e.Row.DataItem, "DeploymentJobID")) <> _
                    Me.ActiveJobID And _
                DataBinder.Eval(e.Row.DataItem, "WorkflowStatus").ToString <> "LIVE" Then
                e.Row.Cells(DeleteColumn).Text = CMSGlobals.BlankIcon
            End If

            ' if there's no active job or it's a reader user, then hide delete/edit icons
            If AppUser.IsInRoleOnly("Reader") Or Me.ActiveJobID = 0 Then
                e.Row.Cells(EditColumn).Text = CMSGlobals.BlankIcon
                e.Row.Cells(DeleteColumn).Text = CMSGlobals.BlankIcon
            End If

        End If



    End Sub

    Protected Sub ddlMarket_PreRender(ByVal sender As Object, ByVal e As System.EventArgs) Handles ddlMarket.PreRender
        ' add item to market name dropdown list on search attribute step -- for All Markets
        ' if it's not there already
        With ddlMarket
            If .Items.Count > 0 Then
                If .Items(0).Value <> "0" Then
                    Dim li As New ListItem("Show All Pages", "0")
                    .Items.Insert(0, li)
                End If

            Else ' just add the initial item
                Dim li As New ListItem("Show All Pages", "0")
                .Items.Insert(0, li)
            End If
        End With
    End Sub
End Class
