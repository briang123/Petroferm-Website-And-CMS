Imports Microsoft.VisualBasic

Public Class ProductGridModule
    Inherits PageModule
    Implements IProductGridModule

    Private _mProductGridModuleId As Integer
    Private _mProductGrid As New ProductGrid
    Private _mProductGridTitle As String
    Private _mProductGridBlurb As String
    Private _mProductGridId As Integer
    Private _mGridModuleOrder As Integer
    Private _mLiveModeStatus As Integer
    Private _mDocAuth As Boolean
    Private _mRegion As String

    Public Sub New()
    End Sub

    Public Sub New(ByVal productGridModuleId As Integer, ByVal liveMode As WorkflowItem.LiveMode)
        Me.ProductGridModuleId = ProductGridModuleId
        Me.LiveModeStatus = LiveMode
        Me.Fill()
    End Sub

    Public Sub New(ByVal productGridModuleId As Integer, ByVal productGridId As Integer, ByVal liveMode As WorkflowItem.LiveMode)
        Me.ProductGridModuleId = ProductGridModuleId
        Me.ProductGridId = ProductGridId
        Me.LiveModeStatus = LiveMode
        Me.Fill()
    End Sub

    Public Property DocAuth() As Boolean Implements IProductGridModule.DocAuth
        Get
            Return _mDocAuth
        End Get
        Set(ByVal value As Boolean)
            _mDocAuth = Value
        End Set
    End Property

    Public Property ProductGrid() As ProductGrid Implements IProductGridModule.ProductGrid
        Get
            Return _mProductGrid
        End Get
        Set(ByVal value As ProductGrid)
            _mProductGrid = value
        End Set
    End Property

    Public Property ProductGridBlurb() As String Implements IProductGridModule.ProductGridBlurb
        Get
            Return _mProductGridBlurb
        End Get
        Set(ByVal value As String)
            _mProductGridBlurb = value
        End Set
    End Property

    Public Property ProductGridId() As Integer Implements IProductGridModule.ProductGridId
        Get
            Return _mProductGridId
        End Get
        Set(ByVal value As Integer)
            _mProductGridId = value
        End Set
    End Property

    Public Property ProductGridModuleId() As Integer Implements IProductGridModule.ProductGridModuleId
        Get
            Return _mProductGridModuleId
        End Get
        Set(ByVal value As Integer)
            _mProductGridModuleId = value
        End Set
    End Property

    Public Property ProductGridTitle() As String Implements IProductGridModule.ProductGridTitle
        Get
            Return _mProductGridTitle
        End Get
        Set(ByVal value As String)
            _mProductGridTitle = value
        End Set
    End Property

    Public Property GridModuleOrder() As Integer Implements IProductGridModule.GridModuleOrder
        Get
            Return _mGridModuleOrder
        End Get
        Set(ByVal value As Integer)
            _mGridModuleOrder = value
        End Set
    End Property

    Public Property LiveModeStatus() As WorkflowItem.LiveMode Implements IProductGridModule.LiveModeStatus
        Get
            Return _mLiveModeStatus
        End Get
        Set(ByVal value As WorkflowItem.LiveMode)
            _mLiveModeStatus = value
        End Set
    End Property

    Public ReadOnly Property RegionId() As Integer Implements IProductGridModule.RegionId
        Get
            ' this is the region id
            If HttpContext.Current.Session.Item("USER_REGION_PREFERENCE") IsNot Nothing Then
                Return Services.GetNULLableInteger(HttpContext.Current.Session.Item("USER_REGION_PREFERENCE"))
            Else
                Return 1
            End If
        End Get
    End Property

    Public Function GetProductGrid() As String Implements IProductGridModule.GetProductGrid

        Dim gridId As Integer = Me.ProductGridId

        If GridID > 0 Then
            'Get Product Grid Documents (MSDS, TDS, BULLETIN, etc.)
            Dim dataDocs As New DataAccess(SiteProfile.GetConnectionString, DataAccess.DataProvider.SQL)
            Dim iCmdDocs As IDbCommand = dataDocs.GetCommand("sp__GetProductDocumentsByGridID", CommandType.StoredProcedure, DataAccess.DataProvider.SQL)
            Dim iparmGridDocsId As IDbDataParameter = dataDocs.GetParameter(DataAccess.DataProvider.SQL, "@GridID", DbType.Int32, GridID, 4, ParameterDirection.Input)
            Dim iParmDocsLiveMode As IDbDataParameter = dataDocs.GetParameter(DataAccess.DataProvider.SQL, "@LiveMode", DbType.Boolean, Me.LiveModeStatus, 1, ParameterDirection.Input)
            With iCmdDocs
                .Parameters.Add(iparmGridDocsId)
                .Parameters.Add(iParmDocsLiveMode)
            End With
            Dim dtProductGridDocuments As DataTable = dataDocs.GetDataTable(iCmdDocs)


            'Get Product Grid Approvals - 12/28/06 - kr
            Dim dataApprovals As New DataAccess(SiteProfile.GetConnectionString, DataAccess.DataProvider.SQL)
            Dim iCmdApprovals As IDbCommand = dataApprovals.GetCommand("sp__GetProductApprovalsByGridID", CommandType.StoredProcedure, DataAccess.DataProvider.SQL)
            Dim iparmGridApprovalsId As IDbDataParameter = dataDocs.GetParameter(DataAccess.DataProvider.SQL, "@GridID", DbType.Int32, GridID, 4, ParameterDirection.Input)
            Dim iParmApprovalsLiveMode As IDbDataParameter = dataDocs.GetParameter(DataAccess.DataProvider.SQL, "@LiveMode", DbType.Boolean, Me.LiveModeStatus, 1, ParameterDirection.Input)
            With iCmdApprovals
                .Parameters.Add(iparmGridApprovalsId)
                .Parameters.Add(iParmApprovalsLiveMode)
            End With
            Dim dtProductGridApprovals As DataTable = dataApprovals.GetDataTable(iCmdApprovals)

            'Get Product Grid Columns
            Dim dataColumn As New DataAccess(SiteProfile.GetConnectionString, DataAccess.DataProvider.SQL)
            Dim iCmdColumn As IDbCommand = dataColumn.GetCommand("sp__GetProductGridColumns", CommandType.StoredProcedure, DataAccess.DataProvider.SQL)
            Dim iparmGridColsId As IDbDataParameter = dataColumn.GetParameter(DataAccess.DataProvider.SQL, "@GridID", DbType.Int32, GridID, 4, ParameterDirection.Input)
            Dim iParmColsLiveMode As IDbDataParameter = dataColumn.GetParameter(DataAccess.DataProvider.SQL, "@LiveMode", DbType.Boolean, Me.LiveModeStatus, 1, ParameterDirection.Input)
            With iCmdColumn
                .Parameters.Add(iparmGridColsId)
                .Parameters.Add(iParmColsLiveMode)
            End With
            Dim dtProductGridColumns As DataTable = dataColumn.GetDataTable(iCmdColumn)

            'Get Product Grid Row Attributes
            Dim dataRows As New DataAccess(SiteProfile.GetConnectionString, DataAccess.DataProvider.SQL)
            Dim iCmdRows As IDbCommand = dataRows.GetCommand("sp__GetProductGridRows", CommandType.StoredProcedure, DataAccess.DataProvider.SQL)
            Dim iparmGridRowsId As IDbDataParameter = dataRows.GetParameter(DataAccess.DataProvider.SQL, "@GridID", DbType.Int32, GridID, 4, ParameterDirection.Input)
            Dim iParmRowsLiveMode As IDbDataParameter = dataRows.GetParameter(DataAccess.DataProvider.SQL, "@LiveMode", DbType.Boolean, Me.LiveModeStatus, 1, ParameterDirection.Input)
            With iCmdRows
                .Parameters.Add(iparmGridRowsId)
                .Parameters.Add(iParmRowsLiveMode)
            End With
            Dim dtProductGridRows As DataTable = dataRows.GetDataTable(iCmdRows)

            'Manipulate data table to get distinct set of Product IDs for current grid
            Dim dtDistinctProductIDs As DataTable = Data.Services.RemoveDuplicateRows(dtProductGridRows, "ProductID", "")
            Dim sb As New System.Text.StringBuilder
            Dim altRow As String = "<tr>"
            Dim displayApprovals As Boolean ' added 12/28/2006 - kr

            With sb
                .Append("<table width=""100%"" border=""0"" cellspacing=""0"" cellpadding=""0"">")

                'Build our header and spacer rows
                .Append("<tr>")
                Dim maxColumns As Integer = 7
                Dim currentColumn As Integer = 1
                For Each row As DataRow In dtProductGridColumns.Rows
                    If currentColumn <= maxColumns Then ' only display a maximum of 7 columns (visual constraints so we don't surpass the pre-defined width)
                        ' 12/28/2006 - kr - don't have Approvals as a column -- this attrib displays below the product
                        If row("AttribName").ToString.ToUpper <> "APPROVALS" Then
                            altRow += "<td class=""tblRow2""></td>"
                            .AppendFormat("<td class=""tblHdr"">{0}</td>", row("AttribName").ToString)
                            currentColumn += 1
                        Else
                            displayApprovals = True
                        End If
                    End If
                Next
                .Append("</tr>")
                altRow += "</tr>"
                .Append(altRow)

                'Loop through each Product ID, then loop through each Product Attribute (column header)
                'If the product attribute does not exist, then skip to the next one

                For Each productId As DataRow In dtDistinctProductIDs.Rows
                    .Append("<tr valign=""top"">")
                    currentColumn = 1

                    For Each columnAttribute As DataRow In dtProductGridColumns.Rows
                        If currentColumn <= maxColumns Then

                            'Get the product attribute value by querying against product id and attribute type (column header)
                            Dim productRows() As DataRow = dtProductGridRows.Select( _
                                "ProductID = " + CType(productID("ProductID"), Integer).ToString + _
                                " AND AttribTypeID = " + CType(columnAttribute("AttribTypeID"), Integer).ToString)

                            If productRows.Length > 0 Or _
                                columnAttribute("AttribName").ToString.ToUpper = "DATASHEETS" Then

                                If columnAttribute("AttribName").ToString.ToUpper = "DATASHEETS" Then
                                    .Append("<td class=""tblRow1"">")
                                    'get a new datatable of distinct values based on the following columns(will also be a new table with these only new columns)
                                    Dim dt As DataTable = dtProductGridDocuments.DefaultView.ToTable(True, New String() {"DocumentID", "DocPath", "ProductID", "ContentType", "ProductName", "RegionID", "RegionName"})

                                    If Me.LiveModeStatus = LiveMode.Live Then
                                        If Me.DocAuth = True Then
                                            If Roles.IsUserInRole(HttpContext.Current.User.Identity.Name, "WebsiteUser") = True Then
                                                'for the live site, we want to filter on the region
                                                Dim docRows() As DataRow = dt.Select("ProductID = " + productID("ProductID").ToString + " AND RegionID = " + Me.RegionID.ToString)

                                                If docRows.Length > 0 Then
                                                    For Each docRow As DataRow In docRows
                                                        'we are tracking the document downloads by passing the information through a document download tracker
                                                        .Append("<a href=""GetFile.aspx?file=" + docRow("DocumentID").ToString + """ title=""" + docRow("ContentType").ToString.ToUpper + " for " + docRow("ProductName").ToString + """>" + docRow("ContentType").ToString.ToUpper + "</a>&nbsp;")
                                                    Next
                                                Else
                                                    .Append("&nbsp;") 'document does not exist for product
                                                End If
                                            Else
                                                .Append("&nbsp;") 'authenticated, but not in WebsiteUser group
                                            End If
                                        Else
                                            'for the live site, we want to filter on the region
                                            Dim docRows() As DataRow = dt.Select("ProductID = " + productID("ProductID").ToString + " AND RegionID = " + Me.RegionID.ToString)

                                            If docRows.Length > 0 Then
                                                For Each docRow As DataRow In docRows
                                                    'we are tracking the document downloads by passing the information through a document download tracker
                                                    .Append("<a href=""GetFile.aspx?file=" + docRow("DocumentID").ToString + """ title=""" + docRow("ContentType").ToString.ToUpper + " for " + docRow("ProductName").ToString + """>" + docRow("ContentType").ToString.ToUpper + "</a>&nbsp;")
                                                Next
                                            Else
                                                .Append("&nbsp;") 'document does not exist for product
                                            End If
                                        End If
                                    Else
                                        'for the CMS view, we render documents from all regions so the user know what docs are available
                                        Dim docRows() As DataRow = dt.Select("ProductID = " + productID("ProductID").ToString)
                                        If docRows.Length > 0 Then
                                            For Each docRow As DataRow In docRows
                                                'in contrast to the live website, we do not track each time the file is viewed from the CMS
                                                .Append("<a href=""../GetFile.aspx?ref=CMS&file=" + docRow("DocumentID").ToString + """ title=""" + docRow("ContentType").ToString.ToUpper + " for " + docRow("ProductName").ToString + """>" + docRow("ContentType").ToString.ToUpper + "</a> (" + docRow("RegionName").ToString + ")<br/>")
                                            Next
                                        Else
                                            .Append("(none defined)")
                                        End If
                                    End If
                                    .Append("</td>")
                                    ' added elseif stmt - 12/28/2006 - kr
                                ElseIf columnAttribute("AttribName").ToString.ToUpper <> "APPROVALS" Then
                                    .Append("<td class=""tblRow1"">")

                                    If columnAttribute("AttribName").ToString.ToUpper = "PRODUCT" And displayApprovals Then
                                        ' get the product name to use for approvals
                                        .Append("<a href=""Javascript:toggleDIV('ProductApproval" & CType(productID("ProductID"), Integer).ToString & "');"">")

                                        For Each attribRow As DataRow In productRows
                                            .Append(attribRow("AttribValue").ToString + "<br/>")
                                        Next
                                        .Append("</a>")
                                    Else
                                        'iterate through each column value
                                        For Each attribRow As DataRow In productRows
                                            .Append(attribRow("AttribValue").ToString + "<br/>")
                                        Next
                                    End If
                                    .Append("</td>")

                                End If

                            Else
                                ' added if stmt 12/28/2006 - don't need empty column for approvals attrib
                                If columnAttribute("AttribName").ToString.ToUpper <> "APPROVALS" Then
                                    .Append("<td class=""tblRow1"">&nbsp;</td>")
                                End If
                            End If
                            currentColumn += 1
                        End If
                    Next
                    .Append("</tr>")
                    If Not displayApprovals Then
                        .Append(altRow)
                    End If


                    ' display approvals if applicable
                    If displayApprovals Then
                        .Append("<tr><td class=""tblRow1"" colspan=""" & dtProductGridColumns.Rows.Count - 1 & """>")
                        .Append("<div id=""ProductApproval" & CType(productID("ProductID"), Integer).ToString & """  class=""tblRow1"" style=""display:none;"">")
                        .Append("<strong>Approvals</strong><br><br>")
                        Dim dt As DataTable = dtProductGridApprovals.DefaultView.ToTable(True, New String() {"ProductID", "ProductName", "ProductApprovals"})
                        Dim approvalRows() As DataRow = dt.Select("ProductID = " + productID("ProductID").ToString)

                        If approvalRows.Length > 0 Then
                            For Each approvalRow As DataRow In approvalRows
                                'we are tracking the document downloads by passing the information through a document download tracker
                                .Append(approvalRow("ProductApprovals").ToString)
                            Next
                        Else
                            .Append("&nbsp;") 'approval does not exist for product
                        End If
                        .Append("<br></div></td></tr>")
                        .Append(altRow)
                    End If

                Next
                .Append("</table>")
                Return .ToString
            End With
        Else
            Return String.Empty
        End If

    End Function

    Public Function Delete() As Boolean Implements IProductGridModule.Delete
        Dim success As Boolean
        Dim iCmd As IDbCommand
        Dim data As New DataAccess(SiteProfile.GetConnectionString, DataAccess.DataProvider.SQL)
        Dim dict As New System.Collections.Specialized.HybridDictionary

        'sp__DeleteProductGridModule
        iCmd = data.GetCommand("sp__DeleteProductGridModule", CommandType.StoredProcedure, DataAccess.DataProvider.SQL)
        '@ProductGridModuleID int = null,
        Dim iParmProductGridModuleId As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@ProductGridModuleID", DbType.Int32, Me.ProductGridModuleId, 4, ParameterDirection.Input)
        '@UserID int = null,
        Dim iParmUserId As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@UserID", DbType.Int32, Me.LastModBy, 4, ParameterDirection.Input)
        '@JobID int = null,
        Dim iParmJobId As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@JobID", DbType.Int32, Me.JobID, 4, ParameterDirection.Input)
        '@WorkflowStatus varchar(50) = 'WORKING'
        ' no parm -- use default value

        With iCmd.Parameters
            .Add(iParmProductGridModuleID)
            .Add(iParmJobID)
            .Add(iParmUserID)
        End With

        dict.Add(dict.Count, iCmd)

        Try
            success = data.ExecuteNonQuery(dict)
            Return success
        Catch ex As Exception
            Throw New NLTException("Error deleting Product Grid Module.", ex, "ProductGridModule.vb", "Function Delete() As Boolean")
        End Try
    End Function

    Public Sub Fill() Implements IProductGridModule.Fill

        Dim data As New DataAccess(SiteProfile.GetConnectionString, DataAccess.DataProvider.SQL)
        Dim iCmd As IDbCommand = data.GetCommand("sp__GetProductGridModuleByModId", CommandType.StoredProcedure, DataAccess.DataProvider.SQL)
        Dim iParmId As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@ProductGridModuleId", DbType.Int32, Me.ProductGridModuleId, 4, ParameterDirection.Input)
        Dim iParmLiveMode As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@LiveMode", DbType.Boolean, Me.LiveModeStatus, 1, ParameterDirection.Input)
        With iCmd.Parameters
            .Add(iParmID)
            .Add(iParmLiveMode)
        End With
        Dim dt As DataTable = data.GetDataTable(iCmd)

        For Each row As DataRow In dt.Rows
            Me.ProductGridModuleId = Services.GetNULLableInteger(row("PGM_ProductGridModuleID"))
            'Me.ModuleTypeId = Services.GetNULLableInteger(row("PGM_Modul   eTypeId"))
            Me.ProductGridBlurb = Services.GetNULLableString(row("PGM_GridBlurb"))
            Me.ProductGridId = Services.GetNULLableInteger(row("PGM_GridID"))
            Me.ProductGridTitle = Services.GetNULLableString(row("PGM_GridTitle"))
            Me.GridModuleOrder = Services.GetNULLableInteger(row("PGM_ModuleOrder"))
            Me.ModuleOrder = Services.GetNULLableInteger(row("PGM_ModuleOrder"))
            Me.ProductGrid.ProductGridID = Services.GetNULLableInteger(row("PGM_GridID")) 'KR
            Me.ProductGrid.ProductGridName = Services.GetNULLableString(row("PG_GridName")) ' KR
            If Me.LiveModeStatus = LiveMode.CMS Then
                ' set workflow properties
                Me.PublishDate = Services.GetNULLableDateTime(row("PublishDate"))
                Me.ExpireDate = Services.GetNULLableDateTime(row("ExpirationDate"))
                Me.WorkflowStatus = row("WorkflowStatus").ToString
                Me.LastModDate = Services.GetNULLableDateTime(row("LastModifiedDate"))
                Me.LastModBy = Services.GetNULLableInteger(row("LastModifiedBy"))
                Me.LastModByName = row("LastModifiedByName").ToString
                Me.MarkedForDelete = Services.GetNULLableInteger(row("MarkedForDeletion"))
                Me.JobID = Services.GetNULLableInteger(row("DeploymentJobID"))
                Me.JobName = row("JobName").ToString
                Me.JobDescription = row("JobDescription").ToString
            End If

        Next

    End Sub

    Public Function Save() As Boolean Implements IProductGridModule.Save



        Dim success As Boolean
        Dim iCmd As IDbCommand
        Dim iParmProductGridModuleId As IDbDataParameter
        Dim iParmPageModuleRelnId As IDbDataParameter = Nothing
        Dim iParmPageId As IDbDataParameter = Nothing
        Dim iParmModuleType As IDbDataParameter = Nothing

        Dim data As New DataAccess(SiteProfile.GetConnectionString, DataAccess.DataProvider.SQL)
        Dim dict As New System.Collections.Specialized.HybridDictionary
        Dim strStoredProc As String

        ' determine whether item should be added or updated
        If Me.ProductGridModuleId = 0 Then
            strStoredProc = "sp__AddProductGridModule"
            '@PageID int = null,
            iParmPageID = data.GetParameter(DataAccess.DataProvider.SQL, "@PageID", DbType.Int32, Me.PageId, 4, ParameterDirection.Input)
            iParmProductGridModuleID = data.GetParameter(DataAccess.DataProvider.SQL, "@ProductGridModuleID", DbType.Int32, System.DBNull.Value, 4, ParameterDirection.Output)
            iParmPageModuleRelnID = data.GetParameter(DataAccess.DataProvider.SQL, "@PageModuleRelnID", DbType.Int32, System.DBNull.Value, 4, ParameterDirection.Output)
            '@ModuleType varchar(50) = 'PRODUCT BLURB',
            iParmModuleType = data.GetParameter(DataAccess.DataProvider.SQL, "@ModuleType", DbType.String, Me.ModuleType, 50, ParameterDirection.Input)
        Else
            strStoredProc = "sp__UpdateProductGridModule"
            iParmProductGridModuleID = data.GetParameter(DataAccess.DataProvider.SQL, "@ProductGridModuleID", DbType.Int32, Me.ProductGridModuleId, 4, ParameterDirection.Input)
        End If

        '@ProductGridTitle varchar(50) = null,
        Dim iParmProductGridTitle As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@ProductGridTitle", DbType.String, Me.ProductGridTitle, 50, ParameterDirection.Input)
        '@ProductGridBlurb text = null,
        Dim iParmProductGridBlurb As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@ProductGridBlurb", DbType.String, Me.ProductGridBlurb, Me.ProductGridBlurb.Length, ParameterDirection.Input)
        '@ModuleOrder int = null,
        Dim iParmModuleOrder As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@ModuleOrder", DbType.Int32, Me.ModuleOrder, 4, ParameterDirection.Input)
        '@ShowTitle bit = 0,
        Dim iParmShowTitle As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@ShowTitle", DbType.Boolean, Me.ShowTitle, 1, ParameterDirection.Input)
        '@ProductGridID int = 0,
        Dim iParmProductGridId As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@ProductGridID", DbType.Int32, Me.ProductGrid.ProductGridID, 4, ParameterDirection.Input)
        '@ProductGridName varchar(100) = null,
        Dim iParmProductGridName As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@ProductGridName", DbType.String, Me.ProductGrid.ProductGridName, 100, ParameterDirection.Input)
        '@BusUnitID int = 0,
        Dim iParmBusUnitId As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@BusUnitID", DbType.Int32, Me.ProductGrid.BusUnitID, 4, ParameterDirection.Input)
        '@ProductIDList varchar(200) = '',
        Dim iParmProductIdList As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@ProductIDList", DbType.String, Me.ProductGrid.ProductRowList, 200, ParameterDirection.Input)
        '@AttributeIDList varchar(200) = '',
        Dim iParmAttributeIdList As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@AttributeIDList", DbType.String, Me.ProductGrid.AttributeColumnList, 200, ParameterDirection.Input)

        '@PublishDate datetime = null,
        Dim iParmPublishDate As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@PublishDate", DbType.Date, Me.PublishDate, 8, ParameterDirection.Input)
        '@ExpireDate datetime = null,
        Dim iParmExpireDate As IDbDataParameter
        If Me.ExpireDate <> #12:00:00 AM# Then
            iParmExpireDate = data.GetParameter(DataAccess.DataProvider.SQL, "@ExpireDate", DbType.Date, Me.ExpireDate, 8, ParameterDirection.Input)
        Else
            iParmExpireDate = data.GetParameter(DataAccess.DataProvider.SQL, "@ExpireDate", DbType.Date, System.DBNull.Value, 8, ParameterDirection.Input)
        End If
        '@MarkedForDeletion bit = 0,
        ' just use default value
        '@WorkflowStatus varchar(50) = 'WORKING',
        ' just use default value
        '@JobID int = null,
        Dim iParmJobId As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@JobID", DbType.Int32, Me.JobID, 4, ParameterDirection.Input)
        '@UserID int = null,
        Dim iParmUserId As IDbDataParameter = data.GetParameter(DataAccess.DataProvider.SQL, "@UserID", DbType.Int32, Me.LastModBy, 4, ParameterDirection.Input)

        '' create cmd and add parms
        iCmd = data.GetCommand(strStoredProc, CommandType.StoredProcedure, DataAccess.DataProvider.SQL)
        With iCmd.Parameters
            .Add(iParmProductGridModuleID)
            If iParmPageID IsNot Nothing Then
                .Add(iParmPageID)
            End If
            If iParmPageModuleRelnID IsNot Nothing Then
                .Add(iParmPageModuleRelnID)
            End If
            If iParmModuleType IsNot Nothing Then
                .Add(iParmModuleType)
            End If
            .Add(iParmProductGridTitle)
            .Add(iParmProductGridBlurb)
            .Add(iParmModuleOrder)
            .Add(iParmShowTitle)
            .Add(iParmProductGridID)
            .Add(iParmProductGridName)
            .Add(iParmBusUnitID)
            .Add(iParmProductIDList)
            .Add(iParmAttributeIDList)
            .Add(iParmPublishDate)
            .Add(iParmExpireDate)
            .Add(iParmJobID)
            .Add(iParmUserID)
        End With

        dict.Add(dict.Count, iCmd)

        Try
            success = data.ExecuteNonQuery(dict)
            If success Then
                If Me.ProductGridModuleId = 0 And iParmProductGridModuleID.Value IsNot System.DBNull.Value Then
                    ' set the id
                    Me.ProductGridModuleId = iParmProductGridModuleID.Value
                End If
            End If

            Return success
        Catch ex As Exception
            Throw New NLTException("Error saving Product Grid Module.", ex, "ProductGridModule.vb", "Function Save() As Boolean")
        End Try
    End Function





End Class
