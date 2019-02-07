Public Interface ISideNavigation
    Property Id() As Integer
    Property ProdCatId() As Integer
    Property Title() As String
    Property Description() As String
    Property Url() As String
    Property BusinessUnitId() As Integer
    Property MarketId() As Integer
    Property PageId() As Integer
    Property ItemOrder() As Integer
    Property Parent() As Integer
    Property SectionId() As Integer
    Property LiveModeStatus() As WorkflowItem.LiveMode

    Sub Fill()
    Function Save() As Boolean
    Function Delete() As Boolean
    Function GetList() As DataTable

End Interface
