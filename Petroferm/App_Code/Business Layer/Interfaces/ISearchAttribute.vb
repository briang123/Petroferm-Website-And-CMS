Imports Microsoft.VisualBasic

Public Interface ISearchAttribute
    Property SearchAttribTypeId() As Integer
    Property BusUnitId() As Integer
    Property MarketId() As Integer
    Property SearchAttribName() As String

    Sub Fill()

    Function Save() As Boolean

    Function Delete() As Boolean

    Function GetList(ByVal busUnitId As Integer, ByVal mktId As Integer) As DataTable
    Function GetList(ByVal busUnitId As Integer, ByVal mktId As Integer, ByVal liveMode As Boolean) As DataTable


End Interface
