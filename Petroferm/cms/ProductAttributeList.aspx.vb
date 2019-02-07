
Partial Class CmsProductAttributeList
    Inherits CMSPage
    Private _editPage As String = "ProductAttributeEdit.aspx"
    Private Const DeleteColumn As Integer = 0
    Private Const EditColumn As Integer = 1
    Private Const ViewColumn As Integer = 2
    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load

        ' set page title
        lblMessage.Text = ""
    End Sub

    Protected Sub Page_PreRenderComplete(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.PreRenderComplete
        ' if it's a reader user or if there's no active job, hide the add button
        If AppUser.IsInRoleOnly("Reader") Or Me.ActiveJobID = 0 Then
            Me.lbtnAdd.Visible = False
            Me.Master.PageTitle = "View Product Attributes"
        Else
            Me.Master.PageTitle = "Manage Product Attributes"
        End If

        ' if bu = petroferm, hide the add button
        If Session("BusUnitID") = 1 Then
            Me.lbtnAdd.Visible = False
        End If

        ' if the current job is in a status that the user should not be making add/edits in,
        ' make this page readonly by hiding the edit/delete icons of the grid and the add button
        If Me.ActiveJob IsNot Nothing Then
            If Not Me.ActiveJob.JobEditsAllowed Then
                Me.gvProductAttributes.Columns(EditColumn).Visible = False
                Me.gvProductAttributes.Columns(DeleteColumn).Visible = False
                Me.lbtnAdd.Visible = False
            End If
        End If

    End Sub
    Protected Sub lbtnAdd_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles lbtnAdd.Click
        Session("FormMode") = CMSFormUtils.FormMode.Edit
        Session("FormProdAttribID") = 0 ' meaning adding a new one
        Response.Redirect(_editPage)
    End Sub

    Protected Sub gvProductAttributes_RowCommand(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewCommandEventArgs) Handles gvProductAttributes.RowCommand
        ' If multiple ButtonField column fields are used, use the
        ' CommandName property to determine which button was clicked.

        Select Case e.CommandName
            Case "GoToEditPage"
                ' Get the ID to be edited
                Dim attribId As Integer = Convert.ToInt32(e.CommandArgument)
                Session("FormMode") = CMSFormUtils.FormMode.Edit
                Session("FormProdAttribID") = attribID
                ' redirect to edit page
                Response.Redirect(_editPage)
            Case "GoToReadPage"
                ' Get the ID to be edited
                Dim attribId As Integer = Convert.ToInt32(e.CommandArgument)
                Session("FormMode") = CMSFormUtils.FormMode.Read
                Session("FormProdAttribID") = attribID
                ' redirect to edit page
                Response.Redirect(_editPage)
            Case "DeleteItem"
                Dim delProdAttrib As New ProductAttribute(Convert.ToInt32(e.CommandArgument))
                With delProdAttrib
                    .JobID = Me.ActiveJobID
                    .LastModBy = Me.ActiveUserID
                    If .Delete() Then
                        lblMessage.Text = "The product attribute has been deleted or marked for deletion."
                        lblMessage.CssClass = "infoMessage"
                    End If

                End With

                ' refresh grid view data
                gvProductAttributes.DataBind()
        End Select
    End Sub

    Protected Sub gvProductAttributes_RowDataBound(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewRowEventArgs) Handles gvProductAttributes.RowDataBound


        'TODO: CMS - Product Attribute - ADD CAPABILITY CHECK FOR ALLOWING DELETE/EDIT BUTTONS TO DISPLAY

        ' this adds a confirmation message to the delete command
        If e.Row.RowType = DataControlRowType.DataRow Then

            Dim attribName As String = DataBinder.Eval(e.Row.DataItem, "AttribName")
            ' replace any apostrophes
            attribName = attribName.Replace("'", "\'")

            Dim ibtnDelete As ImageButton = e.Row.FindControl("ibtnDelete")
            ibtnDelete.Attributes.Add("onclick", "javascript:return " & _
              "confirm('Are you sure you want to delete " & _
              attribName & "?')")

            ' hide the edit/delete button for item that is marked for deletion or marked as read only
            If Convert.ToBoolean(DataBinder.Eval(e.Row.DataItem, "MarkedForDeletion")) Or _
             Convert.ToBoolean(DataBinder.Eval(e.Row.DataItem, "IsReadOnly")) Then
                e.Row.Cells(EditColumn).Text = CMSGlobals.BlankIcon
                e.Row.Cells(DeleteColumn).Text = CMSGlobals.BlankIcon
            End If

            ' -- part of other job check --
            ' if the item is part of another job and in non-LIVE status, then hide edit/delete icons
            If Convert.ToInt32(DataBinder.Eval(e.Row.DataItem, "DeploymentJobID")) <> _
                    Me.ActiveJobID And _
                DataBinder.Eval(e.Row.DataItem, "WorkflowStatus").ToString <> "LIVE" Then
                e.Row.Cells(EditColumn).Text = CMSGlobals.BlankIcon
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
