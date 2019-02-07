Imports Microsoft.VisualBasic

Public Class Person
    Implements IPerson

    Private _mEmail As String
    Private _mFirstName As String
    Private _mLastName As String
    Private _mPhone As String
    Private _mFullName As String


    Public Sub New()
    End Sub

    Public Property Email() As String Implements IPerson.Email
        Get
            Return _mEmail
        End Get
        Set(ByVal value As String)
            _mEmail = value
        End Set
    End Property

    Public Property FirstName() As String Implements IPerson.FirstName
        Get
            Return _mFirstName
        End Get
        Set(ByVal value As String)
            _mFirstName = value
        End Set
    End Property

    Public Property LastName() As String Implements IPerson.LastName
        Get
            Return _mLastName
        End Get
        Set(ByVal value As String)
            _mLastName = value
        End Set
    End Property

    Public Property Phone() As String Implements IPerson.Phone
        Get
            Return _mPhone
        End Get
        Set(ByVal value As String)
            _mPhone = value
        End Set
    End Property

    Public Property FullName() As String Implements IPerson.FullName
        Get
            Return _mFullName
        End Get
        Set(ByVal value As String)
            _mFullName = value
        End Set
    End Property
End Class
