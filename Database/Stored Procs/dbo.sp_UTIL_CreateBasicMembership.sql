


CREATE   proc sp_UTIL_CreateBasicMembership
	@userName nvarchar(256) = 'Administrator',
	@applicationId uniqueidentifier output,
	@uid int output
as
begin

/*
created by: Brian Gaines
created on: 1/1/2007
purpose: These scripts will assist in re-creating the petroferm website core membership elements. 
	If a new database environment is being created, these scripts might help with creating the application and 
	appropriate roles and a single administrator user. If a new environment is being built, a more 
	extensive process will need to be followed to create all the necessary asp.net membership tables, which this 
	procedure depends on.

	This information can also be created by installing the the Visual Studio.NET 2005 IDE and clicking on the 
	configure website menu option from the toolbar (or solution explorer)

history:
	Brian Gaines 1/1/2007 - created initial procedure
*/
	declare @userId int
	declare @userIdguid uniqueidentifier
	select @userId = 0

	-- create the Petroferm application for Membership provider
	declare @appId uniqueidentifier
	exec dbo.aspnet_Applications_CreateApplication @ApplicationName = '/Petroferm', @ApplicationId = @appId OUTPUT
	select @applicationid = @appId
		
	-- create the default roles (if they don't exist) 
	exec dbo.aspnet_Roles_CreateRole '/Petroferm','Administrator'
	exec dbo.aspnet_Roles_CreateRole '/Petroferm','Deployer'
	exec dbo.aspnet_Roles_CreateRole '/Petroferm','Approver'
	exec dbo.aspnet_Roles_CreateRole '/Petroferm','Reviewer'
	exec dbo.aspnet_Roles_CreateRole '/Petroferm','Author'
	exec dbo.aspnet_Roles_CreateRole '/Petroferm','Reader'
	exec dbo.aspnet_Roles_CreateRole '/Petroferm','WebsiteUser'
	
	-- create default user so user administrator can log into the CMS
	-- hard-coded password is !Petroferm2006 (can be changed once you login)
	
	if not exists (select 1 from aspnet_users where loweredusername = 'administrator')
	begin
		declare @now datetime
		select @now = getdate()
		exec dbo.aspnet_Membership_CreateUser 
			@ApplicationName = '/Petroferm',
			@UserName = @userName,
			@Password = '25ZVy+a3izUzV7lKzIL4Ad9Xd9c=',
			@PasswordSalt = 'Vh6InJYKwb2d/OSy73R6eQ==',
			@Email = 'admin@petroferm.com',
			@PasswordQuestion = '',
			@PasswordAnswer = '',
			@IsApproved = 1,
			@CurrentTimeUtc = @now,
			@CreateDate = null,
			@UniqueEmail = 0,
			@PasswordFormat = 1,
			@UserId = @userIdguid output
	
		exec sp__AddUser
			@LastModBy = 0,
			@UserId = @userIdguid,
			@FirstName = 'System',
			@LastName = 'Administrator',
			@AppUserID = @userId
		
		--add user to the following roles
		EXEC dbo.aspnet_UsersInRoles_AddUsersToRoles
			@ApplicationName = '/Petroferm', 
			@RoleNames = 'Administrator,Deployer,Approver,Reviewer,Author,Reader,WebsiteUser', 
			@UserNames = @userName, 
			@CurrentTimeUtc = @now
		
	end
	
	if (@userId = 0)
	begin
		select @userId = AppUserId from tblAppUser u, aspnet_Users aspnet
		where u.userid = aspnet.userid
		and aspnet.username = @userName	
	end

	select @uid = @userId
end