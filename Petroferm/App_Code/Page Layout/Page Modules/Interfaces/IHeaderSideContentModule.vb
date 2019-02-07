Public Interface IHeaderSideContentModule
    Property HeaderSideContentModuleId() As Integer
    Property Title() As String
    Property LineText1() As String
    Property InternalLink1() As Integer
    Property ExternalLink1() As String
    Property InternalLink1Type() As String
    Property LineText2() As String
    Property InternalLink2() As Integer
    Property InternalLink2Type() As String
    Property ExternalLink2() As String
    Sub Fill()
    Function Save() As Boolean
    Function Delete() As Boolean
End Interface
