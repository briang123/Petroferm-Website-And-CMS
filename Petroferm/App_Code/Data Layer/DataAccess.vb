#Region " IMPORTS "
Imports System
Imports System.ComponentModel
Imports System.Data
Imports System.Data.Common
Imports System.Data.OleDb
Imports System.Data.SqlClient
Imports System.Data.OracleClient
Imports System.Web
#End Region

Namespace Data

    Public Class DataAccess
        Implements IDisposable
        Implements IDataAccess

#Region " PRIVATE MEMBER VARIABLES "

        Private _mConnectionString As String
        Private _mConnection As IDbConnection
        Private _mDataProvider As DataProvider

#End Region

#Region " CONSTRUCTORS "

        Public Sub New()
        End Sub

        Public Sub New(ByVal connectionString As String, ByVal dataProvider As DataProvider)
            _mDataProvider = dataProvider
            _mConnectionString = connectionString
            _mConnection = GetConnection(connectionString, dataProvider)
        End Sub

#End Region

        Public Enum DataProvider
            Oledb
            Oracle
            Sql
        End Enum

        Public Function GetConnection(ByVal connectionString As String, ByVal dataProvider As DataProvider) As IDbConnection Implements IDataAccess.GetConnection
            Select Case dataProvider
                Case dataProvider.OLEDB
                    _mConnection = New OleDbConnection(connectionString)
                Case dataProvider.ORACLE
                    _mConnection = New OracleConnection(connectionString)
                Case dataProvider.SQL
                    _mConnection = New SqlConnection(connectionString)
            End Select
            Return _mConnection
        End Function

        Public Function GetTransaction(ByVal dataProvider As DataProvider) As IDbTransaction Implements IDataAccess.GetTransaction
            Dim iTxn As IDbTransaction = Nothing
            Select Case dataProvider
                Case dataProvider.OLEDB
                    iTxn = DirectCast(iTxn, OleDbTransaction)
                Case dataProvider.ORACLE
                    iTxn = DirectCast(iTxn, OracleTransaction)
                Case dataProvider.SQL
                    iTxn = DirectCast(iTxn, SqlTransaction)
            End Select
            Return iTxn
        End Function

        Public Function GetDataAdapter(ByVal query As String, ByVal dataProvider As DataProvider) As IDbDataAdapter Implements IDataAccess.GetDataAdapter
            Dim da As IDbDataAdapter = Nothing
            Select Case dataProvider
                Case dataProvider.OLEDB
                    da = New OleDbDataAdapter(query, _mConnectionString)
                Case dataProvider.ORACLE
                    da = New OracleDataAdapter(query, _mConnectionString)
                Case dataProvider.SQL
                    da = New SqlDataAdapter(query, _mConnectionString)
            End Select
            Return da
        End Function

        Public Function GetDataAdapter(ByVal iCmd As IDbCommand, ByVal dataProvider As DataProvider) As IDbDataAdapter
            Dim da As IDbDataAdapter = Nothing
            Select Case dataProvider
                Case dataProvider.OLEDB
                    da = New OleDbDataAdapter(DirectCast(iCmd, OleDbCommand))
                Case dataProvider.ORACLE
                    da = New OracleDataAdapter(DirectCast(iCmd, OracleCommand))
                Case dataProvider.SQL
                    da = New SqlDataAdapter(DirectCast(iCmd, SqlCommand))
            End Select
            Return da
        End Function

        Public Function GetCommand(ByVal query As String, ByVal commandType As CommandType, ByVal dataProvider As DataProvider) As IDbCommand Implements IDataAccess.GetCommand
            Try
                _mConnection.CreateCommand()
                Dim cmd As IDbCommand = Nothing
                Select Case dataProvider
                    Case dataProvider.OLEDB
                        cmd = New OleDbCommand(query, DirectCast(_mConnection, OleDbConnection))
                    Case dataProvider.ORACLE
                        cmd = New OracleCommand(query, DirectCast(_mConnection, OracleConnection))
                    Case dataProvider.SQL
                        cmd = New SqlCommand(query, DirectCast(_mConnection, SqlConnection))
                End Select
                cmd.CommandType = commandType
                Return cmd
            Catch ex As Exception
                Throw New ApplicationException(ex.ToString, ex)
            End Try
        End Function

        Public Function GetParameter(ByVal dataProvider As DataProvider, _
                                        ByVal paramName As String, _
                                        ByVal paramDbType As DbType, _
                                        ByVal paramValue As Object, _
                                        ByVal paramSize As Integer, _
                                        ByVal paramDirection As ParameterDirection, _
                                        Optional ByVal paramPrecision As Byte = 0, _
                                        Optional ByVal paramScale As Byte = 0, _
                                        Optional ByVal paramSourceColumn As String = Nothing, _
                                        Optional ByVal paramSourceVersion As DataRowVersion = DataRowVersion.Default) As IDbDataParameter

            Dim iParm As IDbDataParameter = Nothing
            Select Case dataProvider
                Case dataProvider.OLEDB
                    iParm = New OleDbParameter
                Case dataProvider.ORACLE
                    iParm = New OracleParameter
                Case dataProvider.SQL
                    iParm = New SqlParameter
            End Select

            With iParm
                .DbType = paramDbType
                .ParameterName = paramName
                .Precision = paramPrecision
                .Scale = paramScale
                .SourceColumn = paramSourceColumn
                .SourceVersion = paramSourceVersion
                .Direction = paramDirection
                If paramValue Is Nothing Then
                    paramValue = DBNull.Value
                Else
                    Select Case paramDbType
                        Case DbType.String
                            If paramValue.Equals(DBNull.Value) Or paramValue.Equals(String.Empty) Then
                                paramValue = DBNull.Value
                            Else
                                paramValue = paramValue.ToString
                            End If
                        Case DbType.Double
                            If paramValue.Equals(DBNull.Value) Or paramValue.Equals(String.Empty) Then
                                paramValue = DBNull.Value
                            Else
                                paramValue = Convert.ToDouble(paramValue)
                            End If
                        Case DbType.Decimal, DbType.Currency
                            If paramValue.Equals(DBNull.Value) Or paramValue.Equals(String.Empty) Then
                                paramValue = DBNull.Value
                            Else
                                paramValue = Convert.ToDecimal(paramValue)
                            End If
                        Case DbType.Date, DbType.DateTime
                            If paramValue.Equals(DBNull.Value) Or paramValue.Equals(String.Empty) Then
                                paramValue = DBNull.Value
                            Else
                                paramValue = Convert.ToDateTime(paramValue)
                            End If
                        Case DbType.Int16
                            If paramValue.Equals(DBNull.Value) Or paramValue.Equals(String.Empty) Then
                                paramValue = DBNull.Value
                            Else
                                paramValue = Convert.ToInt16(paramValue)
                            End If
                        Case DbType.Int32
                            If paramValue.Equals(DBNull.Value) Or paramValue.Equals(String.Empty) Then
                                paramValue = DBNull.Value
                            Else
                                paramValue = Convert.ToInt32(paramValue)
                            End If
                        Case DbType.Int64
                            If paramValue.Equals(DBNull.Value) Or paramValue.Equals(String.Empty) Then
                                paramValue = DBNull.Value
                            Else
                                paramValue = Convert.ToInt64(paramValue)
                            End If
                    End Select
                End If
                .Value = paramValue
                .Size = paramSize
            End With
            Return iParm

        End Function

        Public Function GetDataReader(ByVal query As String, _
                                        ByVal commandType As CommandType, _
                                        ByVal dataProvider As DataProvider) As IDataReader Implements IDataAccess.GetDataReader
            Dim cmd As IDbCommand = Nothing
            Dim dr As IDataReader = Nothing
            Try
                cmd = GetCommand(query, commandType, dataProvider)
                dr = cmd.ExecuteReader
            Catch ex As Exception
                Throw New ApplicationException(ex.ToString, ex)
            End Try
            Return dr
        End Function

        Public Function GetDataList(ByVal query As String) As IListSource Implements IDataAccess.GetDataList
            Dim ds As New DataSet
            Dim iAdapter As IDbDataAdapter = Nothing
            Try
                iAdapter = GetDataAdapter(query, _mDataProvider)
                Me.OpenConnection()
                iAdapter.Fill(ds)
            Catch ex As ApplicationException
                Throw New ApplicationException("An error occurred while attempting to return a generic object that can be bound to.", ex)
            Finally
                Me.CloseConnection()
            End Try
            Return DirectCast(ds, System.ComponentModel.IListSource)
        End Function

        Public Function GetDataList(ByVal iCmd As IDbCommand) As IListSource Implements IDataAccess.GetDataList
            Dim ds As New DataSet
            Dim iAdapter As IDbDataAdapter = Nothing
            Try
                iAdapter = GetDataAdapter(iCmd, _mDataProvider)
                Me.OpenConnection()
                With iAdapter
                    .SelectCommand = iCmd
                    .Fill(ds)
                End With
            Catch ex As ApplicationException
                Throw New ApplicationException("An error occurred while attempting to return a generic object that can be bound to.", ex)
            Finally
                Me.CloseConnection()
            End Try
            Return DirectCast(ds, System.ComponentModel.IListSource)
        End Function

        Public Function ExecuteNonQuery(ByVal commandText As String, ByVal commandType As CommandType) As Boolean Implements IDataAccess.ExecuteNonQuery

            Dim recs As Integer

            Dim iCmd As IDbCommand = Nothing
            Try
                Dim da As IDbDataAdapter = GetDataAdapter(commandText, _mDataProvider)
                iCmd = GetCommand(commandText, commandType, _mDataProvider)
                iCmd.Connection = GetConnection(_mConnectionString, _mDataProvider)
                iCmd.Connection.Open()
                With da
                    .UpdateCommand = iCmd
                    .UpdateCommand.CommandText = commandText
                    .UpdateCommand.CommandType = commandType.Text
                    recs = .UpdateCommand.ExecuteNonQuery
                End With
            Catch ex As Exception
                Throw New ApplicationException(ex.ToString, ex)
            Finally
                If iCmd.Connection.State <> ConnectionState.Closed Then
                    iCmd.Connection.Close()
                End If
            End Try

            Return (recs > 0)

        End Function

        Public Function ExecuteNonQuery(ByVal dict As IDictionary, ByVal useNumericDictKey As Boolean) As Boolean

            Dim success As Boolean = True
            Dim iCon As IDbConnection = Nothing
            Dim iCmd As IDbCommand = Nothing
            iCon = GetConnection(SiteProfile.GetConnectionString(), DataProvider.SQL)
            iCon.Open()

            Dim iTxn As IDbTransaction
            Dim result As Integer
            iTxn = iCon.BeginTransaction

            Try

                If useNumericDictKey Then
                    Dim i As Integer
                    For i = 0 To dict.Count - 1
                        iCmd = CType(dict(i), IDbCommand)
                        iCmd.Connection = iCon
                        iCmd.Transaction = iTxn
                        result = iCmd.ExecuteNonQuery()
                    Next

                Else
                    Dim iEnum As IEnumerator = dict.GetEnumerator
                    While iEnum.MoveNext
                        iCmd = CType(CType(iEnum.Current, DictionaryEntry).Value, IDbCommand)
                        iCmd.Connection = iCon
                        iCmd.Transaction = iTxn
                        iCmd.ExecuteNonQuery()
                    End While
                End If

                iTxn.Commit()
            Catch ex As Exception
                success = False
                Try
                    iTxn.Rollback()
                Catch e As Exception
                    If Not iTxn.Connection Is Nothing Then
                        Throw New ApplicationException("An exception type of " & e.GetType().ToString() & " was encountered while attempting to rollback the transaction.")
                    End If
                End Try
            Finally
                If iCmd.Connection.State <> ConnectionState.Closed Then
                    iCmd.Connection.Close()
                End If
            End Try

            Return success
        End Function

        Public Function ExecuteNonQuery(ByVal dict As IDictionary) As Boolean Implements IDataAccess.ExecuteNonQuery

            Dim success As Boolean = True
            Dim iCon As IDbConnection = Nothing
            Dim iCmd As IDbCommand = Nothing
            iCon = GetConnection(SiteProfile.GetConnectionString, DataProvider.SQL)
            iCon.Open()

            Dim iTxn As IDbTransaction
            iTxn = iCon.BeginTransaction

            Try
                Dim iEnum As IEnumerator = dict.GetEnumerator
                While iEnum.MoveNext
                    iCmd = CType(CType(iEnum.Current, DictionaryEntry).Value, IDbCommand)
                    iCmd.Connection = iCon
                    iCmd.Transaction = iTxn
                    iCmd.ExecuteNonQuery()
                End While

                iTxn.Commit()
            Catch ex As Exception

                success = False
                Try
                    iTxn.Rollback()
                Catch e As Exception
                    If Not iTxn.Connection Is Nothing Then
                        Throw New ApplicationException("An exception type of " & e.GetType().ToString() & " was encountered while attempting to rollback the transaction.")
                    End If
                End Try
                Throw ex ' added by Kelly Roe 11/29/06 -- want exception to bubble up to what is calling this method
            Finally
                If iCmd.Connection.State <> ConnectionState.Closed Then
                    iCmd.Connection.Close()
                End If

            End Try

            Return success
        End Function

