
--select * from tblimagemodule

CREATE proc sp__GetNavImagesByMarket 
	@MarketID int = null,
	@LiveMode bit = 1
as
begin

	if (@MarketId is null or @MarketId = 0)
	begin
		print 'A market id is required'
		return 0
	end
	else
	begin
		if (@LiveMode = 1)
		begin
			if (dbo.fn__TableExists('tblMarket_LIVE') > 0 AND
				dbo.fn__TableExists('tblPage_LIVE') > 0 AND
				dbo.fn__TableExists('tblPageModuleReln_LIVE') > 0 AND
				dbo.fn__TableExists('tblImageModule_LIVE') > 0 AND
				dbo.fn__TableExists('tblImage_LIVE') > 0)
			begin
				select 	i.ImageID, 
					i.ImagePath, 
					i.Alt, 
					i.Width, 
					i.Height, 
					im.ImageType,
					im.ImageOrder,
					pm.PageModuleRelnId,
					pm.ModuleOrder,
					pm.SourceName,
					pm.SourceId,
					pm.ShowTitle,
					pm.PageId
				from 	tblMarket_LIVE m, 
					tblPage_LIVE p, 
					tblPageModuleReln_LIVE pm, 
					tblImageModule_LIVE im, 
					tblImage_LIVE i
				where	m.MarketId = @MarketID
				and 	dbo.fn__GetDateOnly(getdate()) between dbo.fn__GetDateOnly(p.PublishDate) and dbo.fn__GetDateOnly(p.ExpirationDate)
				and 	dbo.fn__GetDateOnly(getdate()) between dbo.fn__GetDateOnly(m.PublishDate) and dbo.fn__GetDateOnly(m.ExpirationDate)
				and 	dbo.fn__GetDateOnly(getdate()) between dbo.fn__GetDateOnly(pm.PublishDate) and dbo.fn__GetDateOnly(pm.ExpirationDate)
				and 	dbo.fn__GetDateOnly(getdate()) between dbo.fn__GetDateOnly(im.PublishDate) and dbo.fn__GetDateOnly(im.ExpirationDate)
				and 	dbo.fn__GetDateOnly(getdate()) between dbo.fn__GetDateOnly(i.PublishDate) and dbo.fn__GetDateOnly(i.ExpirationDate)
				and 	upper(p.WorkflowStatus) = 'LIVE' and upper(m.WorkflowStatus) = 'LIVE' and upper(pm.WorkflowStatus) = 'LIVE' 
				and 	upper(im.WorkflowStatus) = 'LIVE' and upper(i.WorkflowStatus) = 'LIVE'
				and 	m.ActiveFlag = 1 and p.ActiveFlag = 1 and pm.ActiveFlag = 1 and im.ActiveFlag = 1 and i.ActiveFlag = 1				
				and 	UPPER(pm.SourceName) in ('NAV ON IMAGE', 'NAV OFF IMAGE', 'HEADER IMAGE')
				and 	p.MarketId = m.MarketId
				and 	p.PageId = pm.PageId
				and 	pm.SourceId = im.ImageModuleId
				and 	im.ImageId = i.ImageId
				
				return 1
			end
			else
			begin
				print 'Missing some live tables.'
				return 0
			end
		end
		else
		begin

			if (dbo.fn__TableExists('tblMarket') > 0 AND
				dbo.fn__TableExists('tblPage') > 0 AND
				dbo.fn__TableExists('tblPageModuleReln') > 0 AND
				dbo.fn__TableExists('tblImageModule') > 0 AND
				dbo.fn__TableExists('tblImage') > 0)
			begin
				print 'code for cms here'
			end
		end
		
	end
end