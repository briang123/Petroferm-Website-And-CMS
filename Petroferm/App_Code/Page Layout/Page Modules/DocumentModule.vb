Imports Microsoft.VisualBasic

Public Class DocumentModule
    Inherits PageModule
    Implements IDocumentModule

    Private _mDocumentId As Integer
    Private _mDocumentRelnId As Integer
    Private _mLinkText As String
    Private _mSectionId As Integer
    Private _mDocumentFile As Document
    Private _mLiveModeStatus As LiveMode

    Public Property DocumentId() As Integer Implements IDocumentModule.DocumentId
        Get
            Return _mDocumentId
        End Get
        Set(ByVal value As Integer)
            _mDocumentId = value
        End Set
    End Property

    Public Property DocumentRelnId() As Integer Implements IDocumentModule.DocumentRelnId
        Get
            Return _mDocumentRelnId
        End Get
        Set(ByVal value As Integer)
            _mDocumentRelnId = value
        End Set
    End Property

    Public Property DocumentFile() As Document Implements IDocumentModule.DocumentFile
        Get
            Return _mDocumentFile
        End Get
        Set(ByVal value As Document)
            _mDocumentFile = value
        End Set
    End Property

    Public Property LinkText() As String Implements IDocumentModule.LinkText
        Get
            Return _mLinkText
        End Get
        Set(ByVal value As String)
            _mLinkText = value
        End Set
    End Property

    Public Property SectionId() As Integer Implements IDocumentModule.SectionId
        Get
            Return _mSectionId
        End Get
        Set(ByVal value As Integer)
            _mSectionId = value
        End Set
    End Property

    Public Property LiveModeStatus() As LiveMode Implements IDocumentModule.LiveModeStatus
        Get
            Return _mLiveModeStatus
        End Get
        Set(ByVal value As LiveMode)
            _mLiveModeStatus = value
        End Set
    End Property

    Public Function Delete() As Boolean Implements IDocumentModule.Delete
        Dim success As Boolean
        Dim iCmd As IDbCommand
        Dim data As New DataAccess(SiteProfile.GetConnectionString, DataAccess.DataProvider.SQL)
        Dim dict As New System.Collections.Specialized.HybridDictionary

        'proc(sp__DeleteContentModule)
        iCmd = data.GetCommand("sp__DeleteDocumentModule", CommandType.StoredProcedure, DataAccess.DataProvider.SQL)
        '@DocumentModuleRelnID int = null,
        Dim iParmDocModuleRelnId As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@DocumentModuleRelnID", DbType.Int32, Me.DocumentRelnId, 4, ParameterDirection.Input)
        '@UserID int = null,
        Dim iParmUserId As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@UserID", DbType.Int32, Me.LastModBy, 4, ParameterDirection.Input)
        '@JobID int = null,
        Dim iParmJobId As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@JobID", DbType.Int32, Me.JobID, 4, ParameterDirection.Input)
        '@WorkflowStatus varchar(50) = 'WORKING'
        ' no parm -- use default value

        With iCmd.Parameters
            .Add(iParmDocModuleRelnID)
            .Add(iParmJobID)
            .Add(iParmUserID)
        End With

        dict.Add(dict.Count, iCmd)

        Try
            success = data.ExecuteNonQuery(dict)
            Return success
        Catch ex As Exception
            Throw New NLTException("Error deleting Document Module.", ex, "DocumentModule.vb", "Function Delete() As Boolean")

        End Try
    End Function

    Public Sub Fill() Implements IDocumentModule.Fill

        Dim data As New DataAccess(SiteProfile.GetConnectionString, DataAccess.DataProvider.SQL)
        Dim iCmd As IDbCommand = data.GetCommand("sp__GetDocumentModuleByModId", CommandType.StoredProcedure, DataAccess.DataProvider.SQL)
        Dim iParmId As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@ModId", DbType.Int32, Me.DocumentRelnId, 4, ParameterDirection.Input)
        Dim iParmLiveMode As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@LiveMode", DbType.Boolean, LiveModeStatus, 1, ParameterDirection.Input)
        With iCmd
            .Parameters.Add(iParmID)
            .Parameters.Add(iParmLiveMode)
        End With

        Dim dt As DataTable = data.GetDataTable(iCmd)

        For Each row As DataRow In dt.Rows
            With Me
                .DocumentRelnId = Services.GetNULLableInteger(row("DM_DocumentModuleRelnID"))
                .DocumentId = Services.GetNULLableInteger(row("DM_DocumentID"))
                .LinkText = Services.GetNULLableString(row("DM_LinkText"))
                .SectionId = Services.GetNULLableInteger(row("DM_SectionID"))
                .PublishDate = Services.GetNULLableDateTime(row("DM_PublishDate"))
                .ExpireDate = Services.GetNULLableDateTime(row("DM_ExpirationDate"))
                .WorkflowStatus = Services.GetNULLableString(row("DM_WorkflowStatus"))
                .LastModDate = Services.GetNULLableDateTime(row("DM_LastModDate"))
                .LastModBy = Services.GetNULLableInteger(row("DM_LastModBy"))
                .ActiveFlag = Services.GetNULLableBoolean(row("DM_ActiveFlag"))
                .MarkedForDelete = Services.GetNULLableBoolean(row("DM_MarkedForDeletion"))
                .MarkedForDeleteFmt = Services.GetNULLableString(row("DM_FmtMarkedForDeletion"))
                .JobID = Services.GetNULLableInteger(row("DM_JobId"))
                .JobDescription = Services.GetNULLableString(row("DM_JobDescription"))
                .LastModByName = Services.GetNULLableString(row("DM_LastModByName"))
                With .DocumentFile
                    .ProductId = Services.GetNULLableInteger(row("D_ProductID"))
                    .RegionId = Services.GetNULLableInteger(row("D_RegionID"))
                    .DocTitle = Services.GetNULLableString(row("D_DocTitle"))
                    .DocPath = Services.GetNULLableString(row("D_DocPath"))
                    .ContentType = Services.GetNULLableString(row("D_ContentType"))
                    .UploadDate = Services.GetNULLableDateTime(row("D_UploadDate"))
                    .PublishDate = Services.GetNULLableDateTime(row("D_PublishDate"))
                    .ExpireDate = Services.GetNULLableDateTime(row("D_ExpirationDate"))
                    .WorkflowStatus = Services.GetNULLableString(row("D_WorkflowStatus"))
                    .LastModDate = Services.GetNULLableDateTime(row("D_LastModDate"))
                    .LastModBy = Services.GetNULLableInteger(row("D_LastModBy"))
                    .ActiveFlag = Services.GetNULLableBoolean(row("D_ActiveFlag"))
                    .MarkedForDelete = Services.GetNULLableBoolean(row("D_MarkedForDeletion"))
                    .MarkedForDeleteFmt = Services.GetNULLableString(row("D_FmtMarkedForDeletion"))
                    .JobID = Services.GetNULLableInteger(row("D_JobId"))
                    .JobDescription = Services.GetNULLableString(row("D_JobDescription"))
                    .LastModByName = Services.GetNULLableString(row("D_LastModByName"))
                End With

            End With
        Next

    End Sub

    Public Function Save() As Boolean Implements IDocumentModule.Save

        Dim success As Boolean
        Dim iCmd As IDbCommand
        Dim iParmDocumentModuleRelnId As IDbDataParameter
        Dim iParmPageModuleRelnId As IDbDataParameter = Nothing
        Dim iParmPageId As IDbDataParameter = Nothing

        Dim data As New DataAccess(SiteProfile.GetConnectionString, DataAccess.DataProvider.SQL)
        Dim dict As New System.Collections.Specialized.HybridDictionary
        Dim strStoredProc As String

        ' determine whether item should be added or updated
        If Me.DocumentRelnId = 0 Then
            strStoredProc = "sp__AddDocumentModule"
            '@PageID int = null,
            iParmPageID = data.GetParameter(DataAccess.DataProvider.SQL, "@PageID", DbType.Int32, Me.PageId, 4, ParameterDirection.Input)
            iParmDocumentModuleRelnID = data.GetParameter(DataAccess.DataProvider.SQL, "@DocumentModuleRelnID", DbType.Int32, System.DBNull.Value, 4, ParameterDirection.Output)
            iParmPageModuleRelnID = data.GetParameter(DataAccess.DataProvider.SQL, "@PageModuleRelnID", DbType.Int32, System.DBNull.Value, 4, ParameterDirection.Output)
        Else
            strStoredProc = "sp__UpdateDocumentModule"
            iParmDocumentModuleRelnID = data.GetParameter(DataAccess.DataProvider.SQL, "@DocumentModuleRelnID", DbType.Int32, Me.DocumentRelnId, 4, ParameterDirection.Input)
        End If

        '@DocumentID int = null, -- must already exist
        Dim iParmDocumentId As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@DocumentID", DbType.Int32, Me.DocumentId, 4, ParameterDirection.Input)
        '@LinkText varchar(100) = null,
        Dim iParmLinkText As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@LinkText", DbType.String, Me.LinkText, 100, ParameterDirection.Input)
        '@SectionID int = null,
        Dim iParmSectionId As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@SectionID", DbType.Int32, Me.SectionId, 4, ParameterDirection.Input)
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
            .Add(iParmDocumentModuleRelnID)
            If iParmPageID IsNot Nothing Then
                .Add(iParmPageID)
            End If
            If iParmPageModuleRelnID IsNot Nothing Then
                .Add(iParmPageModuleRelnID)
            End If
            .Add(iParmDocumentID)
            .Add(iParmLinkText)
            .Add(iParmSectionID)
            .Add(iParmPublishDate)
            .Add(iParmExpireDate)
            .Add(iParmJobID)
            .Add(iParmUserID)
        End With

        dict.Add(dict.Count, iCmd)

        Try
            success = data.ExecuteNonQuery(dict)
            If success Then
                If Me.DocumentRelnId = 0 And iParmDocumentModuleRelnID.Value IsNot System.DBNull.Value Then
                    ' set the id
                    Me.DocumentRelnId = iParmDocumentModuleRelnID.Value
                End If
            End If

            Return success
        Catch ex As Exception
            Throw New NLTException("Error saving Document Module.", ex, "DocumentModule.vb", "Function Save() As Boolean")
        End Try

    End Function



End Class
