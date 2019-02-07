Public Interface IPageModule
    Property PageModuleRelnId() As Integer
    Property PageId() As Integer
    Property ModuleId() As Integer
    Property ModuleType() As String
    Property ModuleOrder() As Integer
    Property ShowTitle() As Boolean
    Function GetList(ByVal pageId As Integer, ByVal liveMode As Boolean) As DataTable
End Interface
