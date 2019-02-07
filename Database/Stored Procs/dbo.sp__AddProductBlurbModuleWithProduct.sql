



CREATE    proc sp__AddProductBlurbModuleWithProduct
	@SourceID int = null, -- will be the ProductBlurbModuleId if passing in a BlurbProductList
	@ProductSelection varchar(15) = 'INDIVIDUAL',
	@Title varchar(200) = null,
	@ProductBlurb varchar(2000) = null,
	@BlurbProductList as varchar(500) = '',
	@PublishDate datetime = null,
	@ExpireDate datetime = null,
	@MarkedForDeletion bit = 0,
	@WorkflowStatus varchar(50) = 'WORKING',
	@JobID int = null,
	@UserID int = null,
	@PageID int = null, 
	@ModuleOrder int = 1, 
	@ShowTitle bit = 0, 
	@ActiveFlag int = 1, 
	@ProductBlurbModuleID int OUTPUT
as
begin

/*
created by: Brian Gaines
created on: 12/05/2006
purpose:
	Adds a new product blurb for a product or group of products (also adds a record to the tblPageModuleReln)

usage notes:

declare @bmid int
exec sp__AddProductBlurbModuleWithProduct 1, 'INDIVIDUAL', 'Product Blurb Title', null, '', null, null, 0, 'WORKING', 2, 1, @ProductBlurbModuleID = @bmid output
select @bmid

	If we have multiple products we are associating with a product blurb module, then leave the SourceId parameter
	null, for it will not be used anyway; We will instead use the identity value created on the tblProductBlurbModule 
	table to get the id to be inserted in the tblProductBlurbModuleReln table.

	If we have an individual product we want to associate with the product blurb, then we will want to pass in the 
	product Id in the SourceId parameter, which we will then insert a single row in the reln table.

history:
	Brian Gaines (12/05/2006) - created initial procedure
*/

if (dbo.fn__TableExists('tblProductBlurbModule') > 0 AND
	dbo.fn__TableExists('tblProductBlurbModuleReln') > 0)
begin
	
	if ((@SourceId is null or @SourceId = 0) and UPPER(@ProductSelection) = 'INDIVIDUAL')
	begin
		print 'A product id required'
		return 0
	end
	else if ((@BlurbProductList = '' or @BlurbProductList is null) and UPPER(@ProductSelection) = 'MULTIPLE')
	begin
		print 'A product list is required'
		return 0
	end
	else if (@PageId is null or @UserId = 0)
	begin
		print 'A page id is required'
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

		declare @errorcode int
		select @errorcode = @@error

		insert into tblProductBlurbModule (SourceID, ProductSelection, Title, ProductBlurb, PublishDate, ExpirationDate, WorkflowStatus, LastModifiedBy, ActiveFlag, MarkedForDeletion, DeploymentJobId)
		values (@SourceID, @ProductSelection, @Title, @ProductBlurb, @PublishDate, @ExpireDate, @WorkflowStatus, @UserID, 1, @MarkedForDeletion, @JobID)

		select @errorcode = @@error
		select @ProductBlurbModuleId = @@identity	

		if (@errorcode = 0)
		begin
			insert into tblPageModuleReln (PageID, SourceID, SourceName, ModuleOrder, ShowTitle, PublishDate, ExpirationDate, WorkflowStatus, LastModifiedBy, ActiveFlag, MarkedForDeletion, DeploymentJobID)
			values (@PageID, @ProductBlurbModuleId, 'PRODUCT BLURB', @ModuleOrder, @ShowTitle, @PublishDate, @ExpireDate, @WorkflowStatus, @UserID, @ActiveFlag, @MarkedForDeletion, @JobID)

			select @errorcode = @@error
		end

		if (@errorcode = 0)
		begin
			
			if (@BlurbProductList <> '')
			begin 
				insert into tblProductBlurbModuleReln (ProductBlurbModuleId, ProductId, PublishDate, ExpirationDate, WorkflowStatus, LastModifiedBy, ActiveFlag, MarkedForDeletion, DeploymentJobId)
				select @ProductBlurbModuleId, str, @PublishDate, @ExpireDate, @WorkflowStatus, @UserID, 1, @MarkedForDeletion, @JobID 
				from dbo.fn__CharListToTable(@BlurbProductList,',') -- insert multiple rows by converting the string list passed in to a table.
			end
			else
			begin
				insert into tblProductBlurbModuleReln (ProductBlurbModuleId, ProductId, PublishDate, ExpirationDate, WorkflowStatus, LastModifiedBy, ActiveFlag, MarkedForDeletion, DeploymentJobId)
				values (@ProductBlurbModuleId, @SourceId, @PublishDate, @ExpireDate, @WorkflowStatus, @UserID, 1, @MarkedForDeletion, @JobID)
			end
			
			select @errorcode = @@error
		end

		if (@errorcode = 0)
		begin
			commit tran
			return 1
		end
		begin
			rollback tran
			select @ProductBlurbModuleId = 0
			return 0
		end

	end
end
else
begin
	print 'Tables are missing'
	return 0
end
end