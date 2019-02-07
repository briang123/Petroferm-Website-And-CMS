Public Interface IProductCategory
    Property CategoryId() As Integer
    Property CategoryName() As String
    Property CategoryDescription() As String ' this isn't in the db table
    Property BusinessUnitId() As Integer
    Property MarketId() As Integer
    Property CategoryOrder() As Integer
    Property Products() As Hashtable
    Sub Fill()
    Function Save() As Boolean
    Function Delete() As Boolean
    Function GetList(ByVal busUnitId As Integer) As DataTable

End Interface
