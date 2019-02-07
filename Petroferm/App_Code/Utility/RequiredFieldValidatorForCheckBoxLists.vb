Imports Microsoft.VisualBasic
Imports System.Web.UI
Imports System.Web.UI.WebControls
Imports System.ComponentModel

Public Class RequiredFieldValidatorForCheckBoxLists
    Inherits System.Web.UI.WebControls.BaseValidator

    Private _mListControl As ListControl

    Sub New()
        MyBase.EnableClientScript = False
    End Sub

    Protected Overrides Function ControlPropertiesValid() As Boolean
        Dim ctrl As Control = FindControl(ControlToValidate)
        If ctrl IsNot Nothing Then
            _mListControl = TryCast(ctrl, ListControl)
            Return (_mListControl IsNot Nothing)
        Else
            Return False
        End If
    End Function

    Protected Overrides Function EvaluateIsValid() As Boolean
        Return _mListControl.SelectedIndex <> -1
    End Function
End Class
