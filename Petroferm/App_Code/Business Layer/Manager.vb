Imports Microsoft.VisualBasic

Public Class Manager
    Inherits Person
    Implements IManager

    Private _mExtension As String
    Private _mFax As String
    Private _mBio As String
    Private _mPhoto As String

    Public Sub New()
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

    Public Property Bio() As String Implements IManager.Bio
        Get
            Return _mBio
        End Get
        Set(ByVal value As String)
            _mBio = value
        End Set
    End Property

    Public Property Photo() As String Implements IManager.Photo
        Get
            Return _mPhoto
        End Get
        Set(ByVal value As String)
            _mPhoto = value
        End Set
    End Property
End Class