#Region " WRAPPER METHODS "

        Public Function GetDataTable(ByVal query As String) As DataTable
            Try
                Dim dataAccess As New DataAccess
                Dim iSource As IListSource = dataAccess.GetDataList(query)
                Return DirectCast(iSource, DataSet).Tables(0)
            Catch ex As ApplicationException
                Throw New ApplicationException("An error occurred while attempting to return a datatable.", ex)
            End Try
        End Function

        Public Function GetDataTable(ByVal iCmd As IDbCommand) As DataTable
            Try
                Dim iSource As IListSource = GetDataList(iCmd)
                ' check to make sure there is a table count > 0 for the dataset
                ' otherwise, return empty table
                ' kelly roe 11/29/06
                If DirectCast(iSource, DataSet).Tables.Count > 0 Then
                    Return DirectCast(iSource, DataSet).Tables(0)
                Else
                    Return New DataTable
                End If

            Catch ex As ApplicationException
                Throw New ApplicationException("An error occurred while attempting to return a datatable.", ex)
            End Try
        End Function

        Public Function GetDataSet(ByVal query As String) As DataSet
            Try
                Dim iSource As IListSource = GetDataList(query)
                Return DirectCast(iSource, DataSet)
            Catch ex As ApplicationException
                Throw New ApplicationException("An error occurred while attempting to return a dataset.", ex)
            End Try
        End Function

        Public Function GetDataSet(ByVal iCmd As IDbCommand) As DataSet
            Try
                Dim iSource As IListSource = GetDataList(iCmd)
                Return DirectCast(iSource, DataSet)
            Catch ex As ApplicationException
                Throw New ApplicationException("An error occurred while attempting to return a dataset.", ex)
            End Try
        End Function

        Public Function GetCachedDataSet(ByVal query As String, ByVal cacheName As String) As DataSet
            Try
                Dim cachedDataSet As DataSet = DirectCast(HttpContext.Current.Items(cacheName), DataSet)
                If cachedDataSet Is Nothing Then
                    HttpContext.Current.Cache.Insert(cacheName, GetDataSet(query))
                    Return DirectCast(HttpContext.Current.Cache.Item(cacheName), DataSet)
                Else
                    Return cachedDataSet
                End If
            Catch ex As ApplicationException
                Throw New ApplicationException("An error occurred while attempting to retrieve the cached dataset.", ex)
            End Try
        End Function

        Public Function GetCachedDataSet(ByVal iCmd As IDbCommand, ByVal cacheName As String) As DataSet
            Try
                Dim cachedDataSet As DataSet = DirectCast(HttpContext.Current.Items(cacheName), DataSet)
                If cachedDataSet Is Nothing Then
                    HttpContext.Current.Cache.Insert(cacheName, GetDataSet(iCmd))
                    Return DirectCast(HttpContext.Current.Cache.Item(cacheName), DataSet)
                Else
                    Return cachedDataSet
                End If
            Catch ex As ApplicationException
                Throw New ApplicationException("An error occurred while attempting to retrieve the cached dataset.", ex)
            End Try
        End Function

#End Region

#Region " CLEANUP "

        Private Sub CloseConnection() Implements IDataAccess.CloseConnection
            If _mConnection.State <> ConnectionState.Closed Then
                _mConnection.Close()
            End If
            _mConnection = Nothing
        End Sub

        Private Sub OpenConnection() Implements IDataAccess.OpenConnection
            If _mConnection.State = ConnectionState.Closed Then
                _mConnection = GetConnection(_mConnectionString, _mDataProvider)
                _mConnection.Open()
            End If
        End Sub

        Public Sub Dispose() Implements IDisposable.Dispose
            Me.CloseConnection()
        End Sub

#End Region

    End Class

End Namespace
