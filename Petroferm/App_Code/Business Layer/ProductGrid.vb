Imports Microsoft.VisualBasic

Public Class ProductGrid
    Inherits WorkflowItem
    Implements IProductGrid
    Private _mProductGridId As Integer
    Private _mProductGridName As String
    Private _mBusUnitId As Integer
    Private _mAttributeColumnList As String
    Private _mProductRowList As String

    Public Property ProductGridId() As Integer Implements IProductGrid.ProductGridId
        Get
            Return _mProductGridId
        End Get
        Set(ByVal value As Integer)
            _mProductGridId = value
        End Set
    End Property

    Public Property ProductGridName() As String Implements IProductGrid.ProductGridName
        Get
            Return _mProductGridName
        End Get
        Set(ByVal value As String)
            _mProductGridName = value
        End Set
    End Property

    Public Property BusUnitId() As Integer Implements IProductGrid.BusUnitId
        Get
            Return _mBusUnitId
        End Get
        Set(ByVal value As Integer)
            _mBusUnitId = value
        End Set
    End Property

    Public Property AttributeColumnList() As String Implements IProductGrid.AttributeColumnList
        Get
            Return _mAttributeColumnList
        End Get
        Set(ByVal value As String)
            _mAttributeColumnList = value
        End Set
    End Property

    Public Property ProductRowList() As String Implements IProductGrid.ProductRowList
        Get
            Return _mProductRowList
        End Get
        Set(ByVal value As String)
            _mProductRowList = value
        End Set
    End Property

    Public Function Delete() As Boolean Implements IProductGrid.Delete

    End Function

    Public Sub Fill(ByVal liveModeStatus As Integer) Implements IProductGrid.Fill
        Try
            Dim data As New DataAccess(SiteProfile.GetConnectionString, DataAccess.DataProvider.SQL)
            Dim strStoredProc As String = ""
            Dim iParmId As IDbDataParameter = Nothing
            Dim iParmLiveMode As IDbDataParameter = Nothing
            Dim iCmd As IDbCommand = Nothing

            If Me.ProductGridID <> 0 Then
                strStoredProc = "sp__GetProductGridByID"
                iParmID = data.GetParameter(DataAccess.DataProvider.SQL, "@ProductGridID", DbType.Int32, Me.ProductGridID, 4, ParameterDirection.Input)
                iParmLiveMode = data.GetParameter(DataAccess.DataProvider.SQL, "@LiveMode", DbType.Int32, liveModeStatus, 4, ParameterDirection.Input)
            End If

            iCmd = data.GetCommand(strStoredProc, CommandType.StoredProcedure, DataAccess.DataProvider.SQL)
            With iCmd
                .Parameters.Add(iParmID)
                .Parameters.Add(iParmLiveMode)
            End With

            Dim dt As DataTable = data.GetDataTable(iCmd)

            If dt.Rows.Count > 0 Then
                Dim row As DataRow = dt.Rows(0)

                ' fill properties
                Me.BusUnitID = Services.GetNULLableInteger(row("BusinessUnitID"))
                Me.ProductGridName = Services.GetNULLableString(row("ProductGridName"))
                ' set workflow properties
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
            Throw New NLTException("Error retrieving Product Grid.", ex, "ProductGrid.vb", "Function Fill() As Boolean")
        End Try



    End Sub

    Public Function GetList(ByVal busUnitId As Integer) As System.Data.DataTable Implements IProductGrid.GetList
        Try
            Dim data As New DataAccess(SiteProfile.GetConnectionString, DataAccess.DataProvider.SQL)
            Dim iCmd As IDbCommand = data.GetCommand("sp__GetProductGridsByBU", CommandType.StoredProcedure, DataAccess.DataProvider.SQL)


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
            Throw New NLTException("Error retrieving Product Grids.", ex, "ProductGrid.vb", "Public Function GetList(ByVal busUnitID As Integer) As DataTable Implements IProduct.GetList")
        End Try


    End Function

    Public Function Save() As Boolean Implements IProductGrid.Save

    End Function

    Public Function GetProductList(ByVal gridId As Integer, ByVal busUnitId As Integer, ByVal selected As Boolean) As DataTable
        Try
            Dim data As New DataAccess(SiteProfile.GetConnectionString, DataAccess.DataProvider.SQL)
            Dim iCmd As IDbCommand = data.GetCommand("sp__GetProductGridProducts", CommandType.StoredProcedure, DataAccess.DataProvider.SQL)

            '	@ProductGridID int = null,
            Dim iParmProductGridId As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@ProductGridID", DbType.Int32, gridID, 4, ParameterDirection.Input)

            '	@BusUnitID int = null,
            Dim iParmBusUnitId As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@BusUnitID", DbType.Int32, busUnitID, 4, ParameterDirection.Input)

            '@Selected bit = 0,-- this is for getting selected/unselected for product
            Dim iParmSelected As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@Selected", DbType.Boolean, selected, 1, ParameterDirection.Input)

            With iCmd.Parameters
                .Add(iParmProductGridID)
                .Add(iParmBusUnitID)
                .Add(iParmSelected)
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
            Throw New NLTException("Error retrieving Products for Product Grid.", ex, "ProductGridModule.vb", "Public Function GetProductList(ByVal modID As Integer, ByVal busUnitID As Integer, ByVal selected As Boolean) As Object Implements IProductGridModule.GetProductList")
        End Try

    End Function

    Function GetAttributeList(ByVal gridId As Integer, ByVal busUnitId As Integer, ByVal selected As Boolean) As DataTable
        Try
            Dim data As New DataAccess(SiteProfile.GetConnectionString, DataAccess.DataProvider.SQL)
            Dim iCmd As IDbCommand = data.GetCommand("sp__GetProductGridAttributes", CommandType.StoredProcedure, DataAccess.DataProvider.SQL)

            '	@ProductGridID int = null,
            Dim iParmProductGridId As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@ProductGridID", DbType.Int32, gridID, 4, ParameterDirection.Input)

            '	@BusUnitID int = null,
            Dim iParmBusUnitId As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@BusUnitID", DbType.Int32, busUnitID, 4, ParameterDirection.Input)

            '@Selected bit = 0,-- this is for getting selected/unselected for product
            Dim iParmSelected As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@Selected", DbType.Boolean, selected, 1, ParameterDirection.Input)

            With iCmd.Parameters
                .Add(iParmProductGridID)
                .Add(iParmBusUnitID)
                .Add(iParmSelected)
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
            Throw New NLTException("Error retrieving Attributes for Product Grid.", ex, "ProductGridModule.vb", "Public Function GetAttributeList(ByVal modID As Integer, ByVal busUnitID As Integer, ByVal selected As Boolean) As Object Implements IProductGridModule.GetProductList")
        End Try
    End Function

End Class
