Imports Microsoft.VisualBasic

Public Class Region
    Inherits WorkflowItem
    Implements IRegion

    Private _mRegionId As Integer
    Private _mRegionName As String

    Public Property RegionId() As Integer Implements IRegion.RegionId
        Get
            Return _mRegionId
        End Get
        Set(ByVal value As Integer)
            _mRegionId = value
        End Set
    End Property

    Public Property RegionName() As String Implements IRegion.RegionName
        Get
            Return _mRegionName
        End Get
        Set(ByVal value As String)
            _mRegionName = value
        End Set
    End Property


    Function GetList(ByVal mode As LiveMode) As DataTable
        Try
            Dim data As New DataAccess(SiteProfile.GetConnectionString, DataAccess.DataProvider.SQL)
            Dim iCmd As IDbCommand = data.GetCommand("sp__GetRegions", CommandType.StoredProcedure, DataAccess.DataProvider.SQL)
            Dim iParmLiveMode As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@LiveMode", DbType.Int32, Convert.ToInt32(mode), 4, ParameterDirection.Input)
            iCmd.Parameters.Add(iParmLiveMode)
            Dim dt As DataTable = data.GetDataTable(iCmd)
            Return dt

        Catch ex As Exception
            Throw New NLTException("Error retrieving Regions.", ex, "Region.vb", "Function GetList() As DataTable")
        End Try

    End Function
End Class