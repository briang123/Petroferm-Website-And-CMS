Imports Microsoft.VisualBasic

Public Class Employee
    Inherits Person
    Implements IEmployee

    Private _mExtension As String
    Private _mFax As String

    Sub New()
        MyBase.New()
    End Sub

    Public Property Extension() As String Implements IEmployee.Extension
        Get
            Return _mExtension
        End Get
        Set(ByVal value As String)
            _mExtension = value
        End Set
    End Property

    Public Property Fax() As String Implements IEmployee.Fax
        Get
            Return _mFax
        End Get
        Set(ByVal value As String)
            _mFax = value
        End Set
    End Property

End Class
