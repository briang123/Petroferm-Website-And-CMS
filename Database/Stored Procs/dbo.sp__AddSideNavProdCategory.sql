


/*

declare @id int
exec sp__AddSideNavProdCategory 4, 0, 'test cat',1,NULL,null,0,'WORKING',2,1,@id
print @id

*/
CREATE  proc sp__AddSideNavProdCategory
	@BusUnitID int = null,
	@MarketID int = 0,
	@CategoryName varchar(50) = null,
	@CategoryOrder int = null,
	@PublishDate datetime = null,
	@ExpireDate datetime = null,
	@MarkedForDeletion bit = 0,
	@WorkflowStatus varchar(50) = 'WORKING',
	@JobID int = null,
	@UserID int = null,
	@ProdCatID int OUTPUT
as
begin

/*
created by: Kelly Roe
created on: 12/14/2006
purpose:
	Adds a new product category for the side nav for a bus unit

history:
	Kelly Roe   (12/14/2006) - created initial procedure
*/

	if (dbo.fn__TableExists('tblSideNavProdCategory') > 0)
	begin
	
		if (@BusUnitID is null or @BusUnitID = 0)
		begin
			print 'A business unit id is required'
			return 0
		end
		else if (@CategoryName is null or len(ltrim(rtrim(@CategoryName))) = 0)
		begin
			print 'An category name is required'
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
			
			insert into tblSideNavProdCategory (BusinessUnitID, MarketID, CategoryName, CategoryOrder, PublishDate, ExpirationDate, WorkflowStatus, LastModifiedDate, LastModifiedBy, ActiveFlag, MarkedForDeletion, DeploymentJobId)
			values (@BusUnitID, @MarketID, @CategoryName, @CategoryOrder, @PublishDate, @ExpireDate, @WorkflowStatus, getdate(), @UserID, 1, @MarkedForDeletion, @JobID)
	
			if (@@error = 0)
			begin
				select @ProdCatID = @@identity
				return 1
			end
			begin
				select @ProdCatID = 0
				return 0
			end

		end
	
	end
	else
	begin
		print 'The table is missing'
		return 0
	end

end