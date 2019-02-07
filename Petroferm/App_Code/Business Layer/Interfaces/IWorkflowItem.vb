Public Interface IWorkflowItem
    Property PublishDate() As Date
    Property ExpireDate() As Date
    Property WorkflowStatus() As String
    Property LastModDate() As Date
    Property LastModBy() As Integer
    Property ActiveFlag() As Boolean
    Property MarkedForDelete() As Boolean
    Property JobId() As Integer
    Property JobName() As String
    Property LastModByName() As String
    Property JobDescription() As String
End Interface
