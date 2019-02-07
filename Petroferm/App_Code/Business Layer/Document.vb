Imports Microsoft.VisualBasic
Imports System.IO
Imports System.Configuration.ConfigurationManager

Public Class Document
    Inherits WorkflowItem
    Implements IDocument
    Private _mContentType As String
    Private _mDocPath As String
    Private _mDocFilename As String
    Private _mDocTitle As String
    Private _mDocumentId As Integer
    Private _mDocumentType As String
    Private _mProductId As Integer
    Private _mRegion As Region
    Private _mRegionId As Integer
    Private _mUploadDate As DateTime
    Public Sub New()

    End Sub
    Public Sub New(ByVal id As Integer)
        Me.DocumentId = id
    End Sub
    Public Property ContentType() As String Implements IDocument.ContentType
        Get
            Return _mContentType
        End Get
        Set(ByVal value As String)
            _mContentType = value
        End Set
    End Property

    Public Function Delete() As Boolean Implements IDocument.Delete

        ' TODO: CMS - Document.Delete - NEED TO DELETE/MOVE THE ACTUAL FILE SYSTEM DOCUMENT TO A DELETED FOLDER FIRST!
        ' THEN DELETE THE RECORD
        If DeleteDocumentFile() Then

            Dim success As Boolean
            Dim iCmd As IDbCommand
            Dim data As New DataAccess(SiteProfile.GetConnectionString, DataAccess.DataProvider.SQL)
            Dim dict As New System.Collections.Specialized.HybridDictionary

            iCmd = data.GetCommand("sp__DeleteDocument", CommandType.StoredProcedure, DataAccess.DataProvider.SQL)
            '@SearchAttribTypeID int = null,
            Dim iParmDocumentId As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@DocumentID", DbType.Int32, Me.DocumentId, 4, ParameterDirection.Input)
            '@UserID int = null,
            Dim iParmUserId As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@UserID", DbType.Int32, Me.LastModBy, 4, ParameterDirection.Input)
            '@JobID int = null,
            Dim iParmJobId As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@JobID", DbType.Int32, Me.JobID, 4, ParameterDirection.Input)
            '@WorkflowStatus varchar(50) = 'WORKING'
            ' no parm -- use default value

            With iCmd.Parameters
                .Add(iParmDocumentID)
                .Add(iParmJobID)
                .Add(iParmUserID)
            End With

            dict.Add(dict.Count, iCmd)

            Try
                success = data.ExecuteNonQuery(dict)
                Return success
            Catch ex As Exception
                Throw New NLTException("Error deleting Document.", ex, "Document.vb", "Function Delete() As Boolean")
            End Try
        End If



    End Function

    Public Property DocPath() As String Implements IDocument.DocPath
        Get
            Return _mDocPath
        End Get
        Set(ByVal value As String)
            _mDocPath = value
        End Set
    End Property

    Public ReadOnly Property DocFileName() As String Implements IDocument.DocFilename
        Get
            Dim parseStuff As String() = Me.DocPath.Split("/")
            _mDocFilename = parseStuff(parseStuff.Length - 1).ToString
            Return _mDocFilename
        End Get

    End Property

    Public Property DocTitle() As String Implements IDocument.DocTitle
        Get
            Return _mDocTitle
        End Get
        Set(ByVal value As String)
            _mDocTitle = value
        End Set
    End Property

    Public Property DocumentId() As Integer Implements IDocument.DocumentId
        Get
            Return _mDocumentId
        End Get
        Set(ByVal value As Integer)
            _mDocumentId = value
        End Set
    End Property

    Public ReadOnly Property DocumentType() As String Implements IDocument.DocumentType
        Get
            Return System.IO.Path.GetExtension(Me.DocPath).ToLower()
        End Get
    End Property

    Public Sub Fill(ByVal mode As Integer) Implements IDocument.Fill
        Try



            Dim data As New DataAccess(SiteProfile.GetConnectionString, DataAccess.DataProvider.SQL)
            Dim strStoredProc As String = ""
            Dim iParmId As IDbDataParameter = Nothing
            Dim iParmLiveMode As IDbDataParameter = Nothing
            Dim iCmd As IDbCommand = Nothing

            '   sp__GetDocumentByID()
            '	@DocID int = null,
            '	@LiveMode bit = 1


            If Me.DocumentId <> 0 Then
                strStoredProc = "sp__GetDocumentByID"
                iParmID = data.GetParameter(DataAccess.DataProvider.SQL, "@DocID", DbType.Int32, Me.DocumentId, 4, ParameterDirection.Input)
                iParmLiveMode = data.GetParameter(DataAccess.DataProvider.SQL, "@LiveMode", DbType.Int32, Convert.ToInt32(mode), 4, ParameterDirection.Input)
            End If

            ' THESE ARE USED FOR THE LIVE SITE
            ' MAYBE OVERLOAD THIS METHOD TO USE THEM
            ' 	@UserID int = 0,
            '	@URL varchar(500) = 'UNKNOWN',

            iCmd = data.GetCommand(strStoredProc, CommandType.StoredProcedure, DataAccess.DataProvider.SQL)
            With iCmd
                .Parameters.Add(iParmID)
                .Parameters.Add(iParmLiveMode)
            End With

            Dim dt As DataTable = data.GetDataTable(iCmd)

            If dt.Rows.Count > 0 Then
                Dim row As DataRow = dt.Rows(0)
                Me.DocTitle = Services.GetNULLableString(row("DocTitle"))
                Me.DocPath = Services.GetNULLableString(row("DocPath"))
                Me.ContentType = Services.GetNULLableString(row("ContentType"))
                Me.RegionId = Services.GetNULLableInteger(row("RegionID"))
                Me.UploadDate = Services.GetNULLableDateTime(row("UploadDate"))
                ' set workflow properties (CMS)
                Me.PublishDate = Convert.ToDateTime(row("PublishDate"))
                Me.ExpireDate = Convert.ToDateTime(row("ExpirationDate"))
                Me.WorkflowStatus = row("WorkflowStatus").ToString
                Me.LastModDate = Convert.ToDateTime(row("LastModifiedDate"))
                Me.LastModBy = Convert.ToInt32(row("LastModifiedBy"))
                Me.LastModByName = row("LastModifiedByName").ToString
                Me.MarkedForDelete = Convert.ToInt32(row("MarkedForDeletion"))
                Me.MarkedForDeleteFmt = row("FmtMarkedForDeletion").ToString
                Me.JobID = Convert.ToInt32(row("DeploymentJobID"))
                Me.JobName = row("JobName").ToString
                Me.JobDescription = row("JobDescription").ToString

            End If

        Catch ex As Exception
            Throw New NLTException("Error retrieving Document.", ex, "Document.vb", "Function Fill() As Boolean")
        End Try





    End Sub

    Public Property ProductId() As Integer Implements IDocument.ProductId
        Get
            Return _mProductId
        End Get
        Set(ByVal value As Integer)
            _mProductId = value
        End Set
    End Property

    Public Property Region() As Region Implements IDocument.Region
        Get
            Return _mRegion
        End Get
        Set(ByVal value As Region)
            _mRegion = value
        End Set
    End Property

    Public Property RegionId() As Integer Implements IDocument.RegionId
        Get
            Return _mRegionId
        End Get
        Set(ByVal value As Integer)
            _mRegionId = value
        End Set
    End Property

    Public Function Update() As Boolean Implements IDocument.Update
        Return Nothing
    End Function

    Public Property UploadDate() As Date Implements IDocument.UploadDate
        Get
            Return _mUploadDate
        End Get
        Set(ByVal value As Date)
            _mUploadDate = value
        End Set
    End Property

    Public Function GetContentTypeList() As String()
        Return System.Configuration.ConfigurationManager.AppSettings("DOC_TYPE_LIST").Split(",")
    End Function

    Public Function UploadDocument(ByVal docFile As FileUpload, ByVal isSecure As Boolean) As Boolean
        Dim fileOk As Boolean = False

        Dim physicalPath As String = ""

        If docFile.HasFile Then
            Dim fileExtension As String
            fileExtension = System.IO.Path. _
                GetExtension(docFile.FileName).ToLower()
            ' we're going to allow any extension for doc uploads
            'Dim allowedExtensions As String() = _
            '    {".pdf", ".doc"}
            'For i As Integer = 0 To allowedExtensions.Length - 1
            '    If fileExtension = allowedExtensions(i) Then
            '        fileOK = True
            '    End If
            'Next
            fileOK = True
            If fileOK Then
                Try

                    If isSecure Then
                        physicalPath = My.Request.MapPath("~/" & SiteProfile.GetSecureDocPath(String.Empty))
                        Me.DocPath = SiteProfile.GetSecureDocPath(docFile.FileName)
                    Else
                        physicalPath = My.Request.MapPath("~/" & SiteProfile.GetDocPath(String.Empty))
                        Me.DocPath = SiteProfile.GetDocPath(docFile.FileName)
                    End If

                    docFile.PostedFile.SaveAs(physicalPath & docFile.FileName)

                    Me.UploadDate = Today.Date
                    Return True
                Catch ex As Exception
                    Throw ex
                    Return False
                End Try
            End If
        Else ' just return true 
            Return True
        End If
    End Function

    Function DeleteDocumentFile() As Boolean

        Try
            Dim physicalPath As String = My.Request.MapPath(System.Configuration.ConfigurationManager.AppSettings("DOCS_DIRECTORY"))
            Dim deletedPhysicalPath As String = My.Request.MapPath(System.Configuration.ConfigurationManager.AppSettings("DELETE_DOCS_DIRECTORY"))
            If File.Exists(physicalPath & Me.DocFileName) Then
                File.Move(physicalPath & Me.DocFileName, deletedPhysicalPath & Me.DocFileName)
            End If
            Return True
        Catch ex As Exception
            Throw New NLTException("Error moving Document file to deleted folder.", ex, "Document.vb", "Function DeleteDocumentFile() As Boolean")
            Return False
        End Try



    End Function

    Public Function Save() As Boolean Implements IDocument.Save

        Dim success As Boolean
        Dim iCmd As IDbCommand
        Dim iParmDocumentId As IDbDataParameter

        Dim data As New DataAccess(SiteProfile.GetConnectionString, DataAccess.DataProvider.SQL)
        Dim dict As New System.Collections.Specialized.HybridDictionary
        Dim strStoredProc As String

        ' determine whether item should be added or updated
        If Me.DocumentId = 0 Then
            strStoredProc = "sp__AddDocument"
            iParmDocumentID = data.GetParameter(DataAccess.DataProvider.SQL, "@DocumentID", DbType.Int32, System.DBNull.Value, 4, ParameterDirection.Output)
        Else
            strStoredProc = "sp__UpdateDocument"
            iParmDocumentID = data.GetParameter(DataAccess.DataProvider.SQL, "@DocumentID", DbType.Int32, Me.DocumentId, 4, ParameterDirection.Input)
        End If

        '@ProductID int = null,
        Dim iParmProductId As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@ProductID", DbType.Int32, Me.ProductId, 4, ParameterDirection.Input)
        '@RegionID int = null,
        Dim iParmRegionId As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@RegionID", DbType.Int32, Me.RegionId, 4, ParameterDirection.Input)
        '@DocTitle varchar(100) = null,
        Dim iParmDocTitle As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@DocTitle", DbType.String, Me.DocTitle, 100, ParameterDirection.Input)
        '@DocPath varchar(500) = null,
        Dim iParmDocPath As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@DocPath", DbType.String, Me.DocPath, 500, ParameterDirection.Input)
        '@ContentType varchar(20) = null,
        Dim iParmContentType As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@ContentType", DbType.String, Me.ContentType, 20, ParameterDirection.Input)
        '@DocumentType varchar(50) = null,
        Dim iParmDocumentType As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@DocumentType", DbType.String, Me.DocumentType, 50, ParameterDirection.Input)
        '@UploadDate datetime = null,
        Dim iParmUploadDate As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@UploadDate", DbType.Date, Me.UploadDate, 8, ParameterDirection.Input)

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
            .Add(iParmDocumentID)
            .Add(iParmProductID)
            .Add(iParmRegionID)
            .Add(iParmDocTitle)
            .Add(iParmDocPath)
            .Add(iParmContentType)
            .Add(iParmDocumentType)
            .Add(iParmUploadDate)
            .Add(iParmPublishDate)
            .Add(iParmExpireDate)
            .Add(iParmJobID)
            .Add(iParmUserID)
        End With

        dict.Add(dict.Count, iCmd)

        Try
            success = data.ExecuteNonQuery(dict)
            If success Then
                If Me.DocumentId = 0 Then
                    ' set the id
                    Me.DocumentId = iParmDocumentID.Value
                End If
            End If

            Return success
        Catch ex As Exception
            Throw New NLTException("Error saving Document.", ex, "Document.vb", "Function Save() As Boolean")
        End Try




    End Function

    Function GetListByProduct(ByVal productId As Integer) As DataTable
        Try
            Dim data As New DataAccess(SiteProfile.GetConnectionString, DataAccess.DataProvider.SQL)
            Dim iCmd As IDbCommand = data.GetCommand("sp__GetDocumentsByProduct", CommandType.StoredProcedure, DataAccess.DataProvider.SQL)

            '	@ProductID int = null,
            Dim iParmProductId As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@ProductID", DbType.Int32, productID, 4, ParameterDirection.Input)

            '	@LiveMode bit = 0
            ' (parm not needed)
            With iCmd.Parameters
                .Add(iParmProductID)
            End With

            Dim dt As DataTable = data.GetDataTable(iCmd)
            If Not dt Is Nothing Then
                Return dt
            Else
                ' just return empty datatable
                dt = New DataTable
                Return dt
            End If

        Catch ex As Exception
            Throw New NLTException("Error retrieving Documents by Product.", ex, "Document.vb", "Function GetListByProduct(ByVal productID As Integer) As DataTable")
        End Try
    End Function
    Public Function GetListByBu(ByVal busUnitId As Integer, ByVal liveMode As Boolean) As DataTable
        Try
            Dim data As New DataAccess(SiteProfile.GetConnectionString, DataAccess.DataProvider.SQL)
            Dim iCmd As IDbCommand = data.GetCommand("sp__GetDocumentsByBU", CommandType.StoredProcedure, DataAccess.DataProvider.SQL)

            Dim iParmBusUnitId As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@BusUnitId", DbType.Int32, busUnitId, 4, ParameterDirection.Input)
            Dim iParmLiveMode As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@LiveMode", DbType.Boolean, liveMode, 1, ParameterDirection.Input)
            With iCmd.Parameters
                .Add(iParmBusUnitID)
                .Add(iParmLiveMode)
            End With

            Dim dt As DataTable = data.GetDataTable(iCmd)
            If Not dt Is Nothing Then
                Return dt
            Else
                Return Nothing
            End If

        Catch ex As Exception
            Throw New NLTException("Error retrieving Documents by BusinessUnit.", ex, "Document.vb", "Function GetListByBU(ByVal busUnitId As Integer, ByVal liveMode As Boolean) As DataTable")
        End Try
    End Function


End Class