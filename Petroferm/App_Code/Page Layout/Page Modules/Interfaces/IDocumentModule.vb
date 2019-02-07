Public Interface IDocumentModule
    Property DocumentRelnId() As Integer
    Property DocumentId() As Integer
    Property LinkText() As String
    Property SectionId() As Integer
    Property DocumentFile() As Document
    Property LiveModeStatus() As WorkflowItem.LiveMode
    Sub Fill()
    Function Save() As Boolean
    Function Delete() As Boolean
End Interface
