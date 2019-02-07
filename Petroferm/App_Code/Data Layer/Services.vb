Imports System.Data
Imports System.Configuration.ConfigurationManager

Namespace Data

    Public Class Services

        Public Shared Sub MoveTableToNewDataSet(ByRef targetDataSet As DataSet, ByRef srcTable As DataTable)

            Try
                Dim dt As DataTable = srcTable.Clone
                dt.TableName = srcTable.TableName
                For Each row As DataRow In srcTable.Rows
                    dt.ImportRow(row)
                Next
                targetDataSet.Tables.Add(dt)
            Catch ex As Exception
                Throw
            End Try

        End Sub

        Public Shared Sub TruncateDataTable(ByRef sourceTable As DataTable)
            For i As Integer = sourceTable.Rows.Count - 1 To 0 Step -1
                sourceTable.Rows.RemoveAt(i)
            Next
        End Sub

        '''-----------------------------------------------------------------------------
        ''' <summary>
        ''' Function to accept a data table and remove duplicate rows from it based on the columns passed.
        ''' </summary>
        ''' <param name="sourceTable"></param>
        ''' <param name="columnList">Comma delimited list of column names (Name of column,
        ''' not the header text)</param>
        ''' <param name="sortExpr">sort expression describing how the data table should be 
        ''' sorted.</param>
        ''' <returns>Distinct rows as a data table</returns>
        ''' <remarks>This function only accepts comma delimited column list for the 
        ''' columnList parameter</remarks>
        ''' <history>
        '''  Brian Gaines  10/5/2004 Created
        ''' </history>
        '''-----------------------------------------------------------------------------
        Public Shared Function RemoveDuplicateRows(ByVal sourceTable As DataTable, _
                                                    ByVal columnList As String, _
                                                    Optional ByVal sortExpr As String = "") As DataTable

            'Build my string array of column names in the data table
            Dim cols() As String = columnList.Split(","c)

            'Create array to store values in each field of cols() string array
            Dim vals() As String
            vals = DirectCast(cols.Clone, String())

            'Make a copy of our original data table to import distinct records
            Dim cloneTable As DataTable = sourceTable.Clone()

            'Sort our data table before iterating through data
            'If a sort expression is not supplied, then we will just
            'have our data table as it was passed into this function.
            Dim rows() As DataRow = sourceTable.Select("", sortExpr)

            'Initialize our vals() array with empty string values
            Dim i As Integer
            For i = cols.GetLowerBound(0) To cols.GetUpperBound(0)
                vals.SetValue(String.Empty, i)
            Next

            Dim result As Integer
            Dim different As Boolean = False
            'Loop through each data row
            Dim row As DataRow
            For Each row In rows

                'Loop through each column
                For i = cols.GetLowerBound(0) To cols.GetUpperBound(0)

                    'Check if each column value matches the previous rows column values
                    'A non-match will return -1, so we will need to check for it.
                    If vals(i).Equals(row(cols(i)).ToString) Then
                        result = 0
                    Else
                        result = -1
                    End If
                    'result = vals(i).Compare(vals(i), row(cols(i).ToString).ToString, True)

                    'Update our values array with the data in the current row
                    'This will be checked for the next time around
                    vals.SetValue(row(cols(i).ToString).ToString, i)

                    'If we are not on the first data row (empty string value) or 
                    'the current row does not match previous row then NO DUPE!!!
                    If vals.GetValue(i) Is String.Empty Or result < 0 Then
                        different = True
                    End If

                Next

                'If our NO DUPE flag is True then import the row into the 
                'new data table. We need to make sure we RESET our NO DUPE 
                'flag back to False; otherwise, all subsequent rows will 
                'be duped incorrectly
                If different = True Then
                    cloneTable.ImportRow(row)
                    different = False
                End If

            Next

            'Remember now that we imported the *FIRST* occurrence of each data row
            'in our data table, which was the reason for the sort expression. If 
            'you get incorrect results, you may want to check how you are sorting
            'the data in the data table.

            'Return our distinct values 
            Return cloneTable

        End Function

        Public Shared Function SafeSql(ByVal value As String) As String
            Return Chr(39) & value.Replace("'", "''") & Chr(39)
        End Function

        Public Shared Function GetNulLableString(ByVal val As Object) As String
            ' added is nothing check - kr - 12/22/06
            If val Is Nothing Then
                Return String.Empty
            ElseIf val.Equals(DBNull.Value) Or val.ToString = "&nbsp;" Then
                Return String.Empty
            Else
                Return val.ToString()
            End If
        End Function

        Public Shared Function GetNulLableInteger(ByVal val As Object) As Integer
            If val.Equals(DBNull.Value) Or val.Equals(String.Empty) Or val.ToString = "&nbsp;" Then
                Return 0
            Else
                Return Convert.ToInt32(val)
            End If
        End Function

        Public Shared Function GetNulLableBoolean(ByVal val As Object) As Boolean
            If val.Equals(DBNull.Value) Or val.ToString = "&nbsp;" Then
                Return False
            Else
                Return Convert.ToBoolean(val)
            End If
        End Function

        Public Shared Function GetNulLableDouble(ByVal val As Object) As Double
            If val.Equals(DBNull.Value) Or val.Equals(String.Empty) Or val.ToString = "&nbsp;" Then
                Return 0
            Else
                Return Convert.ToDouble(val)
            End If
        End Function

        Public Shared Function GetNulLableDecimal(ByVal val As Object) As Decimal
            If val.Equals(DBNull.Value) Or val.Equals(String.Empty) Or val.ToString = "&nbsp;" Then
                Return 0
            Else
                Return Convert.ToDecimal(val)
            End If
        End Function

        Public Shared Function GetNulLableDateTime(ByVal val As Object) As DateTime
            If val.Equals(DBNull.Value) Or val.Equals(String.Empty) Or val.ToString = "&nbsp;" Then
                Return Nothing
            Else
                Return Convert.ToDateTime(val)
            End If
        End Function

        Public Shared Function GetNulLableStringParameter(ByVal iParm As IDbDataParameter, ByVal val As Object) As IDbDataParameter

            Dim localParm As IDbDataParameter = iParm
            If val.Equals(DBNull.Value) Or val.Equals(String.Empty) Then
                localParm.Value = DBNull.Value
            Else
                localParm.Value = Replace(val.ToString, "'", "''")
            End If

            Return localParm

        End Function

        Public Shared Function GetNulLableIntegerParameter(ByVal iParm As IDbDataParameter, ByVal val As Object) As IDbDataParameter

            Dim localParm As IDbDataParameter = iParm
            If val.Equals(DBNull.Value) Or val.Equals(String.Empty) Then
                localParm.Value = DBNull.Value
            Else
                localParm.Value = Convert.ToInt32(val)
            End If

            Return localParm

        End Function

        Public Shared Function GetNulLableDoubleParameter(ByVal iParm As IDbDataParameter, ByVal val As Object) As IDbDataParameter

            Dim localParm As IDbDataParameter = iParm
            If val.Equals(DBNull.Value) Or val.Equals(String.Empty) Then
                localParm.Value = DBNull.Value
            Else
                localParm.Value = Convert.ToDouble(val)
            End If

            Return localParm

        End Function

        Public Shared Function GetNulLableDecimalParameter(ByVal iParm As IDbDataParameter, ByVal val As Object) As IDbDataParameter

            Dim localParm As IDbDataParameter = iParm
            If val.Equals(DBNull.Value) Or val.Equals(String.Empty) Then
                localParm.Value = DBNull.Value
            Else
                localParm.Value = Convert.ToDecimal(val)
            End If

            Return localParm

        End Function

        Public Shared Function GetNulLableDateParameter(ByVal iParm As IDbDataParameter, ByVal val As Object) As IDbDataParameter

            Dim localParm As IDbDataParameter = iParm
            If val.Equals(DBNull.Value) Or val.Equals(String.Empty) Then
                localParm.Value = DBNull.Value
            Else
                localParm.Value = Convert.ToDateTime(val)
            End If

            Return localParm

        End Function

        Public Shared Function GetReaderNulLableValue(ByVal r As IDataReader, ByVal columnIndex As Integer, ByVal type As DbType, ByVal retText As Object) As Object
            Dim value As Object = Nothing
            If r.IsDBNull(columnIndex) = True Then
                Select Case type
                    Case DbType.Currency, DbType.Decimal, DbType.Double, DbType.Int32, DbType.Int16, DbType.Int64, DbType.Single
                        value = 0
                    Case DbType.String
                        value = String.Empty
                End Select
            Else
                value = r.GetValue(columnIndex)
            End If
            Return value
        End Function


        Public Shared Function NltIsNumber(ByVal val As String) As Boolean
            Dim isNum As Boolean = True
            If val.Length > 0 Then
                For i As Integer = 1 To val.Length
                    If Char.IsNumber(val, i - 1) = False Then
                        isNum = False
                        Exit For
                    End If
                Next
            Else
                isNum = False
            End If
            Return isNum
        End Function

        Public Shared Function IsPastDate(ByVal val As String) As Boolean

            If IsDate(val) Then

                Dim mo As Integer = Month(CType(val, Date))
                Dim d As Integer = Day(CType(val, Date))
                Dim y As Integer = Year(CType(val, Date))

                Dim dateSelected As Date = New Date(y, mo, d)

                If Date.Today.Subtract(dateSelected).TotalDays > 0 Then
                    Return True
                End If

            End If

        End Function

        Public Shared Function BindToEnumKeyValue(ByVal names() As String, ByVal values As Array) As DataTable

            Dim dt As New DataTable
            dt.Columns.Add("Key", GetType(String))
            dt.Columns.Add("Value", GetType(Integer))

            Dim i As Integer = 0
            While i < names.Length
                Dim dr As DataRow = dt.NewRow
                dr("Key") = names(i)
                dr("Value") = CType(values.GetValue(i), Integer)
                dt.Rows.Add(dr)
                i += i
            End While
            Return dt

        End Function

        Public Shared Function AddReadOnlyLineBreaks(ByVal val As String) As String
            If val Is Nothing Then val = String.Empty
            Return RegularExpressions.Regex.Replace(val, vbCrLf, "<br/>")
        End Function

        Public Shared Function GetListFromConfig(ByVal key As String) As IList

            'NOTE:  If you see a blank item in whatever you're binding to, then check 
            '       the web.config key for a ";" at the end of the value list. No semi-colon at the end.
            Dim customList() As String = System.Configuration.ConfigurationManager.AppSettings(key).Split(";"c)
            Dim al As New ArrayList
            With al
                For i As Integer = 0 To customList.Length - 1
                    .Add(customList(i))
                Next
                .Sort()
            End With
            Return al
        End Function

        Public Shared Function GetHashFromConfig(ByVal key As String) As Hashtable

            'NOTE:  If you see a blank item in whatever you're binding to, then check 
            '       the web.config key for a ";" at the end of the value list. No semi-colon at the end.
            Dim customList() As String = System.Configuration.ConfigurationManager.AppSettings(key).Split(";"c)
            Dim ht As New Hashtable
            With ht
                For i As Integer = 0 To customList.Length - 1
                    Dim keyvalpair() As String = customList(i).Split("|"c)

                    Dim val1 As String = keyvalpair(0).ToString
                    Dim val2 As String = keyvalpair(1).ToString
                    .Add(val2, val1)
                Next
            End With
            Return ht
        End Function

    End Class

End Namespace