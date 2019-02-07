Public Interface IProductGrid
    Property ProductGridId() As Integer
    Property ProductGridName() As String
    Property BusUnitId() As Integer
    Property ProductRowList() As String ' comma delimited list of product rows
    Property AttributeColumnList() As String ' comma delimited list of attribute columns

    Sub Fill(ByVal mode As Integer)

    Function Save() As Boolean

    Function Delete() As Boolean

    Function GetList(ByVal busUnitId As Integer) As DataTable


End Interface
