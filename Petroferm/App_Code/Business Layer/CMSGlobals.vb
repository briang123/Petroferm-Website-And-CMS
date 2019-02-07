Imports Microsoft.VisualBasic

Public Class CmsGlobals
    Public Shared ReadOnly Property ActiveJobId() As Integer
        Get
            Return 3 ' TODO: CMS - CHANGE THIS HARD CODED VALUE
        End Get
    End Property
    Public Shared ReadOnly Property UserId() As Integer
        Get
            Return 1 ' TODO: CMS - CHANGE THIS HARD CODED VALUE
        End Get
    End Property
    Public Shared ReadOnly Property BlankIcon() As String
        Get
            Return "&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;"
        End Get
    End Property
    Public Shared ReadOnly Property GridImageMaxHeight() As Integer
        Get
            Return 50
        End Get
    End Property
    Public Shared ReadOnly Property GridImageMaxWidth() As Integer
        Get
            Return 150
        End Get
    End Property

End Class
