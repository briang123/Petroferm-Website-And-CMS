Imports Microsoft.VisualBasic

Public Class ContentModule
    Inherits PageModule
    Implements IContentModule
    Private _mContentId As Integer
    Private _mContent As String
    Private _mContentTitle As String
    Private _mLiveModeStatus As Boolean

    Sub New()
        MyBase.New()
    End Sub

    Sub New(ByVal contentId As Integer, ByVal liveMode As WorkflowItem.LiveMode)
        Me.ContentId = contentId
        Me.LiveModeStatus = liveMode
        Me.Fill()
    End Sub

    Public Property LiveModeStatus() As Boolean Implements IContentModule.LiveModeStatus
        Get
            Return _mLiveModeStatus
        End Get
        Set(ByVal value As Boolean)
            _mLiveModeStatus = value
        End Set
    End Property

    Public Property Content() As String Implements IContentModule.Content
        Get
            Return _mContent
        End Get
        Set(ByVal value As String)
            _mContent = value
        End Set
    End Property

    Public Property ContentId() As Integer Implements IContentModule.ContentId
        Get
            Return _mContentId
        End Get
        Set(ByVal value As Integer)
            _mContentId = value
        End Set
    End Property

    Public Property ContentTitle() As String Implements IContentModule.ContentTitle
        Get
            Return _mContentTitle
        End Get
        Set(ByVal value As String)
            _mContentTitle = value
        End Set
    End Property

    Public Function Delete() As Boolean Implements IContentModule.Delete
        Dim success As Boolean
        Dim iCmd As IDbCommand
        Dim data As New DataAccess(SiteProfile.GetConnectionString, DataAccess.DataProvider.SQL)
        Dim dict As New System.Collections.Specialized.HybridDictionary

        'proc(sp__DeleteContentModule)
        iCmd = data.GetCommand("sp__DeleteContentModule", CommandType.StoredProcedure, DataAccess.DataProvider.SQL)
        '@ContentID int = null,
        Dim iParmContentId As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@ContentID", DbType.Int32, Me.ContentId, 4, ParameterDirection.Input)
        '@UserID int = null,
        Dim iParmUserId As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@UserID", DbType.Int32, Me.LastModBy, 4, ParameterDirection.Input)
        '@JobID int = null,
        Dim iParmJobId As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@JobID", DbType.Int32, Me.JobID, 4, ParameterDirection.Input)
        '@WorkflowStatus varchar(50) = 'WORKING'
        ' no parm -- use default value

        With iCmd.Parameters
            .Add(iParmContentID)
            .Add(iParmJobID)
            .Add(iParmUserID)
        End With

        dict.Add(dict.Count, iCmd)

        Try
            success = data.ExecuteNonQuery(dict)
            Return success
        Catch ex As Exception
            Throw New NLTException("Error deleting Content Module.", ex, "ContentModule.vb", "Function Delete() As Boolean")

        End Try




    End Function

    Public Sub Fill() Implements IContentModule.Fill

        Dim data As New DataAccess(SiteProfile.GetConnectionString, DataAccess.DataProvider.SQL)
        Dim iCmd As IDbCommand = data.GetCommand("sp__GetContentModuleByModID", CommandType.StoredProcedure, DataAccess.DataProvider.SQL)
        Dim iParmId As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@ContentId", DbType.Int32, Me.ContentId, 4, ParameterDirection.Input)
        Dim iParmLiveMode As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@LiveMode", DbType.Boolean, Me.LiveModeStatus, 1, ParameterDirection.Input)
        With iCmd.Parameters
            .Add(iParmID)
            .Add(iParmLiveMode)
        End With
        Dim dt As DataTable = data.GetDataTable(iCmd)

        For Each row As DataRow In dt.Rows
            Me.ContentId = Services.GetNULLableInteger(row("ContentId"))
            Me.Content = Services.GetNULLableString(row("Content"))
            Me.ContentTitle = Services.GetNULLableString(row("Title"))
            MyBase.ModuleType = Services.GetNULLableString(row("SourceName"))

            'workflow item
            MyBase.ExpireDate = Services.GetNULLableDateTime(row("ExpirationDate"))
            MyBase.PublishDate = Services.GetNULLableDateTime(row("PublishDate"))
            MyBase.WorkflowStatus = Services.GetNULLableString(row("WorkflowStatus"))
            MyBase.LastModDate = Services.GetNULLableDateTime(row("LastModifiedDate"))
            MyBase.LastModBy = Services.GetNULLableInteger(row("LastModifiedBy"))
            MyBase.LastModByName = Services.GetNULLableString(row("LastModifiedByName"))
            MyBase.MarkedForDelete = Services.GetNULLableBoolean(row("MarkedForDeletion"))
            MyBase.MarkedForDeleteFmt = Services.GetNULLableString(row("FmtMarkedForDeletion"))
            MyBase.ModuleOrder = Services.GetNULLableInteger(row("ModuleOrder"))
            MyBase.PageModuleRelnId = Services.GetNULLableInteger(row("PageModuleRelnID"))
            MyBase.ShowTitle = Services.GetNULLableBoolean(row("ShowTitle"))
            MyBase.JobID = Services.GetNULLableInteger(row("DeploymentJobID"))
            MyBase.JobName = Services.GetNULLableString(row("JobName"))
            MyBase.JobDescription = Services.GetNULLableString(row("JobDescription"))
        Next

    End Sub

    Public Function Save() As Boolean Implements IContentModule.Save
        Dim success As Boolean
        Dim iCmd As IDbCommand
        Dim iParmContentId As IDbDataParameter
        Dim iParmPageModuleRelnId As IDbDataParameter = Nothing
        Dim iParmPageId As IDbDataParameter = Nothing

        Dim data As New DataAccess(SiteProfile.GetConnectionString, DataAccess.DataProvider.SQL)
        Dim dict As New System.Collections.Specialized.HybridDictionary
        Dim strStoredProc As String

        ' determine whether item should be added or updated
        '@ContentID int = null,
        If Me.ContentId = 0 Then
            strStoredProc = "sp__AddContentModule"
            '@PageID int = null,
            iParmPageID = data.GetParameter(DataAccess.DataProvider.SQL, "@PageID", DbType.Int32, Me.PageId, 4, ParameterDirection.Input)
            iParmContentID = data.GetParameter(DataAccess.DataProvider.SQL, "@ContentID", DbType.Int32, System.DBNull.Value, 4, ParameterDirection.Output)
            iParmPageModuleRelnID = data.GetParameter(DataAccess.DataProvider.SQL, "@PageModuleRelnID", DbType.Int32, System.DBNull.Value, 4, ParameterDirection.Output)
        Else
            strStoredProc = "sp__UpdateContentModule"
            iParmContentID = data.GetParameter(DataAccess.DataProvider.SQL, "@ContentID", DbType.Int32, Me.ContentId, 4, ParameterDirection.Input)
            iParmPageModuleRelnID = data.GetParameter(DataAccess.DataProvider.SQL, "@PageModuleRelnID", DbType.Int32, Me.PageModuleRelnId, 4, ParameterDirection.Input)
        End If

        '@ModuleType varchar(50) = null,
        Dim iParmModuleType As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@ModuleType", DbType.String, Me.ModuleType, 50, ParameterDirection.Input)
        '@ModuleOrder int = null,
        Dim iParmModuleOrder As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@ModuleOrder", DbType.Int32, Me.ModuleOrder, 4, ParameterDirection.Input)
        '@ShowTitle bit = 0,
        Dim iParmShowTitle As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@ShowTitle", DbType.Boolean, Me.ShowTitle, 1, ParameterDirection.Input)
        '@Title varchar(50) = null,
        Dim iParmTitle As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@Title", DbType.String, Me.ContentTitle, 50, ParameterDirection.Input)
        '@Content text = null,
        Dim iParmContent As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@Content", DbType.String, Me.Content, Me.Content.Length, ParameterDirection.Input)
        '@PublishDate datetime = null,
        Dim iParmPublishDate As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@PublishDate", DbType.Date, Me.PublishDate, 8, ParameterDirection.Input)
        '@ExpireDate datetime = null,
        Dim iParmExpireDate As IDbDataParameter
        If Me.ExpireDate <> #12:00:00 AM# Then
            iParmExpireDate = data.GetParameter(DataAccess.DataProvider.SQL, "@ExpireDate", DbType.Date, Me.ExpireDate, 8, ParameterDirection.Input)
        Else
            iParmExpireDate = data.GetParameter(DataAccess.DataProvider.SQL, "@ExpireDate", DbType.Date, System.DBNull.Value, 8, ParameterDirection.Input)
        End If
        '@MarkedForDeletion bit = 0,
        ' just use default value
        '@WorkflowStatus varchar(50) = 'WORKING',
        ' just use default value
        '@JobID int = null,
        Dim iParmJobId As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@JobID", DbType.Int32, Me.JobID, 4, ParameterDirection.Input)
        '@UserID int = null,
        Dim iParmUserId As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@UserID", DbType.Int32, Me.LastModBy, 4, ParameterDirection.Input)

        '' create cmd and add parms
        iCmd = data.GetCommand(strStoredProc, CommandType.StoredProcedure, DataAccess.DataProvider.SQL)
        With iCmd.Parameters
            .Add(iParmContentID)
            If iParmPageID IsNot Nothing Then
                .Add(iParmPageID)
            End If
            .Add(iParmPageModuleRelnID)
            .Add(iParmModuleType)
            .Add(iParmModuleOrder)
            .Add(iParmShowTitle)
            .Add(iParmTitle)
            .Add(iParmContent)
            .Add(iParmPublishDate)
            .Add(iParmExpireDate)
            .Add(iParmJobID)
            .Add(iParmUserID)
        End With

        dict.Add(dict.Count, iCmd)

        Try
            success = data.ExecuteNonQuery(dict)
            If success Then
                If Me.ContentId = 0 Then
                    ' set the id
                    Me.ContentId = iParmContentID.Value
                End If
            End If

            Return success
        Catch ex As Exception
            Throw New NLTException("Error saving Content Module.", ex, "ContentModule.vb", "Function Save() As Boolean")
        End Try




    End Function

End Class


