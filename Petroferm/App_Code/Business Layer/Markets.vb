Imports Microsoft.VisualBasic

Public Class Markets
    Inherits CollectionBase

    Sub New()
        MyBase.New()
    End Sub

    Default Public Property Item(ByVal index As Integer) As Market
        Get
            Return CType(MyBase.List.Item(Index), Market)
        End Get
        Set(ByVal value As Market)
            MyBase.List.Item(Index) = Value
        End Set
    End Property

    Public Function GetMarketById(ByVal marketId As Integer) As Market
        Dim marketObject As Market = Nothing
        Try
            If MyBase.List.Count > 0 Then
                Dim i As Integer
                For i = 0 To MyBase.List.Count - 1
                    If Me.Item(i).MarketID = MarketID Then
                        marketObject = CType(MyBase.List.Item(i), Market)
                    End If
                Next
            End If
        Catch ex As Exception
            Throw ex
        End Try

        Return marketObject
    End Function

    Public Function Add(ByVal item As Market) As Integer
        Try
            If MyBase.List.Count > 0 Then
                Return MyBase.List.Add(Item)
            End If
        Catch ex As Exception
            Throw ex
        End Try
    End Function


End Class
