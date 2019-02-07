Imports Microsoft.VisualBasic

Public Class AppUser
    Inherits Person

    Private _mAppUserId As Integer
    Private _mUserId As String
    Private _mUserName As String

    Public Property UserName() As String
        Get
            Return _mUserName
        End Get
        Set(ByVal value As String)
            _mUserName = value.Trim.ToLower
        End Set
    End Property

    Public Property AppUserId() As Integer
        Get
            Return _mAppUserId
        End Get
        Set(ByVal value As Integer)
            _mAppUserId = value
        End Set
    End Property
    Public Property UserId() As String
        Get
            Return _mUserId
        End Get
        Set(ByVal value As String)
            _mUserId = value
        End Set
    End Property

    Function Fill() As Boolean

        Try

            Dim data As New DataAccess(SiteProfile.GetConnectionString, DataAccess.DataProvider.SQL)
            Dim strStoredProc As String = ""
            Dim iParmUserName As IDbDataParameter = Nothing
            Dim iCmd As IDbCommand = Nothing

            Select Case True
                Case Me.UserName.Length > 0
                    strStoredProc = "sp__GetAppUserByUserName"
                    iParmUserName = data.GetParameter(DataAccess.DataProvider.SQL, "@UserName", DbType.String, Me.UserName, 256, ParameterDirection.Input)
            End Select

            If strStoredProc.Length > 0 Then
                iCmd = data.GetCommand(strStoredProc, CommandType.StoredProcedure, DataAccess.DataProvider.SQL)
                With iCmd
                    If iParmUserName IsNot Nothing Then
                        .Parameters.Add(iParmUserName)
                    End If
                End With

                Dim dt As DataTable = data.GetDataTable(iCmd)

                If dt.Rows.Count > 0 Then
                    Dim row As DataRow = dt.Rows(0)
                    ' fill properties
                    Me.UserName = Services.GetNULLableString(row("UserName"))
                    Me.FirstName = Services.GetNULLableString(row("FirstName"))
                    Me.LastName = Services.GetNULLableString(row("LastName"))
                    Me.UserID = Services.GetNULLableString(row("UserId"))
                    Me.AppUserID = Services.GetNULLableInteger(row("AppUserID"))
                End If
            End If

        Catch ex As Exception
            Throw New NLTException("Error retrieving App User.", ex, "AppUser.vb", "Function Fill() As Boolean")
        End Try
    End Function

    Public Shared Function IsInRoleOnly(ByVal roleName As String) As Boolean

        Dim isInOtherRole As Boolean = False
        Dim myRoles() As String = Roles.GetRolesForUser()
        Dim enumRoles As IEnumerator = myRoles.GetEnumerator

        While enumRoles.MoveNext
            If enumRoles.Current.ToString.ToUpper <> roleName.ToUpper Then
                IsInOtherRole = True
                Exit While
            End If
        End While

        If IsInOtherRole = False And My.User.IsInRole(roleName) Then
            Return True
        Else
            Return False
        End If
    End Function
End Class
