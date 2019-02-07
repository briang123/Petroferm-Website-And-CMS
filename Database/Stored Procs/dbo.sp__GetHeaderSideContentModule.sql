


CREATE  proc sp__GetHeaderSideContentModule
	@PageId int = 0,
	@LiveMode bit = 1
as
begin
	if (@PageId = 0)
	begin
		print 'A page id is required'
		return 0
	end
	else
	begin
		if (@LiveMode = 1)
		begin
			-- we do not check the business unit's status in the context of the live website because 
			-- we would not be calling this procedure if we weren't ALREADY in an active business unit
			if (dbo.fn__TableExists('tblPageModuleReln_LIVE') > 0 and 
				dbo.fn__TableExists('tblHeaderSideContentModule_LIVE') > 0)
			begin
				select 	hsc.HeaderSideContentModuleID 	as 'HSC_ModuleID', 
					hsc.Title 			as 'HSC_Title', 
					hsc.LineText1 			as 'HSC_LineText1', 
					hsc.InternalLink1 		as 'HSC_IntLink1', 
					hsc.InternalLink1Type 		as 'HSC_IntLink1Type', 
					hsc.ExternalLink1 		as 'HSC_ExtLink1', 
					hsc.LineText2 			as 'HSC_LineText2', 
					hsc.InternalLink2 		as 'HSC_IntLink2', 
					hsc.InternalLink2Type 		as 'HSC_IntLink2Type', 
					hsc.ExternalLink2 		as 'HSC_ExtLink2'
				from tblPageModuleReln_LIVE pm, tblHeaderSideContentModule_LIVE hsc
				where pm.PageId = @PageID
				and hsc.ActiveFlag = 1
				and dbo.fn__GetDateOnly(getdate()) between dbo.fn__GetDateOnly(hsc.PublishDate) and dbo.fn__GetDateOnly(hsc.ExpirationDate)
				and UPPER(hsc.WorkflowStatus) = 'LIVE'
				and pm.SourceId = hsc.HeaderSideContentModuleID
				and UPPER(pm.SourceName) = 'HEADER SIDE CONTENT'

				return 1
			end
			else
			begin
				print 'Not all live tables exist'
				return 0
			end
		end
	end
end