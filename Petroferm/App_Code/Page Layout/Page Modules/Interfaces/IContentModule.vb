Public Interface IContentModule
    Property ContentId() As Integer
    Property ContentTitle() As String
    Property Content() As String
    Property LiveModeStatus() As Boolean
    Sub Fill()
    Function Save() As Boolean
    Function Delete() As Boolean
End Interface
