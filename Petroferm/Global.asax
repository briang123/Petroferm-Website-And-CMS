<%@ Application Language="VB" %>

<script runat="server">

    Sub Application_Start(ByVal sender As Object, ByVal e As EventArgs)
      ' Code that runs on application startup

      Dim dataMappings As System.Data.DataTable = TryCast(HttpContext.Current.Cache.Item("DomainMappings"), System.Data.DataTable)

      If dataMappings Is Nothing Then
        Dim data As New Global.Data.DataAccess(SiteProfile.GetConnectionString, Global.Data.DataAccess.DataProvider.SQL)
        Dim iCon As System.Data.IDbConnection = data.GetConnection(SiteProfile.GetConnectionString, Global.Data.DataAccess.DataProvider.SQL)
        Dim iCmd As System.Data.IDbCommand = data.GetCommand("select * from tblDomainMapping_U", System.Data.CommandType.Text, Global.Data.DataAccess.DataProvider.SQL)
        iCmd.Connection = iCon
        iCmd.Connection.Open()

        dataMappings = data.GetDataTable(iCmd)

        Dim sqlDependency As SqlCacheDependency = New SqlCacheDependency("Petroferm", "tblDomainMapping_U")
        HttpContext.Current.Cache.Insert("DomainMappings", dataMappings, sqlDependency, DateTime.Now.AddSeconds(30),  System.Web.Caching.Cache.NoSlidingExpiration)
      End If

    End Sub

    Sub Application_End(ByVal sender As Object, ByVal e As EventArgs)
      ' Code that runs on application shutdown
    End Sub

    Sub Application_Error(ByVal sender As Object, ByVal e As EventArgs)
      ' Code that runs when an unhandled error occurs
    End Sub

    Sub Session_Start(ByVal sender As Object, ByVal e As EventArgs)
      ' Code that runs when a new session is started
    End Sub

    Sub Session_End(ByVal sender As Object, ByVal e As EventArgs)
      ' Code that runs when a session ends. 
      ' Note: The Session_End event is raised only when the sessionstate mode
      ' is set to InProc in the Web.config file. If session mode is set to StateServer 
      ' or SQLServer, the event is not raised.
    End Sub

</script>