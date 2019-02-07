







CREATE       proc sp__UpdateBusinessUnit
	@BusUnitID int = null,
	@BusName varchar(300) = null,
	@DocAuth bit = 0,
	@PublishDate datetime = null,
	@ExpireDate datetime = null,
	@WorkflowStatus varchar(50) = 'WORKING',
	@UserID int = null,
	@ActiveFlag bit = 1,
	@JobID int = null,
	@LogoID int = null,
	@LogoImagePath varchar(500) = 'images/spacer.gif',
	@LogoAltText varchar(200) = '[REPLACE ALT TEXT]', 
	@LogoHeight int = 1, 
	@LogoWidth int = 1
as
begin

declare @errorcode int

/*

[history]
	Kelly Roe	12/14/2006 - made updating the image stuff optional if the path isn't provided
	Kelly Roe	12/15/2006 - fixed image updating -- may need to add a new record if uploading a new logo
	Kelly Roe	12/15/2006 - took out image path in the update tblImage stmt -- don't need it
*/


if (@PublishDate is null)
begin
	select @PublishDate = dbo.fn__GetDateOnly(getdate())
end
else
begin
	select @Publishdate = dbo.fn__GetDateOnly(@PublishDate)
end

if (@ExpireDate is null)
begin
	select @ExpireDate = dbo.fn__GetDateOnly(dateadd(year,30,@PublishDate))
end
else
begin
	select @ExpireDate = dbo.fn__GetDateOnly(@ExpireDate)
end


begin tran

	if (@LogoID <> 0)
	begin
		-- now update image record
		UPDATE tblImage
		SET 	--ImagePath = @LogoImagePath, -- this does not need to be updated (if it did, it would be a new image)
 			Alt = @LogoAltText,
			Width = @LogoWidth,
			Height = @LogoHeight,
			PublishDate = @PublishDate,
			ExpirationDate = @ExpireDate,
			WorkflowStatus = @WorkflowStatus,
			LastModifiedDate = getdate(),
			LastModifiedBy = @UserID,
			ActiveFlag = @ActiveFlag,
			DeploymentJobID = @JobID			
		WHERE   ImageID = @LogoID

		select @errorcode = @@error
	end
	else if (@LogoImagePath is not null and @LogoImagePath <> '') -- need to insert new one (if the path isn't null)
	begin
		insert into tblImage (ImagePath, Alt, Width, Height, PublishDate, ExpirationDate, WorkflowStatus, LastModifiedBy, ActiveFlag, MarkedForDeletion, DeploymentJobID)
		values (@LogoImagePath,@LogoAltText,@LogoWidth,@LogoHeight,@PublishDate,@ExpireDate,@WorkflowStatus,@UserID, @ActiveFlag, 0,@JobID)
		
		select 	@LogoID = @@identity,
			@errorcode = @@error	
	end


	select @errorcode = @@error

	if (@errorcode = 0)
	begin
	
		UPDATE 	tblBusinessUnit
		SET 	BusinessUnitName = @BusName,
			DocAuthorization = @DocAuth,
			LogoImageID = @LogoID,
			PublishDate = @PublishDate,
			ExpirationDate = @ExpireDate,
			WorkflowStatus = @WorkflowStatus,
			LastModifiedDate = getdate(),
			LastModifiedBy = @UserID,
			ActiveFlag = @ActiveFlag,
			DeploymentJobID = @JobID
		WHERE 	BusinessUnitID = @BusUnitID

	end

	if (@errorcode <> 0)
	begin
		print 'An error occurred while updating the business unit.'
		rollback tran
		return 0
	end
	else
	begin
		print 'The business unit was updated successfully.'
		commit tran
		return 1
	end
end