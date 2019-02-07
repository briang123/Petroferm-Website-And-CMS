Imports Microsoft.VisualBasic

Public Class QuestionnaireModule
    Inherits PageModule
    Implements IQuestionnaireModule

    Private _mBlurb As String
    Private _mQuestionnaireModuleId As Integer
    Private _mQuestionnaireTitle As String
    Private _mResponseEmail As String

    Public Property Blurb() As String Implements IQuestionnaireModule.Blurb
        Get
            Return _mBlurb
        End Get
        Set(ByVal value As String)
            _mBlurb = value
        End Set
    End Property

    Public Property QuestionnaireModuleId() As Integer Implements IQuestionnaireModule.QuestionnaireModuleId
        Get
            Return _mQuestionnaireModuleId
        End Get
        Set(ByVal value As Integer)
            _mQuestionnaireModuleId = value
        End Set
    End Property

    Public Property QuestionnaireTitle() As String Implements IQuestionnaireModule.QuestionnaireTitle
        Get
            Return _mQuestionnaireTitle
        End Get
        Set(ByVal value As String)
            _mQuestionnaireTitle = value
        End Set
    End Property

    Public Property ResponseEmail() As String Implements IQuestionnaireModule.ResponseEmail
        Get
            Return _mResponseEmail
        End Get
        Set(ByVal value As String)
            _mResponseEmail = value
        End Set
    End Property
End Class
