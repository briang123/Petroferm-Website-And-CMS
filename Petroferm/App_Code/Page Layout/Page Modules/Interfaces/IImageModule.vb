Public Interface IImageModule
    Property ImageModuleId() As Integer
    Property ImageId() As Integer
    Property ImageType() As String
    Property ImageOrder() As Integer
    Property ImageFile() As ImageFile
    Sub Fill()
    Function Save() As Boolean
    Function Delete() As Boolean
End Interface
