Public Interface IDeploymentJob
    Property DeploymentJobId() As Integer
    Property JobName() As String
    Property JobDescription() As String
    Property ReviewBy() As Integer
    Property ReviewByName() As String
    Property ApprovedBy() As Integer
    Property ApprovedByName() As String
    Property DeploymentDate() As Date
    Property DeployedBy() As Integer
    Property DeployedByName() As String
    Property WorkflowStatus() As String
    Property LastModDate() As Date
    Property LastModBy() As Integer
    Property LastModByName() As String
    Property ActiveFlag() As Boolean

    Sub Fill()
    Function Save() As Boolean
    Function Delete() As Boolean
    Function GetList() As DataTable

End Interface
