
Partial Class CmsBusinessUnitList
    Inherits CMSPage
    Private Const MaxLogoWidth As Integer = 100
    Private Const MaxLogoHeight As Integer = 50
    Private Const EditPage As String = "BusinessUnitEdit.aspx"
    Private Const DeleteColumn As Integer = 0
    Private Const EditColumn As Integer = 1
    Private Const ViewColumn As Integer = 2

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        Me.Master.PageTitle = "Manage Business Units"
        lblMessage.Text = ""

        ' TODO: ADD DELETE/EDIT/VIEW CAPABILITY STUFF HERE TO DETERMINE WHICH COLUMNS TO DISPLAY
        'EXAMPLE: gvBusUnitList.Columns(DELETE_COLUMN).Visible = False


    End Sub

    Protected Sub Page_PreRenderComplete(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.PreRenderComplete
        ' if it's a reader user or if there's no active job, hide the add button
        If AppUser.IsInRoleOnly("Reader") Or Me.ActiveJobID = 0 Then
            Me.lbtnAdd.Visible = False
            Me.Master.PageTitle = "View Business Units"
        End If

        ' if the current job is in a status that the user should not be making add/edits in,
        ' make this page readonly by hiding the edit/delete icons of the grid and the add button
        If Me.ActiveJob IsNot Nothing Then
            If Not Me.ActiveJob.JobEditsAllowed Then
                Me.gvBusUnitList.Columns(EditColumn).Visible = False
                Me.gvBusUnitList.Columns(DeleteColumn).Visible = False
                Me.lbtnAdd.Visible = False
            End If
        End If

    End Sub

    Protected Sub lbtnAdd_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles lbtnAdd.Click
        Session("FormMode") = CMSFormUtils.FormMode.Edit
        Session("FormBusUnitID") = 0 ' meaning adding a new one
        Response.Redirect(EditPage)
    End Sub

    Protected Sub gvBusUnitList_RowCommand(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewCommandEventArgs) Handles gvBusUnitList.RowCommand
        ' If multiple ButtonField column fields are used, use the
        ' CommandName property to determine which button was clicked.
        Select Case e.CommandName
            Case "GoToEditPage"
                ' Get the bus unit ID to be edited
                Dim busUnitId As Integer = Convert.ToInt32(e.CommandArgument)
                Session("FormMode") = CMSFormUtils.FormMode.Edit
                Session("FormBusUnitID") = busUnitID
                ' redirect to edit page
                Response.Redirect(EditPage)
            Case "GoToReadPage"
                ' Get the bus unit ID to be edited
                Dim busUnitId As Integer = Convert.ToInt32(e.CommandArgument)
                Session("FormMode") = CMSFormUtils.FormMode.Read
                Session("FormBusUnitID") = busUnitID
                ' redirect to edit page
                Response.Redirect(EditPage)
            Case "DeleteItem"
                Dim delBusUnit As New BusinessUnit(Convert.ToInt32(e.CommandArgument))
                With delBusUnit
                    .JobID = Me.ActiveJobID
                    .LastModBy = Me.ActiveUserID
                    If .Delete() Then
                        lblMessage.Text = "The business unit has been deleted or marked for deletion."
                        lblMessage.CssClass = "infoMessage"
                    End If
                End With

                ' refresh grid view data
                gvBusUnitList.DataBind()


        End Select
    End Sub

    Protected Sub gvBusUnitList_RowDataBound(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewRowEventArgs) Handles gvBusUnitList.RowDataBound
        ' this adds a confirmation message to the delete command
        If e.Row.RowType = DataControlRowType.DataRow Then

            Dim businessUnitName As String = DataBinder.Eval(e.Row.DataItem, "BusinessUnitName")

            ' replace any apostrophes
            businessUnitName = businessUnitName.Replace("'", "\'")

            Dim ibtnDelete As ImageButton = e.Row.FindControl("ibtnDelete")
            ibtnDelete.Attributes.Add("onclick", "javascript:return " & _
              "confirm('Are you sure you want to delete " & _
              businessUnitName & "?')")

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

            ' hide the edit/delete button for item that is marked for deletion
            If Convert.ToBoolean(DataBinder.Eval(e.Row.DataItem, "MarkedForDeletion")) Then
                e.Row.Cells(EditColumn).Text = String.Empty
                e.Row.Cells(DeleteColumn).Text = String.Empty
            ElseIf Convert.ToInt32(DataBinder.Eval(e.Row.DataItem, "BusinessUnitID")) = 1 Then
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
