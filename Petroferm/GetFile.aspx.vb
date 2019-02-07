Imports System.Data
Imports Data

Partial Class GetFile
    Inherits System.Web.UI.Page

    Protected Sub Page_Load(ByVal sender As Object, ByVal e As System.EventArgs) Handles Me.Load

        'TODO: We need to check if the file requires authentication before viewing. We can do this by 
        'checking which business unit this document belongs to and then determining if the current user 
        'is authenticated. If not then we will not allow the download to happen. If user is not
        'authenticated and they should be maybe we can Throw New ApplicationException("User not authenticated.")

        Dim fileId As Integer
        Dim dataDocs As New DataAccess(SiteProfile.GetConnectionString, DataAccess.DataProvider.SQL)
        Dim iCmdDocs As IDbCommand = dataDocs.GetCommand("sp__GetDocumentByID", CommandType.StoredProcedure, DataAccess.DataProvider.SQL)

        Try

            If Request.QueryString("file") IsNot Nothing Then
                fileID = Request.QueryString("file")
            Else
                fileID = 0
            End If

            If fileID > 0 Then

                Dim ref As String = 1
                If Request.QueryString("ref") IsNot Nothing Then
                    If Request.QueryString("ref").ToString.ToUpper = "CMS" Then
                        ref = 0
                    End If
                End If
                Dim iparmDocsIdIn As IDbDataParameter = dataDocs.GetParameter(DataAccess.DataProvider.SQL, "@DocID", DbType.Int32, fileID, 4, ParameterDirection.Input)
                Dim iparmUserIdIn As IDbDataParameter = dataDocs.GetParameter(DataAccess.DataProvider.SQL, "@UserID", DbType.Int32, 1, 4, ParameterDirection.Input)
                Dim iparmUrlIn As IDbDataParameter = dataDocs.GetParameter(DataAccess.DataProvider.SQL, "@URL", DbType.String, Request.ServerVariables("HTTP_REFERER"), 500, ParameterDirection.Input)
                Dim iparmLiveMode As IDbDataParameter = dataDocs.GetParameter(DataAccess.DataProvider.SQL, "@LiveMode", DbType.Int32, ref, 4, ParameterDirection.Input)
                With iCmdDocs
                    With .Parameters
                        .Add(iparmDocsIdIn)
                        .Add(iparmUserIDIn)
                        .Add(iparmURLIn)
                        .Add(iparmLiveMode)
                    End With
                End With
                Dim dtDocuments As DataTable = dataDocs.GetDataTable(iCmdDocs)
                If dtDocuments.Rows.Count > 0 Then
                    Dim docPath As String = dtDocuments.Rows(0)("DocPath")
                    If docPath.StartsWith("/") Then
                        Response.Redirect("~" + docPath)
                    Else
                        Response.Redirect("~/" + docPath)
                    End If
                Else
                    lblMessage.Text = "A file cannot be found using the the URL you specified."
                End If
            Else
                Throw New NullReferenceException("A File ID is missing")
            End If
        Catch nex As NullReferenceException
            lblMessage.Text = "No file specified."
        Catch ex As Exception
            Throw ex
        Finally
            If iCmdDocs.Connection.State <> ConnectionState.Closed Then
                iCmdDocs.Connection.Close()
            End If
        End Try

    End Sub
End Class
