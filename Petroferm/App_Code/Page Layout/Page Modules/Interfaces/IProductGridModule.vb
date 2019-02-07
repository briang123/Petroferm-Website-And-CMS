Public Interface IProductGridModule
    Property ProductGridModuleId() As Integer
    'Property ModuleTypeId() As Integer
    Property ProductGridTitle() As String
    Property ProductGridBlurb() As String
    Property ProductGridId() As Integer
    Property ProductGrid() As ProductGrid
    Property GridModuleOrder() As Integer
    ReadOnly Property RegionId() As Integer
    Property DocAuth() As Boolean
    Property LiveModeStatus() As WorkflowItem.LiveMode
    Sub Fill()
    Function Save() As Boolean
    Function Delete() As Boolean
    Function GetProductGrid() As String

End Interface
