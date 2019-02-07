Public Class Documents
    Inherits ModuleCollection

    Sub New()
        MyBase.New()
    End Sub

    Public Function Add(ByVal item As Object) As Integer
        Try
            Return MyBase.List.Add(Item)
        Catch ex As Exception
            Throw ex
        End Try
    End Function

End Class