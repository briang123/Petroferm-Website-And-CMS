
Partial Class CmsProductList
    Inherits CMSPage
    Private _editPage As String = "ProductEdit.aspx"
    Private Const DeleteColumn As Integer = 0
    Private Const EditColumn As Integer = 1
    Private Const ViewColumn As Integer = 2
    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load

    End Sub

    Protected Sub Page_PreRenderComplete(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.PreRenderComplete
        ' if it's a reader user or if there's no active job, hide the add button
        If AppUser.IsInRoleOnly("Reader") Or Me.ActiveJobID = 0 Then
            Me.lbtnAdd.Visible = False
            Me.Master.PageTitle = "View Products"
        Else
            Me.Master.PageTitle = "Manage Products"
        End If
        ' if bu = petroferm, hide the add button
        If Session("BusUnitID") = 1 Then
            Me.lbtnAdd.Visible = False
        End If

        ' if the current job is in a status that the user should not be making add/edits in,
        ' make this page readonly by hiding the edit/delete icons of the grid and the add button
        If Me.ActiveJob IsNot Nothing Then
            If Not Me.ActiveJob.JobEditsAllowed Then
                Me.gvProducts.Columns(EditColumn).Visible = False
                Me.gvProducts.Columns(DeleteColumn).Visible = False
                Me.lbtnAdd.Visible = False
            End If
        End If
    End Sub

    Protected Sub lbtnAdd_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles lbtnAdd.Click
        Session("FormMode") = CMSFormUtils.FormMode.Edit
        Session("FormProductID") = 0 ' meaning adding a new one
        Response.Redirect(_editPage)
    End Sub

    Protected Sub gvProducts_RowCommand(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewCommandEventArgs) Handles gvProducts.RowCommand
        ' If multiple ButtonField column fields are used, use the
        ' CommandName property to determine which button was clicked.

        Select Case e.CommandName
            Case "GoToEditPage"
                ' Get the ID to be edited
                Dim productId As Integer = Convert.ToInt32(e.CommandArgument)
                Session("FormMode") = CMSFormUtils.FormMode.Edit
                Session("FormProductID") = productID
                ' redirect to edit page
                Response.Redirect(_editPage)
            Case "GoToReadPage"
                ' Get the ID to be edited
                Dim productId As Integer = Convert.ToInt32(e.CommandArgument)
                Session("FormMode") = CMSFormUtils.FormMode.Read
                Session("FormProductID") = productID
                ' redirect to edit page
                Response.Redirect(_editPage)
            Case "DeleteItem"
                Dim delProduct As New Product(Convert.ToInt32(e.CommandArgument))
                With delProduct
                    .JobID = Me.ActiveJobID
                    .LastModBy = Me.ActiveUserID
                    If .Delete() Then
                        lblMessage.Text = "The product has been deleted or marked for deletion."
                        lblMessage.CssClass = "infoMessage"
                    End If
                End With

                ' refresh grid view data
                gvProducts.DataBind()
        End Select
    End Sub

    Protected Sub gvProducts_RowDataBound(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewRowEventArgs) Handles gvProducts.RowDataBound
        'TODO: CMS - Product Attribute - ADD CAPABILITY CHECK FOR ALLOWING DELETE/EDIT BUTTONS TO DISPLAY

        ' this adds a confirmation message to the delete command
        If e.Row.RowType = DataControlRowType.DataRow Then
            Dim productName As String = DataBinder.Eval(e.Row.DataItem, "ProductName")

            ' replace any apostrophes
            productName = productName.Replace("'", "\'")

            Dim ibtnDelete As ImageButton = e.Row.FindControl("ibtnDelete")
            ibtnDelete.Attributes.Add("onclick", "javascript:return " & _
              "confirm('Are you sure you want to delete " & _
              productName & "?')")

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
