
Partial Class ControlsLogin
    Inherits System.Web.UI.UserControl
    'Added three properties to the control to handle the Register.aspx link so that it displays
    ' its page elements within the correct context.
    ' 12/22/06 kr
    Private _mRefBusUnit As Integer
    Private _mRefMkt As String
    Private _mRefPageId As String

    Public Property RefBusUnit() As Integer
        Get
            Return _mRefBusUnit
        End Get
        Set(ByVal value As Integer)
            _mRefBusUnit = value
        End Set
    End Property
    Public Property RefMkt() As Integer
        Get
            Return _mRefMkt
        End Get
        Set(ByVal value As Integer)
            _mRefMkt = value
        End Set
    End Property

    Public Property RefPageId() As Integer
        Get
            Return _mRefPageId
        End Get
        Set(ByVal value As Integer)
            _mRefPageId = value
        End Set
    End Property


    Protected Sub Page_PreRender(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.PreRender
        Dim regLink As HyperLink = TryCast(Me.Login1.FindControl("lnkRegister"), HyperLink)
        If regLink IsNot Nothing Then
            regLink.NavigateUrl = "~/Register.aspx?ref=" & RefBusUnit.ToString & "," & RefMkt.ToString & "," & RefPageId
        End If

    End Sub
End Class
