
Partial Class CmsControlsWorkflowInfo
    Inherits System.Web.UI.UserControl
    Public Sub SetValues(ByVal wkItem As WorkflowItem)
        With wkItem
            lblPublishDate.Text = .PublishDate.ToShortDateString
            lblExpireDate.Text = .ExpireDate.ToShortDateString
            lblWorkflowStatus.Text = .WorkflowStatus.ToString
            lblLastModByName.Text = .LastModByName
            lblLastModDate.Text = .LastModDate.ToString("g")
            lblMarkedForDelete.Text = .MarkedForDeleteFmt
            If .MarkedForDeleteFmt = "Yes" Then
                lblMarkedForDelete.ForeColor = Drawing.Color.Red
                lblMarkedForDelete.Font.Bold = True
            End If
            lblJobName.Text = .JobName
            lblJobDesc.Text = .JobDescription
        End With
    End Sub

End Class
