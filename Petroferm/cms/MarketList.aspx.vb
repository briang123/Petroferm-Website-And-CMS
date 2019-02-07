
Partial Class CmsMarketList
    Inherits CMSPage
    Private _editPage As String = "MarketEdit.aspx"
    Private Const DeleteColumn As Integer = 0
    Private Const EditColumn As Integer = 1
    Private Const ViewColumn As Integer = 2

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        lblMessage.Text = ""


    End Sub

    Protected Sub lbtnAdd_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles lbtnAdd.Click
        Session("FormMode") = CMSFormUtils.FormMode.Edit
        Session("FormMktID") = 0 ' meaning adding a new one
        Response.Redirect("MarketEdit.aspx")
    End Sub

    Protected Sub Page_PreRenderComplete(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.PreRenderComplete

        ' hide add market for bu = 1 (petroferm)
        If Session("BusUnitID") IsNot Nothing Then
            If Services.GetNULLableInteger(Session("BusUnitID")) = 1 Then
                lbtnAdd.Visible = False
            Else
                lbtnAdd.Visible = True
            End If
        End If

        ' if it's a reader user or if there's no active job, hide the add button
        If AppUser.IsInRoleOnly("Reader") Or Me.ActiveJobID = 0 Then
            Me.lbtnAdd.Visible = False
            Me.Master.PageTitle = "View Markets for " & Me.Master.SelectedBusinessUnit
        Else
            Me.Master.PageTitle = "Manage Markets for " & Me.Master.SelectedBusinessUnit
        End If


        ' if the current job is in a status that the user should not be making add/edits in,
        ' make this page readonly by hiding the edit/delete icons of the grid and the add button
        If Me.ActiveJob IsNot Nothing Then
            If Not Me.ActiveJob.JobEditsAllowed Then
                Me.gvMarket.Columns(EditColumn).Visible = False
                Me.gvMarket.Columns(DeleteColumn).Visible = False
                Me.lbtnAdd.Visible = False
            End If
        End If
    End Sub

    Protected Sub gvMarket_RowCommand(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewCommandEventArgs) Handles gvMarket.RowCommand
        ' If multiple ButtonField column fields are used, use the
        ' CommandName property to determine which button was clicked.
        Select Case e.CommandName
            Case "GoToEditPage"
                ' Get the ID to be edited
                Dim mktId As Integer = Convert.ToInt32(e.CommandArgument)
                Session("FormMode") = CMSFormUtils.FormMode.Edit
                Session("FormMktID") = mktID
                ' redirect to edit page
                Response.Redirect(_editPage)
            Case "GoToReadPage"
                ' Get the ID to be edited
                Dim mktId As Integer = Convert.ToInt32(e.CommandArgument)
                Session("FormMode") = CMSFormUtils.FormMode.Read
                Session("FormMktID") = mktID
                ' redirect to edit page
                Response.Redirect(_editPage)
            Case "DeleteItem"
                Dim delMarket As New Market(Convert.ToInt32(e.CommandArgument))
                With delMarket
                    .JobID = Me.ActiveJobID
                    .LastModBy = Me.ActiveUserID
                    If .Delete() Then
                        lblMessage.Text = "The market has been deleted or marked for deletion."
                        lblMessage.CssClass = "infoMessage"
                    End If
                End With

                ' refresh grid view data
                gvMarket.DataBind()
        End Select

    End Sub

    Protected Sub gvMarket_RowDataBound(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewRowEventArgs) Handles gvMarket.RowDataBound
        'TODO: CMS - Market - ADD CAPABILITY CHECK FOR ALLOWING DELETE/EDIT BUTTONS TO DISPLAY

        ' this adds a confirmation message to the delete command
        If e.Row.RowType = DataControlRowType.DataRow Then

            Dim marketName As String = DataBinder.Eval(e.Row.DataItem, "MarketName")

            ' replace any apostrophes
            marketName = marketName.Replace("'", "\'")

            Dim ibtnDelete As ImageButton = e.Row.FindControl("ibtnDelete")
            ibtnDelete.Attributes.Add("onclick", "javascript:return " & _
              "confirm('Are you sure you want to delete " & _
              marketName & "?')")

            ' hide the edit/delete button for item that is marked for deletion
            If Convert.ToBoolean(DataBinder.Eval(e.Row.DataItem, "MarkedForDeletion")) Then
                e.Row.Cells(EditColumn).Text = String.Empty
                e.Row.Cells(DeleteColumn).Text = String.Empty
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
