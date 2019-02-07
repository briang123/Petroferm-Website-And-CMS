




CREATE     proc sp__DeleteProductBlurb
	@ProductBlurbModuleId int = null,
	@JobID int = null,
	@UserID int = null,
	@WorkflowStatus varchar(50) = 'WORKING',
	@MarkedForDeletion bit = 1
as
begin
/*
created by: Brian Gaines
created on: 12/05/2006
purpose:
	Deletes product blurb and its relationship to the product; however, the product deletion process
	is handled from the product management page.

pseudo code for deleting product blurb:

determine if part of other job by checking:
	sql1) individual product for blurb (pbm.sourceid=pbm_r.productblurbmoduleid)
	sql2) multiple products for blurb (pbm.sourceid=pbm_r.productid)

if NOT part of other job then
	sql3) check if part of live website
	
	if part of live website then
		sql4/5) update cms tables (pbm and pbm_r) to be marked for deletion
	else
		sql6/7) delete from cms tables (pbm and pbm_r)
else
	do nothing
end if

history:
	Brian Gaines (12/05/2006) - created initial procedure
	Brian Gaines (12/28/2006) - found/removed unnecessary table in "from" clause (sql4/5)
*/

if (dbo.fn__TableExists('tblProductBlurbModule') > 0 AND
	dbo.fn__TableExists('tblProductBlurbModuleReln') > 0)
begin
	
	if (@ProductBlurbModuleId is null or @ProductBlurbModuleId = 0)
	begin
		print 'A product blurb module id is required'
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
		

		declare @errorcode int,
			@mark_for_deletion bit,
			@part_of_other_job bit

		select @errorcode = @@error

		-- sql1)
		-- determine if blurb or products attached to blurb are part of another job
		-- we don't need to join with the tblProducts between pbm.sourceid = products.productid
		-- because we only care about whether the blurb module associated to that product is part of 
		-- another job
		select 	@part_of_other_job = count(*) from tblProductBlurbModule
		where 	upper(WorkflowStatus) <> 'LIVE' 
		and 	DeploymentJobId <> @JobID
		and	ProductBlurbModuleId = @ProductBlurbModuleId

		if (@part_of_other_job = 0)
		begin
			-- sql2)
			select 	@part_of_other_job = count(*) from tblProductBlurbModuleReln 
			where 	upper(WorkflowStatus) <> 'LIVE' 
			and 	DeploymentJobId <> @JobID				
			and	ProductBlurbModuleId = @ProductBlurbModuleId

		end
		
		if (@part_of_other_job = 0)
		begin

			if (dbo.fn__TableExists('tblProductBlurbModule_LIVE') > 0)
			begin

				-- sql3) check if we have a live record regardless of the status
				select 	@mark_for_deletion = count(*) 
				from 	tblProductBlurbModule_LIVE 
				where 	ProductBlurbModuleId = @ProductBlurbModuleId
	
			end
			else
			begin
				select @mark_for_deletion = 0
			end

			begin tran

			if (@mark_for_deletion = 1)
				
				if (@errorcode = 0)
				begin
	
					-- sql4)
					-- mark for deletion the product relationships attached to product blurb (ProductSelection = "MULTIPLE")
					-- basically, just update any record in the relationship table where the productblurbmoduleid matches ours
					update 	tblProductBlurbModuleReln
					set 	LastModifiedBy = @UserID, 
						MarkedForDeletion = @MarkedForDeletion, 
						WorkflowStatus = @WorkflowStatus, 
						DeploymentJobId = @JobID
					where 	ProductBlurbModuleId = @ProductBlurbModuleId
					
					select @errorcode = @@error
				end

				if (@errorcode = 0)
				begin
					-- sql5)
					-- mark for deletion the single product for a product blurb (ProductSelection = "INDIVIDUAL")
					-- basically, just update any record in the blurb table where the productblurbmoduleid matches ours
					update 	tblProductBlurbModule
					set 	LastModifiedBy = @UserID, 
						MarkedForDeletion = @MarkedForDeletion, 
						WorkflowStatus = @WorkflowStatus, 
						DeploymentJobId = @JobID
					where 	ProductBlurbModuleId = @ProductBlurbModuleId

					select @errorcode = @@error
				end
				
			end
			else if (@mark_for_deletion = 0)
			begin
		
				if (@errorcode = 0)
				begin
					-- sql6)
					-- since there is no live record, we delete from our blurb based on the blurb id
					delete from tblProductBlurbModuleReln where ProductBlurbModuleId = @ProductBlurbModuleId
					select @errorcode = @@error
				end

				if (@errorcode = 0)
				begin
					-- sql7)
					-- since there is no live record, we delete products from our blurb based on the blurb reln id
					delete from tblProductBlurbModule where ProductBlurbModuleId = @ProductBlurbModuleId
					select @errorcode = @@error
				end

			end

				
			if (@errorcode = 0)
			begin
				rollback tran
				return 1
			end
			begin
				commit tran
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