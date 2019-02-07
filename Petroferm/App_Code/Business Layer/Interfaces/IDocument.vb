Public Interface IDocument
    Property DocumentId() As Integer
    Property ProductId() As Integer
    Property DocTitle() As String
    Property DocPath() As String
    ReadOnly Property DocFilename() As String ' determined by using DocPath property
    Property ContentType() As String
    ReadOnly Property DocumentType() As String
    Property RegionId() As Integer
    Property Region() As Region
    Property UploadDate() As DateTime
    Sub Fill(ByVal mode As Integer)
    Function Update() As Boolean
    Function Delete() As Boolean
    Function Save() As Boolean
End Interface