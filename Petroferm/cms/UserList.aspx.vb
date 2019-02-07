
Partial Class CmsUserList
    Inherits CMSPage

    Private Const MaxLogoWidth As Integer = 100
    Private Const MaxLogoHeight As Integer = 50
    Private Const EditPage As String = "UserEdit.aspx"
    Private Const DeleteColumn As Integer = 0
    Private Const EditColumn As Integer = 1
    Private Const ViewColumn As Integer = 2
    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        Me.Master.PageTitle = "Manage Users"
        lblMessage.Text = ""
    End Sub


    Protected Sub Page_PreRenderComplete(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.PreRenderComplete

        If User.IsInRole("Administrator") = False Then
            With lblMessage
                .Text = "You do not have the appropriate permissions to manage user information."
                .Visible = True
                .CssClass = "infoMessage"
            End With

            gvUserList.Visible = False
            lbtnAdd.Visible = False
        End If

        Me.Master.HideBusinessUnitDropdown()
        Me.Master.HideJobDropdown()

    End Sub

    Protected Sub lbtnAdd_Click(ByVal sender As Object, ByVal e As System.EventArgs) Handles lbtnAdd.Click
        Session("FormMode") = CMSFormUtils.FormMode.Edit
        Session("FormUserId") = 0 ' meaning adding a new one
        Session("FormUserName") = Nothing
        Response.Redirect(EditPage)
    End Sub

    Protected Sub gvUserList_RowCommand(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewCommandEventArgs) Handles gvUserList.RowCommand
        ' If multiple ButtonField column fields are used, use the
        ' CommandName property to determine which button was clicked.
        Select Case e.CommandName
            Case "GoToEditPage"
                Dim userName As String = e.CommandArgument.ToString
                Session("FormMode") = CMSFormUtils.FormMode.Edit
                Session("FormUserName") = userName
                Response.Redirect(EditPage)
            Case "GoToReadPage"
                Dim userName As String = e.CommandArgument.ToString
                Session("FormMode") = CMSFormUtils.FormMode.Read
                Session("FormUserName") = userName
                Response.Redirect(EditPage)
            Case "DeleteItem"
                Dim memUser As MembershipUser = Membership.GetUser(e.CommandArgument.ToString)
                Dim appUser As New User(memUser)
                With appUser
                    If .Delete() Then
                        lblMessage.Text = "The user has been completely deleted from the system."
                        lblMessage.CssClass = "infoMessage"
                    End If
                End With
            Case "ApproveUser"
                Dim memUser As MembershipUser = Membership.GetUser(e.CommandArgument.ToString)
                If Not memUser Is Nothing Then
                    If memUser.IsApproved = False Then
                        memUser.IsApproved = True
                    Else
                        memUser.IsApproved = False
                    End If

                    Dim appUser As New User(memUser)
                    If appUser.ApproveUserById() Then
                        lblMessage.Text = "The user approval status has been updated."
                        lblMessage.CssClass = "infoMessage"
                    End If
                End If
            Case "UnlockUser"
                Dim memUser As MembershipUser = Membership.GetUser(e.CommandArgument.ToString)
                If (Not memUser Is Nothing And memUser.IsLockedOut = True) Then
                    If memUser.UnlockUser() Then
                        lblMessage.Text = "The user has been unlocked."
                        lblMessage.CssClass = "infoMessage"
                    End If
                End If
        End Select

        ' refresh grid view data
        gvUserList.DataBind()

    End Sub

    Protected Sub gvUserList_RowDataBound(ByVal sender As Object, ByVal e As System.Web.UI.WebControls.GridViewRowEventArgs) Handles gvUserList.RowDataBound
        If e.Row.RowType = DataControlRowType.DataRow Then

            Dim userName As String = DataBinder.Eval(e.Row.DataItem, "userName")
            Dim userLockedOut As Boolean = DataBinder.Eval(e.Row.DataItem, "IsLockedOut")
            Dim userApproved As Boolean = DataBinder.Eval(e.Row.DataItem, "IsApproved")

            userName = userName.Replace("'", "\'")

            ' this adds a confirmation message to the delete command
            Dim ibtnDelete As ImageButton = e.Row.FindControl("ibtnDelete")
            ibtnDelete.Attributes.Add("onclick", "javascript:return " & _
              "confirm('Are you sure you want to delete " & userName & "?')")

            Dim imgLocked As Image = e.Row.FindControl("imgLocked")
            Dim ibtnLocked As ImageButton = e.Row.FindControl("ibtnLocked")
            If userLockedOut = True Then
                ibtnLocked.Visible = True
                imgLocked.Visible = False
            Else
                imgLocked.Visible = True
                ibtnLocked.Visible = False
            End If

            Dim ibtnApproveUser As ImageButton = e.Row.FindControl("ibtnApproveUser")
            If userApproved = True Then
                ibtnApproveUser.ImageUrl = "../App_Themes/CMS_Theme/images/user.gif"
                ibtnApproveUser.AlternateText = "Click to Unauthenticate User"
            Else
                ibtnApproveUser.AlternateText = "Click to Authenticate User"
                ibtnApproveUser.ImageUrl = "../App_Themes/CMS_Theme/images/imnhdr.gif"
            End If

            Dim imgOnline As Image = e.Row.FindControl("imgOnline")
            Dim memUser As MembershipUser = Membership.GetUser(userName)
            If memUser.IsOnline Then
                imgOnline.ImageUrl = "../App_Themes/CMS_Theme/images/check.gif"
                imgOnline.AlternateText = "User is currently signed into the system"
            End If

        End If
    End Sub

End Class
