
Partial Class CmsChangePassword
    Inherits CMSPage

    Protected Sub Page_Load1(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        Me.Master.PageTitle = "Change Password"
        Me.Master.HideBusinessUnitDropdown()
        Me.Master.HideJobDropdown()
    End Sub
End Class
