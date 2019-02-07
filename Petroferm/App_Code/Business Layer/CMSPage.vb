Imports Microsoft.VisualBasic

Public Class CmsPage
    Inherits System.Web.UI.Page
    Protected Friend Sub Page_Error(ByVal sender As Object, ByVal e As System.EventArgs) _
    Handles MyBase.Error
        ' get exception 
        'Dim ex As NLTException = DirectCast(Server.GetLastError().InnerException, NLTException)

        Dim exNlt As NLTException = Nothing
        Dim ex As Exception = Nothing

        exNLT = TryCast(Server.GetLastError.InnerException, NLTException)

        Dim errorLogger As New NLTErrorLogger

        If exNLT IsNot Nothing Then
            ' log error
            errorLogger.Log(exNLT)
        End If

        '' go to error page
        Server.Transfer(Me.ErrorPage)

    End Sub
    Private Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load
        Me.ErrorPage = "~/cms/Error.aspx"


        If Not My.User.IsAuthenticated Then
            Session("ActiveUserID") = Nothing
        End If

        ' try to reset the session object
        If Session("ActiveJobID") Is Nothing Then
            ' check the dropdown list on master page
            Dim ddlActiveJob As DropDownList
            ddlActiveJob = TryCast(Me.Master.FindControl("ddlJob"), DropDownList)
            If ddlActiveJob.SelectedValue.Length > 0 And ddlActiveJob.SelectedValue <> "SELECT" Then
                Session("ActiveJobID") = Convert.ToInt32(ddlActiveJob.SelectedValue)
                Me.ActiveJobID = Convert.ToInt32(Session("ActiveJobID"))
            Else
                Me.ActiveJobID = 0
            End If

        Else
            Me.ActiveJobID = Convert.ToInt32(Session("ActiveJobID"))
        End If

    End Sub

    Public Property ActiveUserId() As Integer
        Get
            If Session("ActiveUserID") Is Nothing Then
                ' get the user id
                Dim currUser As New AppUser
                With currUser
                    .UserName = My.User.Name
                    .Fill()
                    If .AppUserID <> 0 Then
                        Session("ActiveUserID") = .AppUserID
                    Else
                        Session("ActiveUserID") = 0
                    End If
                End With
            End If
            Return Convert.ToInt32(Session("ActiveUserID"))
        End Get
        Set(ByVal value As Integer)
            Session("ActiveUserID") = value
        End Set
    End Property

    Public Property ActiveJobId() As Integer
        Get
            If Session("ActiveJobID") Is Nothing Then
                Return 0
            Else
                Return Convert.ToInt32(Session("ActiveJobID"))
            End If
        End Get
        Set(ByVal value As Integer)
            Session("ActiveJobID") = value
        End Set
    End Property


    Public Property ActiveJob() As DeploymentJob
        Get
            Return Session("ActiveJob")
        End Get
        Set(ByVal value As DeploymentJob)
            Session("ActiveJob") = value
        End Set
    End Property





End Class
