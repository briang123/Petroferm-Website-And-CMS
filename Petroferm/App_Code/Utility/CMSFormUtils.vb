Imports Microsoft.VisualBasic

Public Class CmsFormUtils

    Public Enum FormMode As Integer
        Read = 0
        Edit = 1
    End Enum


    ''' <summary>
    ''' This method sets the text of the finish button and (for edit mode) adds
    ''' an onclick attribute to confirm that the user wants to save 
    ''' </summary>
    ''' <param name="mode">Read or Edit</param>
    ''' <remarks></remarks>
    Public Shared Sub SetFinishButtonProperties(ByRef btnFinish As Button, ByVal mode As CMSFormUtils.FormMode, Optional ByVal addConfirm As Boolean = True)
        If Not btnFinish Is Nothing Then
            Select Case mode
                Case CMSFormUtils.FormMode.Edit
                    btnFinish.Text = "Save and Close"
                    If addConfirm Then
                        btnFinish.Attributes.Add("onclick", _
                            "return confirm('Are you sure you want to save this information?\n\n" & _
                            "The information will now be part of the active job and its workflow status will be set to WORKING.');")
                    End If
                Case CMSFormUtils.FormMode.Read
                    btnFinish.Text = "Close"
            End Select
        End If

    End Sub
End Class
