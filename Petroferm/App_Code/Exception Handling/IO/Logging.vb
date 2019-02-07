Public Class Logging

    Public Enum TraceLevel
        Normal
        Warning
    End Enum

    Public Shared Sub TraceWrite(ByVal traceLevel As TraceLevel, _
                            ByVal category As String, _
                            ByVal message As String, _
                            Optional ByVal ex As Exception = Nothing)

        Try
            Dim ctxt As HttpContext = HttpContext.Current
            If ctxt.Trace.IsEnabled Then
                Select Case traceLevel
                    Case traceLevel.Normal
                        ctxt.Trace.Write(category, message, ex)
                    Case traceLevel.Warning
                        ctxt.Trace.Warn(category, message, ex)
                End Select
            End If
        Catch ae As ApplicationException
            Throw ae
        End Try
    End Sub

End Class
