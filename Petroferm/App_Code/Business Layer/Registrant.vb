Imports Microsoft.VisualBasic

Public Class Registrant
    Inherits Person

    Private _mRegistrantId As Integer
    Private _mRegion As String
    Private _mRegionId As Integer
    Private _mComments As String
    Private _mCompanyName As String
    Private _mUserName As String
    Private _mPassword As String
    Private _mConfirmedPassword As String
    Private _mMembershipId As Guid
    Private _mActiveFlag As Boolean

    Public Sub New()
        MyBase.New()
    End Sub

    Public Sub New(ByVal memUser As MembershipUser)
        MyBase.New()
        Me.MembershipUser = MemUser
    End Sub

    Public Property RegionId() As Integer
        Get
            Return _mRegionId
        End Get
        Set(ByVal value As Integer)
            _mRegionId = value
        End Set
    End Property

    Public Property RegistrantId() As Integer
        Get
            Return _mRegistrantId
        End Get
        Set(ByVal value As Integer)
            _mRegistrantId = value
        End Set
    End Property

    Public Property Region() As String
        Get
            Return _mRegion
        End Get
        Set(ByVal value As String)
            _mRegion = value
        End Set
    End Property

    Public Property Comments() As String
        Get
            Return _mComments
        End Get
        Set(ByVal value As String)
            _mComments = value
        End Set
    End Property

    Public Property CompanyName() As String
        Get
            Return _mCompanyName
        End Get
        Set(ByVal value As String)
            _mCompanyName = value
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

    Public Property Password() As String
        Get
            Return _mPassword
        End Get
        Set(ByVal value As String)
            _mPassword = value
        End Set
    End Property

    Public Property ConfirmedPassword() As String
        Get
            Return _mConfirmedPassword
        End Get
        Set(ByVal value As String)
            _mConfirmedPassword = value
        End Set
    End Property

    Public Property MembershipId() As Guid
        Get
            Return _mMembershipId
        End Get
        Set(ByVal value As Guid)
            _mMembershipId = value
        End Set
    End Property

    Public Property ActiveFlag() As Boolean
        Get
            Return _mActiveFlag
        End Get
        Set(ByVal value As Boolean)
            _mActiveFlag = value
        End Set
    End Property

    Public Function Save() As Boolean

        Dim success As Boolean
        Dim data As New DataAccess(SiteProfile.GetConnectionString, DataAccess.DataProvider.SQL)
        Dim dict As New System.Collections.Specialized.HybridDictionary

        Dim iparmRegId As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@RegId", DbType.Int32, System.DBNull.Value, 4, ParameterDirection.Output)
        Dim iparmMemberId As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@UserID", DbType.Guid, Me.MembershipId, 16, ParameterDirection.Input)
        Dim iparmRegionId As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@RegionID", DbType.Int32, 1, 4, ParameterDirection.Input)
        Dim iparmFullName As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@FullName", DbType.String, MyBase.FullName, 150, ParameterDirection.Input)
        Dim iparmCompanyName As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@CompanyName", DbType.String, Me.CompanyName, 300, ParameterDirection.Input)
        Dim iparmActiveFlag As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@ActiveFlag", DbType.Boolean, Me.ActiveFlag, 1, ParameterDirection.Input)
        Dim iparmLastModBy As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@LastModBy", DbType.Int32, 0, 4, ParameterDirection.Input)

        Dim iCmd As IDbCommand = data.GetCommand("sp__AddRegistrant", CommandType.StoredProcedure, DataAccess.DataProvider.SQL)
        With iCmd.Parameters
            .Add(iparmRegId)
            .Add(iparmRegionId)
            .Add(iparmMemberId)
            .Add(iparmFullName)
            .Add(iparmCompanyName)
            .Add(iparmActiveFlag)
            .Add(iparmLastModBy)
        End With

        dict.Add(dict.Count, iCmd)

        Try
            success = data.ExecuteNonQuery(dict)
            If success Then
                Me.RegistrantId = iparmRegId.Value
            End If
            Return success
        Catch ex As Exception
            Throw New NLTException("Error saving Registrant.", ex, "Registrant.vb", "Function Save() As Boolean")
        End Try

    End Function

    Function GetList() As DataTable
        Try
            Dim data As New DataAccess(SiteProfile.GetConnectionString, DataAccess.DataProvider.SQL)
            Dim iCmd As IDbCommand = data.GetCommand("sp__GetRegistrants", CommandType.StoredProcedure, DataAccess.DataProvider.SQL)
            Dim dt As DataTable = data.GetDataTable(iCmd)
            Return dt
        Catch ex As Exception
            Throw New NLTException("Error retrieving registrant list.", ex, "Registrant.vb", "Function GetList() As DataTable")
        End Try

    End Function

    Private _mMembershipUser As MembershipUser
    Property MembershipUser() As MembershipUser
        Get
            Return _mMembershipUser
        End Get
        Set(ByVal value As MembershipUser)
            _mMembershipUser = value
        End Set
    End Property


    Function Delete() As Boolean

        If Membership.DeleteUser(Me.MembershipUser.UserName, True) Then
            Dim data As New DataAccess(SiteProfile.GetConnectionString, DataAccess.DataProvider.SQL)
            Dim dict As New System.Collections.Specialized.HybridDictionary
            Dim iParmId As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@UserId", DbType.Guid, Me.MembershipUser.ProviderUserKey, Me.MembershipUser.ProviderUserKey.ToString.Length, ParameterDirection.Input)
            Dim iCmd As IDbCommand = data.GetCommand("sp__DeleteRegistrant", CommandType.StoredProcedure, DataAccess.DataProvider.SQL)
            iCmd.Parameters.Add(iParmID)
            dict.Add(dict.Count, iCmd)
            Try
                Return data.ExecuteNonQuery(dict)
            Catch ex As Exception
                Throw New NLTException("Error saving deleting registrant.", ex, "Registrant.vb", "Function Delete() As Boolean")
            End Try
        Else
            Return False
        End If

    End Function

End Class
