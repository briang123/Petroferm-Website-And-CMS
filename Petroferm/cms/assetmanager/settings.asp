<%
Dim arrBaseFolder
Redim arrBaseFolder(4)

Dim arrBaseName
Redim arrBaseName(4)

Dim bReturnAbsolute
bReturnAbsolute=false

' determine root folder - added 1/2/07 kr to fix path issues on the diff servers
dim root
if UCase(request.servervariables("SERVER_NAME")) = "LOCALHOST" then
	root = "/petroferm"
end if

arrBaseFolder(0)= root & "/web/files/docs/unmanaged/"'Use "Relative to Root" Path
arrBaseName(0)="Documents"

arrBaseFolder(1)= root & "/web/files/images/content/"
arrBaseName(1)="Content Images"

arrBaseFolder(2)=""
arrBaseName(2)=""
 
arrBaseFolder(3)=""
arrBaseName(3)=""

%>