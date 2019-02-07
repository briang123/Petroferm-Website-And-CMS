Imports Microsoft.VisualBasic
Imports System
Imports System.Collections

Public Class PageModuleComparer
    Implements IComparer

    Public Enum SortDirection
        Ascending
        Descending
    End Enum

    Private _mDirection As SortDirection = SortDirection.Ascending

    Public Sub New()
        MyBase.New()
    End Sub

    Public Sub New(ByVal direction As SortDirection)
        Me._mDirection = direction
    End Sub

    Private Function Compare(ByVal x As Object, ByVal y As Object) As Integer Implements IComparer.Compare

        Dim moduleX As IPageModule = DirectCast(x, IPageModule)
        Dim moduleY As IPageModule = DirectCast(y, IPageModule)

        If ModuleX Is Nothing AndAlso ModuleY Is Nothing Then
            Return 0
        ElseIf ModuleX Is Nothing AndAlso ModuleY IsNot Nothing Then
            If Me._mDirection = SortDirection.Ascending Then
                Return -1
            Else
                Return 1
            End If
        ElseIf ModuleX IsNot Nothing AndAlso ModuleY Is Nothing Then
            If Me._mDirection = SortDirection.Ascending Then
                Return 1
            Else
                Return -1
            End If
        Else
            If Me._mDirection = SortDirection.Ascending Then
                Return ModuleX.ModuleOrder.CompareTo(ModuleY.ModuleOrder)
            Else
                Return ModuleY.ModuleOrder.CompareTo(ModuleX.ModuleOrder)
            End If
        End If
    End Function
End Class

