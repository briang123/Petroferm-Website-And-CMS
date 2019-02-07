


CREATE   proc sp__DeleteProduct
	@ProductID int = null,
	@JobID int = null,
	@WorkflowStatus varchar(50) = 'WORKING',
	@UserID int = null
as
begin

	declare @errorcode int,
		@mark_for_deletion bit,
		@part_of_other_job bit,
		@today datetime

	select @today = getdate()
	select @errorcode = @@error

	select 	@part_of_other_job = count(*)
	from tblProductBlurbModuleReln pbmr, tblProductBlurbModule pbm
	where pbmr.ProductBlurbModuleID  = pbm.SourceId
	and pbm.ProductSelection = 'MULTIPLE' 
	and pbmr.ProductID = @ProductID	
	and upper(pbmr.WorkflowStatus) <> 'LIVE' 
	and upper(pbm.WorkflowStatus) <> 'LIVE'
	and pbmr.DeploymentJobId <> @JobID
	and pbm.DeploymentJobId <> @JobID

	if (@part_of_other_job = 0)
	begin
		select 	@part_of_other_job = count(*)
		from tblPageModuleReln pmr, tblProductBlurbModule pbm
		where pmr.SourceId = pbm.ProductBlurbModuleID
		and pmr.SourceName = 'PRODUCT BLURB'
		and pbm.ProductSelection = 'INDIVIDUAL'
		and pbm.SourceId = @ProductID	
		and upper(pmr.WorkflowStatus) <> 'LIVE' 
		and upper(pbm.WorkflowStatus) <> 'LIVE'
		and pmr.DeploymentJobId <> @JobID
		and pbm.DeploymentJobId <> @JobID

	end
	
	if (@part_of_other_job = 0)
	begin
		select 	@part_of_other_job = count(*)
		from tblProductBlurbModule
		where SourceId = @ProductId
		and ProductSelection = 'INDIVIDUAL'	
		and upper(WorkflowStatus) <> 'LIVE' 
		and DeploymentJobId <> @JobID
	end

	if (@part_of_other_job = 0)
	begin
		select 	@part_of_other_job = count(*)
		from tblProductGridRowDef where ProductID = @ProductID	
		and upper(WorkflowStatus) <> 'LIVE' 
		and DeploymentJobId <> @JobID
	end

	if (@part_of_other_job = 0)
	begin
		select 	@part_of_other_job = count(*)
		from tblProductAttributeReln where ProductID = @ProductID	
		and upper(WorkflowStatus) <> 'LIVE' 
		and DeploymentJobId <> @JobID
	end

	if (@part_of_other_job = 0)
	begin
		select 	@part_of_other_job = count(*)
		from tblProductSearchAttribReln where ProductID = @ProductID	
		and upper(WorkflowStatus) <> 'LIVE' 
		and DeploymentJobId <> @JobID
	end

	if (@part_of_other_job = 0)
	begin
		select 	@part_of_other_job = count(*)
		from tblDocument where ProductID = @ProductID	
		and upper(WorkflowStatus) <> 'LIVE' 
		and DeploymentJobId <> @JobID
	end

	if (@part_of_other_job = 0)
	begin
		select 	@part_of_other_job = count(*)
		from tblProduct where ProductID = @ProductID	
		and upper(WorkflowStatus) <> 'LIVE' 
		and DeploymentJobId <> @JobID
	end

	if (@part_of_other_job = 0)
	begin

		begin tran

		select @errorcode = @@error

		if (@errorcode = 0)
		begin

			select 	@mark_for_deletion = count(*) 
			from tblProductBlurbModuleReln_LIVE pbmr, tblProductBlurbModule_LIVE pbm
			where pbmr.ProductBlurbModuleID  = pbm.SourceId
			and pbm.ProductSelection = 'MULTIPLE' 
			and pbmr.ProductID = @ProductID	

			if (@mark_for_deletion = 1)
			begin
			
				update 	tblProductBlurbModuleReln 
				set 	LastModifiedBy = @UserID, LastModifiedDate = @today, MarkedForDeletion = 1, WorkflowStatus = @WorkflowStatus, DeploymentJobId = @JobID
				from 	tblProductBlurbModuleReln pbmr, tblProductBlurbModule pbm
				where 	pbmr.ProductBlurbModuleID  = pbm.SourceId
				and 	pbm.ProductSelection = 'MULTIPLE' 
				and 	pbmr.ProductID = @ProductID	

				update 	tblProductBlurbModule
				set 	LastModifiedBy = @UserID, LastModifiedDate = @today, MarkedForDeletion = 1, WorkflowStatus = @WorkflowStatus, DeploymentJobId = @JobID
				from 	tblProductBlurbModuleReln pbmr, tblProductBlurbModule pbm
				where 	pbmr.ProductBlurbModuleID  = pbm.SourceId
				and 	pbm.ProductSelection = 'MULTIPLE' 
				and 	pbmr.ProductID = @ProductID				
	
			end	
			else if(@mark_for_deletion = 0)
			begin 
				delete tblProductBlurbModuleReln
				from tblProductBlurbModuleReln pbmr, tblProductBlurbModule pbm
				where pbmr.ProductBlurbModuleID  = pbm.SourceId
				and pbm.ProductSelection = 'MULTIPLE' 
				and pbmr.ProductID = @ProductID	
			end

			select @errorcode = @@error
		end


		if (@errorcode = 0)
		begin

			select 	@mark_for_deletion = count(*) 
			from tblPageModuleReln_LIVE pmr, tblProductBlurbModule_LIVE pbm
			where pmr.SourceId = pbm.ProductBlurbModuleID
			and pmr.SourceName = 'PRODUCT BLURB'
			and pbm.ProductSelection = 'INDIVIDUAL'
			and pbm.SourceId = @ProductID	

			if (@mark_for_deletion = 1)
			begin

				update tblPageModuleReln
				set 	LastModifiedBy = @UserID, LastModifiedDate = @today, MarkedForDeletion = 1, WorkflowStatus = @WorkflowStatus, DeploymentJobId = @JobID
				from 	tblPageModuleReln pmr, tblProductBlurbModule pbm
				where 	pmr.SourceId = pbm.ProductBlurbModuleID
				and 	pmr.SourceName = 'PRODUCT BLURB'
				and 	pbm.ProductSelection = 'INDIVIDUAL'
				and 	pbm.SourceId = @ProductID	

				update 	tblProductBlurbModule
				set 	LastModifiedBy = @UserID, LastModifiedDate = @today, MarkedForDeletion = 1, WorkflowStatus = @WorkflowStatus, DeploymentJobId = @JobID
				from 	tblPageModuleReln pmr, tblProductBlurbModule pbm
				where 	pmr.SourceId = pbm.ProductBlurbModuleID
				and 	pmr.SourceName = 'PRODUCT BLURB'
				and 	pbm.ProductSelection = 'INDIVIDUAL'
				and 	pbm.SourceId = @ProductID	
	
			end	
			else if(@mark_for_deletion = 0)
			begin 
				delete tblPageModuleReln
				from tblPageModuleReln pmr, tblProductBlurbModule pbm
				where pmr.SourceId = pbm.ProductBlurbModuleID
				and pmr.SourceName = 'PRODUCT BLURB'
				and pbm.ProductSelection = 'INDIVIDUAL'
				and pbm.SourceId = @ProductID	
			end

			select @errorcode = @@error
		end

		if (@errorcode = 0)
		begin

			select 	@mark_for_deletion = count(*) 
			from tblProductBlurbModule_LIVE 
			where SourceId = @ProductId
			and ProductSelection = 'INDIVIDUAL'	

			if (@mark_for_deletion = 1)
			begin
				update 	tblProductBlurbModule
				set 	LastModifiedBy = @UserID, LastModifiedDate = @today, MarkedForDeletion = 1, WorkflowStatus = @WorkflowStatus, DeploymentJobId = @JobID	
				from 	tblProductBlurbModule
				where 	SourceId = @ProductId
				and 	ProductSelection = 'INDIVIDUAL'	
			end	
			else if(@mark_for_deletion = 0)
			begin 
				delete from tblProductBlurbModule 
				where SourceId = @ProductId
				and ProductSelection = 'INDIVIDUAL'	
			end

			select @errorcode = @@error
		end

		if (@errorcode = 0)
		begin

			select 	@mark_for_deletion = count(*) 
			from tblProductGridRowDef_LIVE where ProductID = @ProductID	

			if (@mark_for_deletion = 1)
			begin
				update tblProductGridRowDef 
				set 	LastModifiedBy = @UserID, LastModifiedDate = @today, MarkedForDeletion = 1, WorkflowStatus = @WorkflowStatus, DeploymentJobId = @JobID					
				where ProductID = @ProductID					
			end	
			else if(@mark_for_deletion = 0)
			begin 
				delete from tblProductGridRowDef where ProductID = @ProductID	
			end

			select @errorcode = @@error
		end

		if (@errorcode = 0)
		begin

			select 	@mark_for_deletion = count(*) 
			from tblProductAttributeReln_LIVE where ProductID = @ProductID	

			if (@mark_for_deletion = 1)
			begin
				update 	tblProductAttributeReln
				set 	LastModifiedBy = @UserID, LastModifiedDate = @today, MarkedForDeletion = 1, WorkflowStatus = @WorkflowStatus, DeploymentJobId = @JobID	
				from 	tblProductAttributeReln where ProductID = @ProductID	
			end	
			else if(@mark_for_deletion = 0)
			begin 
				delete from tblProductAttributeReln where ProductID = @ProductID	
			end

			select @errorcode = @@error
		end

		if (@errorcode = 0)
		begin

			select 	@mark_for_deletion = count(*) 
			from tblProductSearchAttribReln_LIVE where ProductID = @ProductID	

			if (@mark_for_deletion = 1)
			begin
				update 	tblProductSearchAttribReln
				set 	LastModifiedBy = @UserID, LastModifiedDate = @today, MarkedForDeletion = 1, WorkflowStatus = @WorkflowStatus, DeploymentJobId = @JobID	
				from 	tblProductSearchAttribReln where ProductID = @ProductID	
			end	
			else if(@mark_for_deletion = 0)
			begin 
				delete from tblProductSearchAttribReln where ProductID = @ProductID	
			end

			select @errorcode = @@error
		end

		if (@errorcode = 0)
		begin

			select 	@mark_for_deletion = count(*) 
			from tblDocument_LIVE where ProductID = @ProductID	

			if (@mark_for_deletion = 1)
			begin
				update 	tblDocument
				set 	LastModifiedBy = @UserID, LastModifiedDate = @today, MarkedForDeletion = 1, WorkflowStatus = @WorkflowStatus, DeploymentJobId = @JobID	
				from 	tblDocument where ProductID = @ProductID	
			end	
			else if(@mark_for_deletion = 0)
			begin 
				delete from tblDocument where ProductID = @ProductID	
			end

			select @errorcode = @@error
		end


		if (@errorcode = 0)
		begin

			select 	@mark_for_deletion = count(*) 
			from tblProduct_LIVE where ProductID = @ProductID	

			if (@mark_for_deletion = 1)
			begin
				update tblProduct
				set LastModifiedBy = @UserID, LastModifiedDate = @today, MarkedForDeletion = 1, WorkflowStatus = @WorkflowStatus, DeploymentJobId = @JobID	
				from tblProduct where ProductID = @ProductID	
			end	
			else if(@mark_for_deletion = 0)
			begin 
				delete from tblProduct where ProductID = @ProductID	
			end

			select @errorcode = @@error
		end

		if (@errorcode = 0)
		begin
	
			commit tran
			print 'The product was deleted'
			return 1
		end
		else
		begin
			rollback tran
			print 'An error occurred while attempting to delete the product'
			return 0
		end
	end
	else
	begin
		print 'The product is part of another job'
		return 0
	end

end