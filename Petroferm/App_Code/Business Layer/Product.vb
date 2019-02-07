Imports Microsoft.VisualBasic

Public Class Product
    Inherits WorkflowItem
    Implements IProduct

    Private _mDocuments As Documents
    Private _mProductId As Integer
    Private _mProductName As String = ""
    Private _mBusUnitId As Integer
    Private _mProductKeywords As String = ""
    Private _mProductBlurb As String = ""
    Private _mProductApprovals As String = ""

    Public Sub New(ByVal prodId As Integer)
        ProductID = prodID
        Me.Fill()
    End Sub

    Public Sub New()

    End Sub

    Public Property BusUnitId() As Integer Implements IProduct.BusUnitId
        Get
            Return _mBusUnitId
        End Get
        Set(ByVal value As Integer)
            _mBusUnitId = value
        End Set
    End Property

    Public Property ProductApprovals() As String Implements IProduct.ProductApprovals
        Get
            Return _mProductApprovals
        End Get
        Set(ByVal value As String)
            _mProductApprovals = value.Trim
        End Set
    End Property

    Public Property ProductBlurb() As String Implements IProduct.ProductBlurb
        Get
            Return _mProductBlurb
        End Get
        Set(ByVal value As String)
            _mProductBlurb = value
        End Set
    End Property

    Public Property ProductId() As Integer Implements IProduct.ProductId
        Get
            Return _mProductId
        End Get
        Set(ByVal value As Integer)
            _mProductId = value
        End Set
    End Property

    Public Property ProductKeywords() As String Implements IProduct.ProductKeywords
        Get
            Return _mProductKeywords
        End Get
        Set(ByVal value As String)
            _mProductKeywords = value.Trim
        End Set
    End Property

    Public Property ProductName() As String Implements IProduct.ProductName
        Get
            Return _mProductName
        End Get
        Set(ByVal value As String)
            _mProductName = value.Trim
        End Set
    End Property

    Public Function Save() As Boolean Implements IProduct.Save



        Dim success As Boolean
        Dim iCmd As IDbCommand
        Dim iParmProductId As IDbDataParameter

        Dim data As New DataAccess(SiteProfile.GetConnectionString, DataAccess.DataProvider.SQL)
        Dim dict As New System.Collections.Specialized.HybridDictionary
        Dim strStoredProc As String

        ' determine whether item should be added or updated
        If Me.ProductID = 0 Then
            strStoredProc = "sp__AddProduct"
            iParmProductID = data.GetParameter(DataAccess.DataProvider.SQL, "@ProductID", DbType.Int32, System.DBNull.Value, 4, ParameterDirection.Output)
        Else
            strStoredProc = "sp__UpdateProduct"
            iParmProductID = data.GetParameter(DataAccess.DataProvider.SQL, "@ProductID", DbType.Int32, Me.ProductID, 4, ParameterDirection.Input)
        End If

        '@BusUnitID int = null,
        Dim iParmBusId As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@BusUnitID", DbType.Int32, Me.BusUnitID, 4, ParameterDirection.Input)
        '@ProductName varchar(200) = null,
        Dim iParmProductName As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@ProductName", DbType.String, Me.ProductName, 200, ParameterDirection.Input)
        '@ProductKeywords varchar(200) = null,
        Dim iParmProductKeywords As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@ProductKeywords", DbType.String, Me.ProductKeywords, 200, ParameterDirection.Input)
        '@ProductBlurb varchar(2000) = null,
        Dim iParmProductBlurb As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@ProductBlurb", DbType.String, Me.ProductBlurb, 2000, ParameterDirection.Input)
        '@ProductApprovals varchar(2000) = null,
        Dim iParmProductApprovals As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@ProductApprovals", DbType.String, Me.ProductApprovals, 2000, ParameterDirection.Input)

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
            .Add(iParmProductID)
            .Add(iParmBusID)
            .Add(iParmProductName)
            .Add(iParmProductKeywords)
            .Add(iParmProductBlurb)
            .Add(iParmProductApprovals)
            .Add(iParmPublishDate)
            .Add(iParmExpireDate)
            .Add(iParmJobID)
            .Add(iParmUserID)
        End With

        dict.Add(dict.Count, iCmd)

        Try
            success = data.ExecuteNonQuery(dict)
            If success Then
                If Me.ProductID = 0 Then
                    ' set the id
                    Me.ProductID = iParmProductID.Value
                End If
            End If

            Return success
        Catch ex As Exception
            Throw New NLTException("Error saving Product.", ex, "Product.vb", "Function Save() As Boolean")
        End Try
    End Function

    Public Function Delete() As Boolean Implements IProduct.Delete
        Dim success As Boolean
        Dim iCmd As IDbCommand
        Dim data As New DataAccess(SiteProfile.GetConnectionString, DataAccess.DataProvider.SQL)
        Dim dict As New System.Collections.Specialized.HybridDictionary

        'proc(sp__DeleteProductAttribute)
        iCmd = data.GetCommand("sp__DeleteProduct", CommandType.StoredProcedure, DataAccess.DataProvider.SQL)
        '@ProductID int = null,
        Dim iParmProductId As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@ProductID", DbType.Int32, Me.ProductID, 4, ParameterDirection.Input)
        '@UserID int = null,
        Dim iParmUserId As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@UserID", DbType.Int32, Me.LastModBy, 4, ParameterDirection.Input)
        '@JobID int = null,
        Dim iParmJobId As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@JobID", DbType.Int32, Me.JobID, 4, ParameterDirection.Input)
        '@WorkflowStatus varchar(50) = 'WORKING'
        ' no parm -- use default value

        With iCmd.Parameters
            .Add(iParmProductID)
            .Add(iParmJobID)
            .Add(iParmUserID)
        End With

        dict.Add(dict.Count, iCmd)

        Try
            success = data.ExecuteNonQuery(dict)
            Return success
        Catch ex As Exception
            Throw New NLTException("Error deleting Product.", ex, "Product.vb", "Function Delete() As Boolean")
        End Try
    End Function

    Public Sub Fill() Implements IProduct.Fill
        Try
            Dim data As New DataAccess(SiteProfile.GetConnectionString, DataAccess.DataProvider.SQL)
            Dim dict As New System.Collections.Specialized.HybridDictionary

            'PROC(sp__GetProductAttributeByID)
            Dim strStoredProc As String = "sp__GetProductByID"

            '@ProductID int = null,
            Dim iParmProductId As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@ProductID", DbType.Int32, Me.ProductID, 4, ParameterDirection.Input)
            '@BusUnitID int OUTPUT,
            Dim iParmBusUnitId As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@BusUnitID", DbType.Int32, System.DBNull.Value, 4, ParameterDirection.Output)
            '@ProductName varchar(200) OUTPUT,
            Dim iParmProductName As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@ProductName", DbType.String, String.Empty, 200, ParameterDirection.Output)
            '@ProductKeywords varchar(200) OUTPUT,
            Dim iParmProductKeywords As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@ProductKeywords", DbType.String, String.Empty, 200, ParameterDirection.Output)
            '@ProductBlurb varchar(2000) OUTPUT,
            Dim iParmProductBlurb As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@ProductBlurb", DbType.String, String.Empty, 2000, ParameterDirection.Output)
            '@ProductApprovals varchar(2000) OUTPUT,
            Dim iParmProductApprovals As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@ProductApprovals", DbType.String, String.Empty, 2000, ParameterDirection.Output)
            '@PublishDate datetime OUTPUT,
            Dim iParmPublishDate As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@PublishDate", DbType.Date, System.DBNull.Value, 8, ParameterDirection.Output)
            '@ExpireDate datetime OUTPUT,
            Dim iParmExpireDate As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@ExpireDate", DbType.Date, System.DBNull.Value, 8, ParameterDirection.Output)
            '@WorkflowStatus varchar(50) OUTPUT,
            Dim iParmWorkflowStatus As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@WorkflowStatus", DbType.String, System.DBNull.Value, 50, ParameterDirection.Output)
            '@LastModifiedDate datetime OUTPUT,
            Dim iParmLastModifiedDate As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@LastModifiedDate", DbType.Date, System.DBNull.Value, 8, ParameterDirection.Output)
            '@LastModifiedBy int OUTPUT,
            Dim iParmLastModifiedBy As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@LastModifiedBy", DbType.Int32, System.DBNull.Value, 4, ParameterDirection.Output)
            '@LastModifiedByName varchar(150) OUTPUT,
            Dim iParmLastModifiedByName As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@LastModifiedByName", DbType.String, System.DBNull.Value, 150, ParameterDirection.Output)
            '@FmtMarkedForDeletion varchar(3) OUTPUT,
            Dim iParmFmtMarkedForDeletion As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@FmtMarkedForDeletion", DbType.String, String.Empty, 3, ParameterDirection.Output)
            '@MarkedForDeletion bit OUTPUT,
            Dim iParmMarkedForDeletion As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@MarkedForDeletion", DbType.Int32, System.DBNull.Value, 1, ParameterDirection.Output)
            '@JobID int OUTPUT,
            Dim iParmJobId As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@JobID", DbType.Int32, JobID, 4, ParameterDirection.Output)
            '@JobName varchar(100) OUTPUT,
            Dim iParmJobName As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@JobName", DbType.String, System.DBNull.Value, 100, ParameterDirection.Output)
            '@JobDescription varchar(500) OUTPUT
            Dim iParmJobDescription As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@JobDescription", DbType.String, System.DBNull.Value, 500, ParameterDirection.Output)

            Dim iCmd As IDbCommand = data.GetCommand(strStoredProc, CommandType.StoredProcedure, DataAccess.DataProvider.SQL)
            With iCmd.Parameters
                .Add(iParmProductID)
                .Add(iParmBusUnitID)
                .Add(iParmProductName)
                .Add(iParmProductKeywords)
                .Add(iParmProductBlurb)
                .Add(iParmProductApprovals)
                .Add(iParmPublishDate)
                .Add(iParmExpireDate)
                .Add(iParmWorkflowStatus)
                .Add(iParmLastModifiedDate)
                .Add(iParmLastModifiedBy)
                .Add(iParmLastModifiedByName)
                .Add(iParmFmtMarkedForDeletion)
                .Add(iParmMarkedForDeletion)
                .Add(iParmJobID)
                .Add(iParmJobName)
                .Add(iParmJobDescription)
            End With

            dict.Add(dict.Count, iCmd)

            If data.ExecuteNonQuery(dict) Then

                ' check to make sure something came back
                If Not iParmBusUnitID.Value Is System.DBNull.Value Then
                    ' fill properties
                    Me.BusUnitID = Services.GetNULLableInteger(iParmBusUnitID.Value)
                    Me.ProductName = iParmProductName.Value.ToString
                    Me.ProductKeywords = iParmProductKeywords.Value.ToString
                    Me.ProductBlurb = iParmProductBlurb.Value.ToString
                    Me.ProductApprovals = iParmProductApprovals.Value.ToString
                    ' fill workflow properties
                    Me.WorkflowStatus = iParmWorkflowStatus.Value.ToString
                    Me.MarkedForDelete = Services.GetNULLableInteger(iParmMarkedForDeletion.Value)
                    Me.MarkedForDeleteFmt = iParmFmtMarkedForDeletion.Value.ToString
                    Me.PublishDate = Services.GetNULLableDateTime(iParmPublishDate.Value)
                    Me.ExpireDate = Services.GetNULLableDateTime(iParmExpireDate.Value)
                    Me.LastModDate = Services.GetNULLableDateTime(iParmLastModifiedDate.Value)
                    Me.LastModBy = Services.GetNULLableInteger(iParmLastModifiedBy.Value)
                    Me.LastModByName = iParmLastModifiedByName.Value.ToString
                    Me.JobID = Services.GetNULLableInteger(iParmJobID.Value)
                    Me.JobName = iParmJobName.Value.ToString
                    Me.JobDescription = iParmJobDescription.Value.ToString

                    Me.Documents = Me.GetDocuments()

                Else
                    Dim ex As New Exception("No Product was returned for Product ID " & Me.ProductID)
                    Throw New NLTException("Error retrieving Product.", ex, "Product.vb", "Sub Fill()")
                End If
            End If

        Catch ex As Exception
            Throw New NLTException("Error retrieving Product.", ex, "Product.vb", "Sub Fill()")
        End Try

    End Sub

    Public Function GetList(ByVal busUnitId As Integer) As System.Data.DataTable Implements IProduct.GetList
        Try
            Dim data As New DataAccess(SiteProfile.GetConnectionString, DataAccess.DataProvider.SQL)
            Dim iCmd As IDbCommand = data.GetCommand("sp__GetProductsByBU", CommandType.StoredProcedure, DataAccess.DataProvider.SQL)


            ' PROC(sp__GetProductAttributesByBU)
            '	@BusUnitID int = null,
            Dim iParmBusUnitId As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@BusUnitID", DbType.Int32, busUnitID, 4, ParameterDirection.Input)
            '	@LiveMode bit = 0
            ' (parm not needed)
            iCmd.Parameters.Add(iParmBusUnitID)
            Dim dt As DataTable = data.GetDataTable(iCmd)
            If Not dt Is Nothing Then
                Return dt
            Else
                ' just return empty datatable
                dt = New DataTable
                Return dt
            End If


        Catch ex As Exception
            Throw New NLTException("Error retrieving Products.", ex, "Product.vb", "Public Function GetList(ByVal busUnitID As Integer) As DataTable Implements IProduct.GetList")
        End Try


    End Function

    Public Function GetListByJob(ByVal jobId As Integer) As System.Data.DataTable
        Try
            Dim data As New DataAccess(SiteProfile.GetConnectionString, DataAccess.DataProvider.SQL)
            Dim iCmd As IDbCommand = data.GetCommand("sp__GetProductsByJobId", CommandType.StoredProcedure, DataAccess.DataProvider.SQL)
            Dim iParmJobId As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@JobID", DbType.Int32, jobID, 4, ParameterDirection.Input)
            iCmd.Parameters.Add(iParmJobID)
            Dim dt As DataTable = data.GetDataTable(iCmd)
            Return dt

        Catch ex As Exception
            Throw New NLTException("Error retrieving Products by Job.", ex, "Webpage.vb", "Function GetListByJob(ByVal busUnitID As Integer, ByVal mktID As Integer) As System.Data.DataTable")
        End Try
    End Function

    Public Property Documents() As Documents Implements IProduct.Documents
        Get
            Return _mDocuments
        End Get
        Set(ByVal value As Documents)
            _mDocuments = value
        End Set
    End Property

    Public Function GetDocuments() As Documents
        Try
            Dim data As New DataAccess(SiteProfile.GetConnectionString, DataAccess.DataProvider.SQL)
            Dim iCmd As IDbCommand = data.GetCommand("sp__GetDocumentsByProduct", CommandType.StoredProcedure, DataAccess.DataProvider.SQL)
            Dim iParmId As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@ProductID", DbType.Int32, Me.ProductID, 4, ParameterDirection.Input)
            Dim iParmMode As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@LiveMode", DbType.Int32, WorkflowItem.LiveMode.Live, 4, ParameterDirection.Input)
            With iCmd.Parameters
                .Add(iParmID)
                .Add(iParmMode)
            End With

            Dim docs As New Documents
            Dim dt As DataTable = data.GetDataTable(iCmd)
            For Each dataRow As DataRow In dt.Rows
                Dim doc As New Document
                With doc
                    .DocumentId = Services.GetNULLableInteger(dataRow("DocumentId"))
                    .ProductId = Services.GetNULLableInteger(dataRow("ProductId"))
                    Dim region As New Region
                    region.RegionName = Services.GetNULLableString(dataRow("RegionName"))
                    .Region = region
                    .DocTitle = Services.GetNULLableString(dataRow("DocTitle"))
                    .DocPath = Services.GetNULLableString(dataRow("DocPath"))
                    .ContentType = Services.GetNULLableString(dataRow("ContentType"))
                    .UploadDate = Services.GetNULLableString(dataRow("UploadDate"))
                End With
                docs.Add(doc)
            Next
            Return docs
        Catch ex As Exception
            Throw New NLTException("Error retrieving product documents.", ex, "Product.vb", "Function GetDocuments() as Document")
        End Try
    End Function
End Class
