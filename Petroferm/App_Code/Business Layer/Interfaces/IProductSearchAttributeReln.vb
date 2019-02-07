Public Interface IProductSearchAttributeReln
    Property ProdSearchAttribRelnId() As Integer
    Property SearchAttribTypeId() As Integer
    Property ProductId() As Integer

    Sub Fill()
    Function Save() As Boolean
    Function Delete() As Boolean
    Function GetList(ByVal searchAttribTypeId As Integer, ByVal prodId As Integer) As DataTable

End Interface
