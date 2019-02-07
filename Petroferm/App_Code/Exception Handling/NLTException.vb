Public Class NltException : Inherits System.Exception

#Region " ENUMERATIONS "
    Public Enum CcmTaskType
        DbSave
        DbDelete
        DbSelect
        ObjCreate
        MiscError
        PageEvent
    End Enum

#End Region

#Region " PRIVATE MEMBERS "
    Private _sourceFileName As String = ""
    Private _sourceMethodName As String = ""
    Private _userId As String = ""
#End Region

#Region " PROPERTIES "
    Property SourceFileName() As String
        Get
            Return _sourceFileName
        End Get
        Set(ByVal value As String)
            _sourceFileName = Value
        End Set
    End Property
    Property SourceMethodName() As String
        Get
            Return _sourceMethodName
        End Get
        Set(ByVal value As String)
            _sourceMethodName = Value
        End Set
    End Property
    Property UserId() As String
        Get
            Return _userID
        End Get
        Set(ByVal value As String)
            _userID = Value.ToUpper
        End Set
    End Property
#End Region

#Region " CONSTRUCTORS "
    Private Sub New()
        MyBase.New()
    End Sub

    'Public Sub New(ByVal message As String)
    '    MyBase.New(message)
    'End Sub
    Public Sub New(ByVal message As String, ByVal inner As Exception, _
               ByVal sourceFileName As String, _
               ByVal sourceMethodName As String)
        MyBase.New(message, inner)
        _sourceFileName = sourceFileName
        _sourceMethodName = sourceMethodName
    End Sub
#End Region

#Region " METHODS "

#End Region



End Class
