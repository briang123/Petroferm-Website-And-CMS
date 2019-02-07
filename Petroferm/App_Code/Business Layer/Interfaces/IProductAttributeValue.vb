Public Interface IProductAttributeValue
    Property ProdAttribRelnId() As Integer
    Property AttribType() As ProductAttribute
    Property ProductId() As Integer
    Property AttribValue() As String

    Sub Fill()
    Function Save() As Boolean
    Function Delete() As Boolean
    Function GetList(ByVal prodId As Integer) As DataTable

End Interface
