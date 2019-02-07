




CREATE        proc sp__AddProduct
	@BusUnitID int = null,
	@ProductName varchar(200) = null,
	@ProductKeywords varchar(200) = null,
	@ProductBlurb varchar(2000) = null,
	@ProductApprovals varchar(2000) = null,
	@PublishDate datetime = null,
	@ExpireDate datetime = null,
	@MarkedForDeletion bit = 0,
	@WorkflowStatus varchar(50) = 'WORKING',
	@JobID int = null,
	@UserID int = null,
	@ProductID int OUTPUT
as
begin

/*
created by: Kelly Roe
created on: 12/01/2006
purpose:
	Adds a new product for a particular business unit
	
syntax usage:
	declare @productId int
	exec sp__AddProduct
		@BusUnitID int = 1,
		@ProductName varchar(200) = 'Product Name',
		@ProductKeywords varchar(200) = 'Product Keywords',
		@ProductBlurb varchar(2000) = 'Product Blurb',
		@ProductApprovals varchar(2000) = 'Product Approvals',
		@PublishDate datetime = null,
		@ExpireDate datetime = null,
		@MarkedForDeletion bit = 0,
		@WorkflowStatus varchar(50) = 'WORKING',
		@JobID int = 1,
		@UserID int = 1,
		@ProductID = @productId OUTPUT
	select @productId

history:
	Kelly Roe	(12/01/2006) - created initial procedure
	Kelly Roe	(12/15/2006) - add a attrib/value pair for Product attrib type (for the name)
*/

	if (dbo.fn__TableExists('tblProduct') > 0)
	begin
	
		if (@BusUnitID is null or @BusUnitID = 0)
		begin
			print 'A business unit id is required'
			return 0
		end
		else if (@ProductName is null or len(ltrim(rtrim(@ProductName))) = 0)
		begin
			print 'An product name is required'
			return 0
		end
		else if (@UserID is null or @UserID = 0)
		begin
			print 'A user id is required'
			return 0
		end
		else if (@JobID is null or @JobId = 0)
		begin
			print 'a job id is required'
			return 0
		end
		else
		begin


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

				declare @errorcode int,	
				        @AttribTypeID int
				-- get the attrib type id to use for attrib/value reln
				select @AttribTypeID = AttribTypeID from tblProductAttributeType
							 where	BusinessUnitID = @BusUnitID and
							 UPPER(AttribName) = 'PRODUCT' and ActiveFlag = 1
			

				insert into tblProduct (BusinessUnitID, ProductName, ProductKeywords, ProductBlurb, ProductApprovals, PublishDate, ExpirationDate, WorkflowStatus, LastModifiedDate, LastModifiedBy, ActiveFlag, MarkedForDeletion, DeploymentJobId)
				values (@BusUnitID, @ProductName, @ProductKeywords, @ProductBlurb, @ProductApprovals, @PublishDate, @ExpireDate, @WorkflowStatus, getdate(), @UserID, 1, @MarkedForDeletion, @JobID)
				select @errorcode = @@error
				select @ProductId = @@identity

				-- also insert an attrib/value pair for product name
				if (@errorcode = 0)
				begin
					insert into tblProductAttributeReln (AttribTypeID, ProductID, AttribValue, PublishDate, ExpirationDate, WorkflowStatus, LastModifiedDate, LastModifiedBy, ActiveFlag, MarkedForDeletion, DeploymentJobId)
					values (@AttribTypeID, @ProductID, @ProductName, @PublishDate, @ExpireDate, @WorkflowStatus, getdate(), @UserID, 1, @MarkedForDeletion, @JobID)
		


				end


				if (@errorcode <> 0)
				begin
					print 'An error occurred while creating a product. The creation process will be rolled back to its original state.'
					rollback tran
					return 0
				end
				else
				begin
					print 'The product was create successfully.'
					commit tran
					return 1
				end
				
		end
	
	end
	else
	begin
		print 'The tblProduct table is missing'
		return 0
	end

end