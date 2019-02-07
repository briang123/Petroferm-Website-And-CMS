


CREATE  PROC sp__UpdateProductAttribute
	@BusUnitID int = null,
	@AttribTypeID int = null,
	@AttribName varchar(100) = null,
	@AllowMultiple bit = 0,
	@IsReadOnly bit = 0,
	@PublishDate datetime = null,
	@ExpireDate datetime = null,
	@MarkedForDeletion bit = 0,
	@WorkflowStatus varchar(50) = 'WORKING',
	@JobID int = null,
	@UserID int = null
AS
BEGIN

/*
created by: Brian Gaines
created on: 11/30/2006

purpose:
	Get a single product attribute by its ID

example script usage:
	exec sp__UpdateProductAttribute
		@UserID = 1,
		@BusUnitID = 2, 
		@AttribTypeID  = 3,
		@AttribName = 'Attribute Name',
		@AllowMultiple = 0

history:
	Brian Gaines (11/30/2006) - created initial procedure
	Kelly Roe    (12/01/2006) - added additional parms to update
*/

if (@BusUnitID is null or @BusUnitID = 0)
begin
	print 'A business unit id is required'
	return 0
end
else if (@AttribTypeID is null or @AttribTypeID = 0)
begin
	print 'An attribute id is required'
	return 0
end
else if (@AttribName is null or len(ltrim(rtrim(@AttribName))) = 0)
begin
	print 'An attribute name is required'
	return 0
end
else if (@UserID is null or @UserID = 0)
begin
	print 'A user id is required'
	return 0
end
else
begin
	if (dbo.fn__TableExists('tblProductAttributeType') > 0)
	begin

		update 	tblProductAttributeType
		set	BusinessUnitID = @BusUnitID,
			AttribName = @AttribName,
			AllowMultiple = @AllowMultiple,
			IsReadOnly = @IsReadOnly,
			PublishDate = @PublishDate,
			ExpirationDate = @ExpireDate,
			WorkflowStatus = @WorkflowStatus,
			LastModifiedDate = getdate(),
			LastModifiedBy = @UserID
		where	BusinessUnitId = @BusUnitID
		and	AttribTypeID = @AttribTypeID
	
		if (@@error = 0)
		begin
			print 'successfully updated the product attribute'
			return 1
		end
		else
		begin
			print 'an error occurred while attempting to add a product attribute'
			return 0
		end
	end
	else
	begin
		print 'The tblProductAttributeType table is missing'
		return 0
	end
end

END