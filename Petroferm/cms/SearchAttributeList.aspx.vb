
Partial Class CmsSearchAttributeList
    Inherits CMSPage
    Private _editPage As String = "SearchAttributeEdit.aspx"
    Private Const DeleteColumn As Integer = 0
    Private Const EditColumn As Integer = 1
    Private Const ViewColumn As Integer = 2
    Private Const MktColumn As Integer = 4
    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load

        ' set page title

        lblMessage.Text = ""
    End Sub

    Protected Sub Page_PreRenderComplete(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.PreRenderComplete
        ' if it's a reader user or if there's no active job, hide the add button
        If AppUser.IsInRoleOnly("Reader") Or Me.ActiveJobID = 0 Then
            Me.lbtnAdd.Visible = False
            Me.Master.PageTitle = "View Search Attributes"
        Else
            Me.Master.PageTitle = "Manage Search Attributes"
        End If
        ' if bu = petroferm, hide the add button and market filters
        If Session("BusUnitID") = 1 Then
            Me.lbtnAdd.Visible = False
            Me.lblMarket.Visible = False
            Me.ddlMarket.Visible = False
        End If

        ' if the current job is in a status that the user should not be making add/edits in,
        ' make this page readonly by hiding the edit/delete icons of the grid and the add button
        If Me.ActiveJob IsNot Nothing Then
            If Not Me.ActiveJob.JobEditsAllowed Then
                Me.gvSearchAttributes.Columns(EditColumn).Visible = False
                Me.gvSearchAttributes.Columns(DeleteColumn).Visible = False
                Me.lbtnAdd.Visible = False
            End If
        End If
    End Sub

    Protected Sub ddlMarket_PreRender(ByVal sender As Object, ByVal e As System.EventArgs) Handles ddlMarket.PreRender
        ' add item to market name dropdown list on search attribute step -- for All Markets
        ' if it's not there already
        With ddlMarket
            If .Items.Count > 0 Then
                If .Items(0).Value <> "0" Then
                    Dim li As New ListItem("All Markets", "0")
                    .Items.Insert(0, li)
                End If
            End If
        End With
    End Sub

    Protected Sub ddlMarket_SelectedIndexChanged(ByVal sender As Object, ByVal e As System.EventArgs) Handles ddlMarket.SelectedIndexChanged
        ' show the market column if "all markets" is selected, otherwise hide it
        If ddlMarket.SelectedIndex = 0 Then
            gvSearchAttributes.Columns(MktColumn).Visible = True
        Else
            gvSearchAttributes.Columns(MktColumn).Visible = False
        End If
    End Sub

    Protected Sub lbtnAdd_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles lbtnAdd.Click
        Session("FormMode") = CMSFormUtils.FormMode.Edit
        Session("FormProdAttribID") = 0 ' meaning adding a new one
        Response.Redirect(_editPage)
    End Sub

    Protected Sub gvSearchAttributes_RowCommand(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewCommandEventArgs) Handles gvSearchAttributes.RowCommand
        ' If multiple ButtonField column fields are used, use the
        ' CommandName property to determine which button was clicked.

        Select Case e.CommandName
            Case "GoToEditPage"
                ' Get the ID to be edited
                Dim attribId As Integer = Convert.ToInt32(e.CommandArgument)
                Session("FormMode") = CMSFormUtils.FormMode.Edit
                Session("FormSearchAttribID") = attribID
                ' redirect to edit page
                Response.Redirect(_editPage)
            Case "GoToReadPage"
                ' Get the ID to be edited
                Dim attribId As Integer = Convert.ToInt32(e.CommandArgument)
                Session("FormMode") = CMSFormUtils.FormMode.Read
                Session("FormSearchAttribID") = attribID
                ' redirect to edit page
                Response.Redirect(_editPage)
            Case "DeleteItem"
                Dim delSearchAttrib As New SearchAttribute(Convert.ToInt32(e.CommandArgument))
                With delSearchAttrib
                    .JobID = Me.ActiveJobID
                    .LastModBy = Me.ActiveUserID
                    If .Delete() Then
                        lblMessage.Text = "The search attribute has been deleted or marked for deletion."
                        lblMessage.CssClass = "infoMessage"
                    End If
                End With
                ' refresh grid view data
                gvSearchAttributes.DataBind()
        End Select
    End Sub

    Protected Sub gvSearchAttributes_RowDataBound(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewRowEventArgs) Handles gvSearchAttributes.RowDataBound
        'TODO: CMS - Search Attribute - ADD CAPABILITY CHECK FOR ALLOWING DELETE/EDIT BUTTONS TO DISPLAY

        ' this adds a confirmation message to the delete command
        If e.Row.RowType = DataControlRowType.DataRow Then

            Dim searchAttributeName As String = DataBinder.Eval(e.Row.DataItem, "SearchAttributeName")

            ' replace any apostrophes
            searchAttributeName = searchAttributeName.Replace("'", "\'")

            Dim ibtnDelete As ImageButton = e.Row.FindControl("ibtnDelete")
            ibtnDelete.Attributes.Add("onclick", "javascript:return " & _
              "confirm('Are you sure you want to delete " & _
              searchAttributeName & "?')")


            ' hide the edit/delete button for item that is marked for deletion or marked as read only
            If Convert.ToBoolean(DataBinder.Eval(e.Row.DataItem, "MarkedForDeletion")) Then
                e.Row.Cells(EditColumn).Text = CMSGlobals.BlankIcon
                e.Row.Cells(DeleteColumn).Text = CMSGlobals.BlankIcon
            End If

            ' -- part of other job check --
            ' if the item is part of another job and in non-LIVE status, then hide just the delete icon
            ' (still may edit items within wizard)
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


End Class
