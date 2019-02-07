Public Interface IProductBlurbModule
    Property ProductId() As Integer
    Property ProductName() As String
    Property ProductBlurbModuleId() As Integer
    Property LiveModeStatus() As WorkflowItem.LiveMode
    Property SourceId() As Integer
    Property ProductSelection() As String ' will be Individual or Multiple
    Property Title() As String
    Property ProductBlurb() As String ' will be used when it's a Multiple product blurb
    Property ProductIdList() As String ' comma-delimited list of products for a multi-product blurb
    Sub Fill(ByVal liveMode As Boolean)
    Function GetProductList(ByVal modId As Integer, ByVal busUnitId As Integer, ByVal selected As Boolean) As DataTable
    Function Save() As Boolean
    Function Delete() As Boolean
    Property Products() As Products
End Interface
