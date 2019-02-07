







CREATE  proc sp__AddProductSearchAttributeReln
	@ProductID int = null,
	@SearchAttribTypeID int = null,
	@PublishDate datetime = null,
	@ExpireDate datetime = null,
	@MarkedForDeletion bit = 0,
	@WorkflowStatus varchar(50) = 'WORKING',
	@JobID int = null,
	@UserID int = null,
	@ProdSearchAttribRelnID int OUTPUT
as
begin

/*
created by: Kelly Roe
created on: 12/04/2006
purpose:
	Adds a new product search attrib relationship
	
syntax usage:
	declare @ProdSearchAttribRelnID int
		exec sp__AddProductSearchAttributeReln
		@ProductID = 1,
		@SearchAttribTypeID  = 1,
		@PublishDate = null,
		@ExpireDate = null,
		@MarkedForDeletion = 0,
		@WorkflowStatus  = 'WORKING',
		@JobID  = null,
		@UserID  = null,
		@ProdSearchAttribRelnID = null
	select @ProdSearchAttribRelnID

history:
	Kelly Roe	(12/04/2006) - created initial procedure
	Kelly Roe	(12/05/2006) - added update of deployment job record
*/
declare @errorcode int

	if (dbo.fn__TableExists('tblProductSearchAttribReln') > 0)
	begin
	
		if (@ProductID is null or @ProductID = 0)
		begin
			print 'A product id is required'
			return 0
		end
		else if (@SearchAttribTypeID is null or @SearchAttribTypeID = 0)
		begin
			print 'A search attribute id is required'
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
			
				insert into tblProductSearchAttribReln (SearchAttribTypeID, ProductID, PublishDate, ExpirationDate, WorkflowStatus, LastModifiedDate, LastModifiedBy, ActiveFlag, MarkedForDeletion, DeploymentJobId)
				values (@SearchAttribTypeID, @ProductID, @PublishDate, @ExpireDate, @WorkflowStatus, getdate(), @UserID, 1, @MarkedForDeletion, @JobID)
	
				select @errorcode = @@error
			
				if (@errorcode = 0)
				begin
					select @ProdSearchAttribRelnID = @@identity
					
			
					update 	tblDeploymentJobs
					set 	WorkflowStatus = 'WORKING',
						LastModifiedDate = getdate(),
						LastModifiedBy = @UserID
					where 	DeploymentJobID = @JobID
			
					select @errorcode = @@error
				end
				else
				begin
					select @ProdSearchAttribRelnID = 0

				end
			
				if (@errorcode <> 0)
				begin
					print 'An error occurred'
					rollback tran
					return 0
				end
				else
				begin
					print 'Success'
					commit tran
					return 1
				end
			end

	
	end
	else
	begin
		print 'The tblProductSearchAttribReln table is missing'
		return 0
	end


end