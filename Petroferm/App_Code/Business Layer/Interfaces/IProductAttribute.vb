Public Interface IProductAttribute

    Property AttribId() As Integer
    Property AttribName() As String
    Property BusUnitId() As Integer
    Property AllowMultiple() As Boolean
    Property IsReadOnly() As Boolean

    Sub Fill()

    Function Save() As Boolean

    Function Delete() As Boolean

    Function GetList(ByVal busUnitId As Integer) As DataTable


End Interface

