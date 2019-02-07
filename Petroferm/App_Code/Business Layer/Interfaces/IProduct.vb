Public Interface IProduct
    Property Documents() As Documents
    Property ProductId() As Integer
    Property ProductName() As String
    Property BusUnitId() As Integer
    Property ProductKeywords() As String
    Property ProductBlurb() As String
    Property ProductApprovals() As String

    Sub Fill()
    Function Save() As Boolean
    Function Delete() As Boolean
    Function GetList(ByVal busUnitId As Integer) As DataTable

End Interface
