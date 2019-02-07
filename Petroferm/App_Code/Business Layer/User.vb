Public Class User
    Inherits Employee

    Private _mAppUserId As Integer
    Private _mUserName As String
    Private _mMembershipUser As MembershipUser
    Private _mBusUnitId As Integer

#Region " CONSTRUCTORS "

    Public Sub New()
        MyBase.New()
    End Sub

    Public Sub New(ByVal memUser As MembershipUser)
        MyBase.New()
        Me.MembershipUser = MemUser
    End Sub

    Public Sub New(ByVal memUser As MembershipUser, ByVal busUnitId As Integer)
        MyBase.New()
        Me.MembershipUser = MemUser
        Me.BusUnitID = BusUnitId
    End Sub

    Public Sub New(ByVal busUnitId As Integer)
        MyBase.New()
        Me.BusUnitID = BusUnitID
    End Sub

#End Region

    Property MembershipUser() As MembershipUser
        Get
            Return _mMembershipUser
        End Get
        Set(ByVal value As MembershipUser)
            _mMembershipUser = value
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

    Public Property UserName() As String
        Get
            Return _mUserName
        End Get
        Set(ByVal value As String)
            _mUserName = value
        End Set
    End Property

    Public Property BusUnitId() As Integer
        Get
            Return _mBusUnitId
        End Get
        Set(ByVal value As Integer)
            _mBusUnitId = value
        End Set
    End Property

    Function Save() As Boolean
        Return True
    End Function

    Function AddAppUser(ByVal lastModifiedBy As Integer) As Boolean
        Try

            Dim success As Boolean = False
            Dim data As New DataAccess(SiteProfile.GetConnectionString, DataAccess.DataProvider.SQL)
            Dim dict As New System.Collections.Specialized.HybridDictionary

            Dim iParmId As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@UserID", DbType.Guid, Me.MembershipUser.ProviderUserKey, Me.MembershipUser.ProviderUserKey.ToString.Length, ParameterDirection.Input)
            Dim iParmFirstName As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@FirstName", DbType.String, MyBase.FirstName, 50, ParameterDirection.Input)
            Dim iParmLastName As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@LastName", DbType.String, MyBase.LastName, 100, ParameterDirection.Input)
            Dim iParmLastModBy As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@LastModBy", DbType.Int32, LastModifiedBy, 4, ParameterDirection.Input)
            Dim iParmAppUserId As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@AppUserId", DbType.Int32, DBNull.Value, 4, ParameterDirection.Output)
            Dim iCmd As IDbCommand = data.GetCommand("sp__AddUser", CommandType.StoredProcedure, DataAccess.DataProvider.SQL)
            With iCmd.Parameters
                .Add(iParmID)
                .Add(iParmFirstName)
                .Add(iParmLastName)
                .Add(iParmLastModBy)
                .Add(iParmAppUserId)
            End With

            dict.Add(dict.Count, iCmd)

            success = data.ExecuteNonQuery(dict)
            If success Then
                Me.AppUserId = iParmAppUserId.Value
            End If

            Return success
        Catch ex As Exception
            Throw New NLTException("Error adding app user.", ex, "User.vb", "Function AddAppUser() As Boolean")
        End Try

    End Function

    Function ApproveUserById() As Boolean

        Dim data As New DataAccess(SiteProfile.GetConnectionString, DataAccess.DataProvider.SQL)
        Dim dict As New System.Collections.Specialized.HybridDictionary

        Dim iParmId As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@UserId", DbType.Guid, Me.MembershipUser.ProviderUserKey, Me.MembershipUser.ProviderUserKey.ToString.Length, ParameterDirection.Input)
        Dim iParmApproved As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@IsApproved", DbType.Boolean, Me.MembershipUser.IsApproved, 1, ParameterDirection.Input)
        Dim iCmd As IDbCommand = data.GetCommand("sp__ApproveUserByID", CommandType.StoredProcedure, DataAccess.DataProvider.SQL)

        With iCmd.Parameters
            .Add(iParmID)
            .Add(iParmApproved)
        End With

        dict.Add(dict.Count, iCmd)

        Try
            Return data.ExecuteNonQuery(dict)
        Catch ex As Exception
            Throw New NLTException("Error saving approving/disapproving user.", ex, "User.vb", "Function ApproveUserById() As Boolean")
        End Try
    End Function

    Function Delete() As Boolean

        If Membership.DeleteUser(Me.MembershipUser.UserName, True) Then
            Dim data As New DataAccess(SiteProfile.GetConnectionString, DataAccess.DataProvider.SQL)
            Dim dict As New System.Collections.Specialized.HybridDictionary
            Dim iParmId As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@UserId", DbType.Guid, Me.MembershipUser.ProviderUserKey, Me.MembershipUser.ProviderUserKey.ToString.Length, ParameterDirection.Input)
            Dim iCmd As IDbCommand = data.GetCommand("sp__DeleteUser", CommandType.StoredProcedure, DataAccess.DataProvider.SQL)
            iCmd.Parameters.Add(iParmID)
            dict.Add(dict.Count, iCmd)
            Try
                Return data.ExecuteNonQuery(dict)
            Catch ex As Exception
                Throw New NLTException("Error deleting user.", ex, "User.vb", "Function Delete() As Boolean")
            End Try
        Else
            Return False
        End If

    End Function

    Sub Fill()

        Try

            Dim data As New DataAccess(SiteProfile.GetConnectionString, DataAccess.DataProvider.SQL)
            Dim strStoredProc As String = ""
            Dim iParmUserName As IDbDataParameter = Nothing
            Dim iCmd As IDbCommand = Nothing

            Select Case True
                Case Me.MembershipUser.UserName.Length > 0
                    strStoredProc = "sp__GetAppUserByUserName"
                    iParmUserName = data.GetParameter(DataAccess.DataProvider.SQL, "@UserName", DbType.String, Me.MembershipUser.UserName, 256, ParameterDirection.Input)
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
                    Me.UserName = Services.GetNULLableString(row("UserName"))
                    Me.FirstName = Services.GetNULLableString(row("FirstName"))
                    Me.LastName = Services.GetNULLableString(row("LastName"))
                    Me.AppUserId = Services.GetNULLableInteger(row("AppUserID"))
                End If
            End If

        Catch ex As Exception
            Throw New NLTException("Error retrieving App User.", ex, "User.vb", "Function Fill() As Boolean")
        End Try
    End Sub

    Function GetList() As DataTable
        Try
            Dim data As New DataAccess(SiteProfile.GetConnectionString, DataAccess.DataProvider.SQL)
            Dim iCmd As IDbCommand = data.GetCommand("sp__GetAppUsers", CommandType.StoredProcedure, DataAccess.DataProvider.SQL)
            Dim dt As DataTable = data.GetDataTable(iCmd)
            Return dt
        Catch ex As Exception
            Throw New NLTException("Error retrieving user list.", ex, "User.vb", "Function GetList() As DataTable")
        End Try

    End Function


    Function GetDefaultBuByUserId() As Integer
        Try
            Dim success As Boolean = False
            Dim dict As New System.Collections.Specialized.HybridDictionary
            Dim data As New DataAccess(SiteProfile.GetConnectionString, DataAccess.DataProvider.SQL)
            Dim iCmd As IDbCommand = data.GetCommand("sp__GetAppUserBUDefault", CommandType.StoredProcedure, DataAccess.DataProvider.SQL)
            Dim iParmId As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@UserId", DbType.Guid, Me.MembershipUser.ProviderUserKey, Me.MembershipUser.ProviderUserKey.ToString.Length, ParameterDirection.Input)
            Dim iParmBuId As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@BusUnitID", DbType.Int32, System.DBNull.Value, 4, ParameterDirection.Output)
            With iCmd.Parameters
                .Add(iParmID)
                .Add(iParmBUId)
            End With

            dict.Add(dict.Count, iCmd)

            success = data.ExecuteNonQuery(dict)
            If success Then
                Return iParmBUId.Value
            End If
        Catch ex As Exception
            Throw New NLTException("Error retrieving the default business unit for user.", ex, "User.vb", "Function GetDefaultBUByUserID() As Integer")
        End Try

    End Function

    Function GetBuByUserId() As DataTable
        Try
            Dim data As New DataAccess(SiteProfile.GetConnectionString, DataAccess.DataProvider.SQL)
            Dim iCmd As IDbCommand = data.GetCommand("sp__GetAppUserBusinessUnits", CommandType.StoredProcedure, DataAccess.DataProvider.SQL)
            Dim iParmId As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@UserId", DbType.Guid, Me.MembershipUser.ProviderUserKey, Me.MembershipUser.ProviderUserKey.ToString.Length, ParameterDirection.Input)
            iCmd.Parameters.Add(iParmID)
            Dim dt As DataTable = data.GetDataTable(iCmd)
            Return dt
        Catch ex As Exception
            Throw New NLTException("Error retrieving business units for user.", ex, "User.vb", "Function GetBUByUserID() As DataTable")
        End Try

    End Function

    Function UpdateUserDefaultBu(ByVal businessUnitId As Integer, ByVal lastModifiedBy As Integer) As Boolean

        Dim data As New DataAccess(SiteProfile.GetConnectionString, DataAccess.DataProvider.SQL)
        Dim dict As New System.Collections.Specialized.HybridDictionary

        Dim iParmId As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@UserID", DbType.Guid, Me.MembershipUser.ProviderUserKey, Me.MembershipUser.ProviderUserKey.ToString.Length, ParameterDirection.Input)
        Dim iParmBusIdList As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@BusUnitID", DbType.Int32, BusinessUnitID, 4, ParameterDirection.Input)
        Dim iParmIsDefault As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@IsDefault", DbType.Boolean, True, 1, ParameterDirection.Input)
        Dim iParmLastModBy As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@LastModBy", DbType.Int32, LastModifiedBy, 4, ParameterDirection.Input)
        Dim iCmd As IDbCommand = data.GetCommand("sp__UpdateAppUserDefaultBU", CommandType.StoredProcedure, DataAccess.DataProvider.SQL)
        With iCmd.Parameters
            .Add(iParmID)
            .Add(iParmBusIdList)
            .Add(iParmIsDefault)
            .Add(iParmLastModBy)
        End With

        dict.Add(dict.Count, iCmd)

        Try
            Return data.ExecuteNonQuery(dict)
        Catch ex As Exception
            Throw New NLTException("Error saving default user BU.", ex, "User.vb", "Function UpdateUserDefaultBU() As Boolean")
        End Try

    End Function

    Function UpdateAppUser(ByVal lastModifiedBy As Integer) As Boolean

        Dim data As New DataAccess(SiteProfile.GetConnectionString, DataAccess.DataProvider.SQL)
        Dim dict As New System.Collections.Specialized.HybridDictionary

        Dim iParmId As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@UserID", DbType.Guid, Me.MembershipUser.ProviderUserKey, Me.MembershipUser.ProviderUserKey.ToString.Length, ParameterDirection.Input)
        Dim iParmFirstName As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@FirstName", DbType.String, MyBase.FirstName, 50, ParameterDirection.Input)
        Dim iParmLastName As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@LastName", DbType.String, MyBase.LastName, 100, ParameterDirection.Input)
        Dim iParmLastModBy As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@LastModBy", DbType.Int32, LastModifiedBy, 4, ParameterDirection.Input)
        Dim iCmd As IDbCommand = data.GetCommand("sp__UpdateAppUser", CommandType.StoredProcedure, DataAccess.DataProvider.SQL)
        With iCmd.Parameters
            .Add(iParmID)
            .Add(iParmFirstName)
            .Add(iParmLastName)
            .Add(iParmLastModBy)
        End With

        dict.Add(dict.Count, iCmd)

        Try
            Return data.ExecuteNonQuery(dict)
        Catch ex As Exception
            Throw New NLTException("Error updating app user.", ex, "User.vb", "Function UpdateAppUser() As Boolean")
        End Try

    End Function

    Function UpdateUserBuList(ByVal buIdList As String, ByVal lastModifiedBy As Integer) As Boolean

        Dim data As New DataAccess(SiteProfile.GetConnectionString, DataAccess.DataProvider.SQL)
        Dim dict As New System.Collections.Specialized.HybridDictionary

        Dim iParmId As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@UserID", DbType.Guid, Me.MembershipUser.ProviderUserKey, Me.MembershipUser.ProviderUserKey.ToString.Length, ParameterDirection.Input)
        Dim iParmBusIdList As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@BusUnitIDList", DbType.String, BUIdList, 100, ParameterDirection.Input)
        Dim iParmActiveFlag As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@ActiveFlag", DbType.Boolean, True, 1, ParameterDirection.Input)
        Dim iParmLastModBy As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@LastModBy", DbType.Int32, LastModifiedBy, 4, ParameterDirection.Input)
        Dim iCmd As IDbCommand = data.GetCommand("sp__AddBusinessAppUser", CommandType.StoredProcedure, DataAccess.DataProvider.SQL)
        With iCmd.Parameters
            .Add(iParmID)
            .Add(iParmBusIdList)
            .Add(iParmActiveFlag)
            .Add(iParmLastModBy)
        End With

        dict.Add(dict.Count, iCmd)

        Try
            Return data.ExecuteNonQuery(dict)
        Catch ex As Exception
            Throw New NLTException("Error updating user business unit list.", ex, "User.vb", "Function UpdateUserBUList() As Boolean")
        End Try

    End Function

    Public Sub GoToEdit()
        My.Response.Redirect("~/cms/UserEdit.aspx")
    End Sub



End Class

