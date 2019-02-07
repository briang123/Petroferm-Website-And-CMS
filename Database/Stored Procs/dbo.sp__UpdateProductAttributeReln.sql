




CREATE   PROC sp__UpdateProductAttributeReln
	@ProdAttribRelnID int = null,
	@ProductID int = null,
	@AttribID int = null,
	@AttribValue varchar(500) = null,
	@PublishDate datetime = null,
	@ExpireDate datetime = null,
	@MarkedForDeletion bit = 0,
	@WorkflowStatus varchar(50) = 'WORKING',
	@JobID int = null,
	@UserID int = null
AS
BEGIN

/*
created by: Kelly Roe
created on: 12/02/2006

purpose:
	update a product attribute value reln

example script usage:
	exec sp__UpdateProductAttributeReln
		parms here

history:
	Kelly Roe    (12/02/2006) - created initial procedure
*/

if (@ProdAttribRelnID is null or @ProdAttribRelnID = 0)
begin
	print 'A product attribute reln id is required'
	return 0
end
else if (@AttribID is null or @AttribID = 0)
begin
	print 'An attribute id is required'
	return 0
end
else if (@AttribValue is null or len(ltrim(rtrim(@AttribValue))) = 0)
begin
	print 'An attribute value is required'
	return 0
end
else if (@UserID is null or @UserID = 0)
begin
	print 'A user id is required'
	return 0
end
else
begin
	if (dbo.fn__TableExists('tblProductAttributeReln') > 0)
	begin

		update 	tblProductAttributeReln
		set	ProductID = @ProductID,
			AttribTypeID = @AttribID,
			AttribValue = @AttribValue,
			PublishDate = @PublishDate,
			ExpirationDate = @ExpireDate,
			WorkflowStatus = @WorkflowStatus,
			LastModifiedDate = getdate(),
			LastModifiedBy = @UserID
		where	ProdAttribRelnID = @ProdAttribRelnID
	
		if (@@error = 0)
		begin
			print 'successfully updated the product attribute value'
			return 1
		end
		else
		begin
			print 'an error occurred while attempting to add a product attribute value'
			return 0
		end
	end
	else
	begin
		print 'The tblProductAttributeReln table is missing'
		return 0
	end
end

END