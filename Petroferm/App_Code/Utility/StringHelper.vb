Imports Microsoft.VisualBasic

Public Class StringHelper

    Public Shared Function GetClassNameUsingInstr(ByVal str As String) As String
        If StripFileName(GetAppVar("PATH_INFO")) & "?" & GetAppVar("QUERY_STRING").IndexOf(str.ToLower) > 0 Then
            Return "navsub-selected"
        Else
            Return "navsub-inact"
        End If
    End Function

    Public Shared Function GetClassName(ByVal str As String) As String
        If str.ToLower = StripFileName(GetAppVar("PATH_INFO")) & "?" & GetAppVar("QUERY_STRING") Then
            Return "navsub-selected"
        Else
            Return "navsub-inact"
        End If
    End Function

    Public Shared Function GetAppVar(ByVal key As String) As String
        Return HttpContext.Current.Request.ServerVariables(key).Trim.ToLower
    End Function

    Public Shared Function StripFileName(ByVal path As String) As String
        Dim nPos As Integer
        nPos = path.LastIndexOf("/")
        Return path.Substring(1, path.Length - nPos)
    End Function

End Class
